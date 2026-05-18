/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页页面数据计算工具
 */

import { BillBean, BillGroup } from 'base';
import {
  AssetAccountBean,
  BillSortTypeEnum,
  HomeAssetSummary,
  HomeHeaderState,
  HomeMonthlySummary,
  HomeWeeklyDisplayState
} from '../viewmodels/HomeViewModels';

export class HomeIndexCalculator {
  /**
   * 根据当前卡片索引和排序模式生成列表区头部文案。
   */
  static buildHeaderState(swiperIndex: number, billSortType: BillSortTypeEnum): HomeHeaderState {
    const headerState: HomeHeaderState = new HomeHeaderState();
    headerState.title = swiperIndex === 2 ? '资产账户' : '本周账单';
    if (swiperIndex === 2) {
      headerState.action = '管理资产';
      return headerState;
    }
    if (billSortType === BillSortTypeEnum.DATE_DESC) {
      headerState.action = '按日总额排序';
      return headerState;
    }
    if (billSortType === BillSortTypeEnum.DAY_TOTAL_DESC) {
      headerState.action = '按金额排序';
      return headerState;
    }
    headerState.action = '按时间排序';
    return headerState;
  }

  /**
   * 返回首页账单列表下一个排序模式。
   */
  static getNextBillSortType(billSortType: BillSortTypeEnum): BillSortTypeEnum {
    if (billSortType === BillSortTypeEnum.DATE_DESC) {
      return BillSortTypeEnum.DAY_TOTAL_DESC;
    }
    if (billSortType === BillSortTypeEnum.DAY_TOTAL_DESC) {
      return BillSortTypeEnum.AMOUNT_DESC;
    }
    return BillSortTypeEnum.DATE_DESC;
  }

  /**
   * 计算首页预算卡和收支卡所需的月度摘要数据。
   */
  static buildMonthlySummary(monthBillGroups: BillGroup[], defaultMonthBudget: number): HomeMonthlySummary {
    const summary: HomeMonthlySummary = new HomeMonthlySummary();
    summary.currentMonthText = HomeIndexCalculator.getCurrentMonthText();

    let totalExpense: number = 0;
    let totalIncome: number = 0;
    monthBillGroups.forEach((group: BillGroup) => {
      totalExpense += group.totalExpense;
      totalIncome += group.totalIncome;
    });

    summary.monthlyExpense = totalExpense;
    summary.monthlyIncome = totalIncome;
    summary.monthlyBalance = totalIncome - totalExpense;
    summary.remainingDaysOfMonth = HomeIndexCalculator.getRemainingDaysOfMonth();
    const remaining: number = defaultMonthBudget - totalExpense;
    summary.budgetRemaining = remaining > 0 ? remaining : 0;
    summary.dailyBudgetRemaining = summary.budgetRemaining / summary.remainingDaysOfMonth;
    summary.budgetProgressValue = totalExpense > defaultMonthBudget ? defaultMonthBudget : totalExpense;
    summary.budgetUsagePercent = defaultMonthBudget <= 0 ? 0 :
      Math.min(100, summary.budgetProgressValue / defaultMonthBudget * 100);
    return summary;
  }

  /**
   * 汇总资产账户列表，得到总资产、总负债和净资产。
   */
  static buildAssetSummary(assetAccounts: AssetAccountBean[]): HomeAssetSummary {
    const summary: HomeAssetSummary = new HomeAssetSummary();
    assetAccounts.forEach((item: AssetAccountBean) => {
      if (item.isLiability) {
        summary.totalLiabilities += item.amount;
      } else {
        summary.totalAssets += item.amount;
      }
    });
    summary.netAssets = summary.totalAssets - summary.totalLiabilities;
    return summary;
  }

  /**
   * 生成周账单列表的排序结果与排序说明。
   */
  static buildWeeklyDisplayState(weekBillGroups: BillGroup[], billSortType: BillSortTypeEnum): HomeWeeklyDisplayState {
    const displayState: HomeWeeklyDisplayState = new HomeWeeklyDisplayState();
    displayState.sortedWeekBills = HomeIndexCalculator.buildSortedWeekBills(weekBillGroups, billSortType);
    displayState.sortedWeekBillGroups = HomeIndexCalculator.buildSortedWeekBillGroups(weekBillGroups, billSortType);
    displayState.billSortModeText = HomeIndexCalculator.getBillSortModeText(billSortType);
    return displayState;
  }

  /**
   * 将日期转换成首页使用的“今天/昨天/日期”文案。
   */
  static formatDateTitle(dateStr: string): string {
    const today = new Date();
    const todayStr =
      `${today.getFullYear()}-${(today.getMonth() + 1).toString().padStart(2, '0')}-${today.getDate()
        .toString()
        .padStart(2, '0')}`;
    if (dateStr === todayStr) {
      return '今天';
    }
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const yesterdayStr =
      `${yesterday.getFullYear()}-${(yesterday.getMonth() + 1).toString().padStart(2, '0')}-${yesterday.getDate()
        .toString()
        .padStart(2, '0')}`;
    if (dateStr === yesterdayStr) {
      return '昨天';
    }
    return dateStr;
  }

  /**
   * 计算账单分组头部展示的当日总流水。
   */
  static getGroupTurnover(group: BillGroup): number {
    return group.totalIncome + group.totalExpense;
  }

  /**
   * 将金额格式化为两位小数和千分位形式。
   */
  static formatAmount(amount: number): string {
    const fixedAmount: string = amount.toFixed(2);
    const amountParts: string[] = fixedAmount.split('.');
    let integerPart: string = amountParts[0];
    const decimalPart: string = amountParts[1];
    const resultParts: string[] = [];

    while (integerPart.length > 3) {
      resultParts.unshift(integerPart.slice(integerPart.length - 3));
      integerPart = integerPart.slice(0, integerPart.length - 3);
    }
    resultParts.unshift(integerPart);
    return `${resultParts.join(',')}.${decimalPart}`;
  }

  /**
   * 将周账单拍平成单列表，并按当前模式排序。
   */
  private static buildSortedWeekBills(weekBillGroups: BillGroup[], billSortType: BillSortTypeEnum): BillBean[] {
    const billList: BillBean[] = [];
    weekBillGroups.forEach((group: BillGroup) => {
      group.bills.forEach((bill: BillBean) => {
        billList.push(bill);
      });
    });

    if (billSortType === BillSortTypeEnum.AMOUNT_DESC) {
      billList.sort((first: BillBean, second: BillBean) => second.amount - first.amount);
      return billList;
    }

    billList.sort((first: BillBean, second: BillBean) => second.date - first.date);
    return billList;
  }

  /**
   * 复制并排序账单分组，避免直接修改原始分组数组。
   */
  private static buildSortedWeekBillGroups(weekBillGroups: BillGroup[], billSortType: BillSortTypeEnum): BillGroup[] {
    const groupList: BillGroup[] = [];
    weekBillGroups.forEach((group: BillGroup) => {
      groupList.push(group);
    });

    if (billSortType === BillSortTypeEnum.DAY_TOTAL_DESC) {
      groupList.sort((first: BillGroup, second: BillGroup) =>
        HomeIndexCalculator.getGroupTurnover(second) - HomeIndexCalculator.getGroupTurnover(first));
      return groupList;
    }

    groupList.sort((first: BillGroup, second: BillGroup) => second.dateTimestamp - first.dateTimestamp);
    return groupList;
  }

  /**
   * 生成列表头部使用的排序说明文本。
   */
  private static getBillSortModeText(billSortType: BillSortTypeEnum): string {
    if (billSortType === BillSortTypeEnum.DATE_DESC) {
      return '按时间倒序';
    }
    if (billSortType === BillSortTypeEnum.DAY_TOTAL_DESC) {
      return '按日总额从高到低';
    }
    return '按金额从高到低';
  }

  /**
   * 生成当前月份文案，例如“5月”。
   */
  private static getCurrentMonthText(): string {
    const now = new Date();
    return `${now.getMonth() + 1}月`;
  }

  /**
   * 计算本月剩余天数，用于预算卡展示。
   */
  private static getRemainingDaysOfMonth(): number {
    const now = new Date();
    const lastDay: number = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
    const remainingDays: number = lastDay - now.getDate() + 1;
    return remainingDays > 0 ? remainingDays : 1;
  }
}
