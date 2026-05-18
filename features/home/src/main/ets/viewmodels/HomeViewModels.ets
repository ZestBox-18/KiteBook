/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页视图模型
 */

import { BillBean, BillGroup } from 'base';

export class AssetAccountBean {
  name: string = '';
  subtitle: string = '';
  amount: number = 0;
  icon: Resource = $r('sys.symbol.creditcard');
  isLiability: boolean = false;

  /**
   * 构建一个首页资产账户展示对象。
   */
  constructor(name: string, subtitle: string, amount: number, icon: Resource, isLiability: boolean) {
    this.name = name;
    this.subtitle = subtitle;
    this.amount = amount;
    this.icon = icon;
    this.isLiability = isLiability;
  }
}

export enum BillSortTypeEnum {
  DATE_DESC = 'date_desc',
  DAY_TOTAL_DESC = 'day_total_desc',
  AMOUNT_DESC = 'amount_desc'
}

export class HomeHeaderState {
  title: string = '本周账单';
  action: string = '按日总额排序';
}

export class HomeMonthlySummary {
  currentMonthText: string = '';
  monthlyExpense: number = 0;
  monthlyIncome: number = 0;
  monthlyBalance: number = 0;
  budgetRemaining: number = 0;
  remainingDaysOfMonth: number = 1;
  dailyBudgetRemaining: number = 0;
  budgetProgressValue: number = 0;
  budgetUsagePercent: number = 0;
}

export class HomeAssetSummary {
  totalAssets: number = 0;
  totalLiabilities: number = 0;
  netAssets: number = 0;
}

export class HomeWeeklyDisplayState {
  sortedWeekBills: BillBean[] = [];
  sortedWeekBillGroups: BillGroup[] = [];
  billSortModeText: string = '按时间倒序';
}
