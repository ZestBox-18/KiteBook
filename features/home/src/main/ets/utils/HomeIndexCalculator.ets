/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页页面数据计算工具
 */

import { BillBean, BillGroup } from 'base';
import { AssetAccountBean, BillSortTypeEnum, HomeAssetSummary, HomeMonthlySummary, HomeWeeklyDisplayState } from '../viewmodels/HomeViewModels';

export class HomeIndexCalculator {
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
   * 生成首页最近账单列表的排序结果。
   */
  static buildWeeklyDisplayState(weekBillGroups: BillGroup[], billSortType: BillSortTypeEnum): HomeWeeklyDisplayState {
    const displayState: HomeWeeklyDisplayState = new HomeWeeklyDisplayState();
    displayState.sortedWeekBills = HomeIndexCalculator.buildSortedWeekBills(weekBillGroups, billSortType);
    return displayState;
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
