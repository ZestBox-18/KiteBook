/**
 * Copyright (C), 2026-05-25
 * @author ZestBox
 * @date 2026/05/25
 * @version 1.0
 * @description: 报表模块数据聚合工具
 */

import { BillBean, BillManager, BillTypeEnum, CategoryBean, CategoryManager } from 'base';
import { dbManager, resultSet2Record, Clog } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { BudgetAnalysisBean } from '../models/BudgetAnalysisBean';
import { CategoryStatBean } from '../models/CategoryStatBean';
import { IncomeExpenseBean } from '../models/IncomeExpenseBean';
import { TimeDimensionEnum } from '../models/TimeDimensionEnum';

const TAG: string = '[ReportDataHelper]';
const DAY_MS: number = 24 * 60 * 60 * 1000;
const BUDGET_TABLE_NAME: string = 'budgets';

class TimeBucket {
  label: string = '';
  startTime: number = 0;
  endTime: number = 0;
  income: number = 0;
  expense: number = 0;

  constructor(label: string, startTime: number, endTime: number) {
    this.label = label;
    this.startTime = startTime;
    this.endTime = endTime;
  }
}

class TimeRange {
  startTime: number = 0;
  endTime: number = 0;

  constructor(startTime: number, endTime: number) {
    this.startTime = startTime;
    this.endTime = endTime;
  }
}

class CategoryAccumulator {
  categoryName: string = '';
  amount: number = 0;
  count: number = 0;
  icon: Resource = $r('sys.symbol.ellipsis_circle');

  constructor(categoryName: string, icon: Resource) {
    this.categoryName = categoryName;
    this.icon = icon;
  }
}

class BudgetRecord {
  category: string = '';
  amount: number = 0;
  month: string = '';

  constructor(category: string, amount: number, month: string) {
    this.category = category;
    this.amount = amount;
    this.month = month;
  }
}

export class ReportDataHelper {
  /**
   * 加载收支趋势报表数据，按所选时间维度聚合为连续时间桶。
   */
  static async loadIncomeExpenseReport(timeDimension: TimeDimensionEnum): Promise<IncomeExpenseBean[]> {
    const buckets: TimeBucket[] = ReportDataHelper.buildTrendBuckets(timeDimension);
    if (buckets.length === 0) {
      return [];
    }
    const lastBucket: TimeBucket = buckets[buckets.length - 1];
    const bills: BillBean[] =
      await BillManager.getBillsByRange(buckets[0].startTime, lastBucket.endTime, '');

    bills.forEach((bill: BillBean) => {
      for (let index = 0; index < buckets.length; index++) {
        const bucket: TimeBucket = buckets[index];
        if (bill.date >= bucket.startTime && bill.date < bucket.endTime) {
          if (bill.type === BillTypeEnum.INCOME) {
            bucket.income += bill.amount;
          } else if (bill.type === BillTypeEnum.EXPENSE) {
            bucket.expense += bill.amount;
          }
          break;
        }
      }
    });

    return buckets.map((bucket: TimeBucket) =>
      new IncomeExpenseBean(bucket.label, bucket.income, bucket.expense, bucket.startTime));
  }

  /**
   * 加载分类报表数据，仅统计支出类流水并复用分类表中的系统图标。
   */
  static async loadCategoryReport(timeDimension: TimeDimensionEnum): Promise<CategoryStatBean[]> {
    const range: TimeRange = ReportDataHelper.buildCurrentRange(timeDimension);
    const expenseBills: BillBean[] =
      await BillManager.getBillsByRange(range.startTime, range.endTime, BillTypeEnum.EXPENSE);
    const categories: CategoryBean[] = await CategoryManager.getCategoriesByType(BillTypeEnum.EXPENSE);
    const accumulatorMap: Map<string, CategoryAccumulator> = new Map();

    expenseBills.forEach((bill: BillBean) => {
      let accumulator: CategoryAccumulator | undefined = accumulatorMap.get(bill.category);
      if (!accumulator) {
        accumulator = new CategoryAccumulator(bill.category, ReportDataHelper.resolveCategoryIcon(bill.category, categories));
        accumulatorMap.set(bill.category, accumulator);
      }
      accumulator.amount += bill.amount;
      accumulator.count += 1;
    });

    const categoryStats: CategoryStatBean[] = Array.from(accumulatorMap.values())
      .sort((first: CategoryAccumulator, second: CategoryAccumulator) => second.amount - first.amount)
      .map((item: CategoryAccumulator, index: number) =>
        new CategoryStatBean(
          item.categoryName,
          item.icon,
          ReportDataHelper.getCategoryColor(index),
          item.amount,
          item.count
        ));
    return categoryStats;
  }

  /**
   * 加载某个月份的预算数据，并用真实支出回填每个预算项的已用额度。
   */
  static async loadBudgetReport(monthAnchor: number): Promise<BudgetAnalysisBean[]> {
    const monthKey: string = ReportDataHelper.buildMonthKey(monthAnchor);
    const budgetRecords: BudgetRecord[] = await ReportDataHelper.queryBudgetsByMonth(monthKey);
    if (budgetRecords.length === 0) {
      return [];
    }

    const monthDate: Date = new Date(monthAnchor);
    const monthStart: number = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1).getTime();
    const monthEnd: number = new Date(monthDate.getFullYear(), monthDate.getMonth() + 1, 1).getTime();
    const expenseBills: BillBean[] =
      await BillManager.getBillsByRange(monthStart, monthEnd, BillTypeEnum.EXPENSE);
    const expenseMap: Map<string, number> = new Map();

    expenseBills.forEach((bill: BillBean) => {
      const currentAmount: number = expenseMap.get(bill.category) ?? 0;
      expenseMap.set(bill.category, currentAmount + bill.amount);
    });

    return budgetRecords
      .map((record: BudgetRecord) =>
        new BudgetAnalysisBean(
          `${record.category}预算`,
          record.amount,
          expenseMap.get(record.category) ?? 0,
          ReportDataHelper.formatMonthText(monthAnchor)
        ))
      .sort((first: BudgetAnalysisBean, second: BudgetAnalysisBean) => second.usageRate - first.usageRate);
  }

  private static async queryBudgetsByMonth(month: string): Promise<BudgetRecord[]> {
    const predicates = new relationalStore.RdbPredicates(BUDGET_TABLE_NAME);
    predicates.equalTo('month', month);
    predicates.orderByAsc('id');

    return new Promise<BudgetRecord[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          const budgets: BudgetRecord[] = rows.map((row: Record<string, object>) =>
            new BudgetRecord(String(row['category']), Number(row['amount']), String(row['month'])));
          resolve(budgets);
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, '查询预算失败', err);
          reject([]);
        });
    });
  }

  private static buildTrendBuckets(timeDimension: TimeDimensionEnum): TimeBucket[] {
    if (timeDimension === TimeDimensionEnum.DAY) {
      return ReportDataHelper.buildDayBuckets(7);
    }
    if (timeDimension === TimeDimensionEnum.WEEK) {
      return ReportDataHelper.buildWeekBuckets(8);
    }
    if (timeDimension === TimeDimensionEnum.YEAR) {
      return ReportDataHelper.buildYearBuckets(5);
    }
    return ReportDataHelper.buildMonthBuckets(6);
  }

  private static buildDayBuckets(count: number): TimeBucket[] {
    const dayBuckets: TimeBucket[] = [];
    const todayStart: number = ReportDataHelper.getDayStart(Date.now());
    for (let index = count - 1; index >= 0; index--) {
      const startTime: number = todayStart - index * DAY_MS;
      const endTime: number = startTime + DAY_MS;
      dayBuckets.push(new TimeBucket(ReportDataHelper.formatMonthDayText(startTime), startTime, endTime));
    }
    return dayBuckets;
  }

  private static buildWeekBuckets(count: number): TimeBucket[] {
    const weekBuckets: TimeBucket[] = [];
    const currentWeekStart: number = ReportDataHelper.getWeekStart(Date.now());
    for (let index = count - 1; index >= 0; index--) {
      const startTime: number = currentWeekStart - index * 7 * DAY_MS;
      const endTime: number = startTime + 7 * DAY_MS;
      weekBuckets.push(
        new TimeBucket(
          `${ReportDataHelper.formatMonthDayText(startTime)}周`,
          startTime,
          endTime
        ));
    }
    return weekBuckets;
  }

  private static buildMonthBuckets(count: number): TimeBucket[] {
    const monthBuckets: TimeBucket[] = [];
    const now: Date = new Date();
    for (let index = count - 1; index >= 0; index--) {
      const bucketDate: Date = new Date(now.getFullYear(), now.getMonth() - index, 1);
      const startTime: number = bucketDate.getTime();
      const endTime: number = new Date(bucketDate.getFullYear(), bucketDate.getMonth() + 1, 1).getTime();
      monthBuckets.push(
        new TimeBucket(
          `${bucketDate.getFullYear()}-${ReportDataHelper.padNumber(bucketDate.getMonth() + 1)}`,
          startTime,
          endTime
        ));
    }
    return monthBuckets;
  }

  private static buildYearBuckets(count: number): TimeBucket[] {
    const yearBuckets: TimeBucket[] = [];
    const currentYear: number = new Date().getFullYear();
    for (let index = count - 1; index >= 0; index--) {
      const year: number = currentYear - index;
      const startTime: number = new Date(year, 0, 1).getTime();
      const endTime: number = new Date(year + 1, 0, 1).getTime();
      yearBuckets.push(new TimeBucket(`${year}`, startTime, endTime));
    }
    return yearBuckets;
  }

  private static buildCurrentRange(timeDimension: TimeDimensionEnum): TimeRange {
    const now: Date = new Date();
    if (timeDimension === TimeDimensionEnum.DAY) {
      const startTime: number = ReportDataHelper.getDayStart(now.getTime());
      return new TimeRange(startTime, startTime + DAY_MS);
    }
    if (timeDimension === TimeDimensionEnum.WEEK) {
      const startTime: number = ReportDataHelper.getWeekStart(now.getTime());
      return new TimeRange(startTime, startTime + 7 * DAY_MS);
    }
    if (timeDimension === TimeDimensionEnum.YEAR) {
      const startTime: number = new Date(now.getFullYear(), 0, 1).getTime();
      const endTime: number = new Date(now.getFullYear() + 1, 0, 1).getTime();
      return new TimeRange(startTime, endTime);
    }
    const startTime: number = new Date(now.getFullYear(), now.getMonth(), 1).getTime();
    const endTime: number = new Date(now.getFullYear(), now.getMonth() + 1, 1).getTime();
    return new TimeRange(startTime, endTime);
  }

  private static resolveCategoryIcon(categoryName: string, categories: CategoryBean[]): Resource {
    for (let index = 0; index < categories.length; index++) {
      const category: CategoryBean = categories[index];
      if (category.name === categoryName) {
        return category.getIconResource();
      }
    }
    return $r('sys.symbol.ellipsis_circle');
  }

  private static getCategoryColor(index: number): string {
    const colorIndex: number = index % 6;
    if (colorIndex === 0) {
      return '#4BB3FF';
    }
    if (colorIndex === 1) {
      return '#50D3A1';
    }
    if (colorIndex === 2) {
      return '#FF9966';
    }
    if (colorIndex === 3) {
      return '#E66D8F';
    }
    if (colorIndex === 4) {
      return '#8B7DFF';
    }
    return '#E1C67A';
  }

  private static getDayStart(timestamp: number): number {
    const date: Date = new Date(timestamp);
    return new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime();
  }

  private static getWeekStart(timestamp: number): number {
    const date: Date = new Date(timestamp);
    const day: number = date.getDay();
    const offset: number = day === 0 ? 6 : day - 1;
    return new Date(date.getFullYear(), date.getMonth(), date.getDate() - offset).getTime();
  }

  private static formatMonthDayText(timestamp: number): string {
    const date: Date = new Date(timestamp);
    return `${ReportDataHelper.padNumber(date.getMonth() + 1)}-${ReportDataHelper.padNumber(date.getDate())}`;
  }

  private static buildMonthKey(timestamp: number): string {
    const date: Date = new Date(timestamp);
    return `${date.getFullYear()}-${ReportDataHelper.padNumber(date.getMonth() + 1)}`;
  }

  private static formatMonthText(timestamp: number): string {
    const date: Date = new Date(timestamp);
    return `${date.getFullYear()}年${ReportDataHelper.padNumber(date.getMonth() + 1)}月`;
  }

  private static padNumber(value: number): string {
    return value.toString().padStart(2, '0');
  }
}
