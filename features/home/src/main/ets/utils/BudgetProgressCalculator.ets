/**
 * Copyright (C), 2026-07-10
 * @author ZestBox
 * @date 2026/07/10
 * @version 1.0
 * @description: 月度预算进度客观指标计算器
 */

export class BudgetProgressSummary {
  usagePercent: number = 0;
  timeProgressPercent: number = 0;
  progressDifference: number = 0;
  remainingAmount: number = 0;
  remainingDays: number = 0;
  dailyAvailableAmount: number = 0;
}

export class BudgetProgressCalculator {
  static build(monthAnchor: number, totalBudget: number, totalUsed: number, nowTimestamp: number): BudgetProgressSummary {
    const summary: BudgetProgressSummary = new BudgetProgressSummary();
    const monthDate: Date = new Date(monthAnchor);
    const now: Date = new Date(nowTimestamp);
    const daysInMonth: number = new Date(monthDate.getFullYear(), monthDate.getMonth() + 1, 0).getDate();
    const monthStart: number = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1).getTime();
    const nextMonthStart: number = new Date(monthDate.getFullYear(), monthDate.getMonth() + 1, 1).getTime();

    let elapsedDays: number = 0;
    if (nowTimestamp >= nextMonthStart) {
      elapsedDays = daysInMonth;
    } else if (nowTimestamp >= monthStart) {
      elapsedDays = now.getDate();
    }

    summary.usagePercent = totalBudget > 0 ? totalUsed / totalBudget * 100 : 0;
    summary.timeProgressPercent = elapsedDays / daysInMonth * 100;
    summary.progressDifference = summary.usagePercent - summary.timeProgressPercent;
    summary.remainingAmount = Math.max(0, totalBudget - totalUsed);
    summary.remainingDays = elapsedDays > 0 && elapsedDays < daysInMonth ? daysInMonth - elapsedDays + 1 : 0;
    summary.dailyAvailableAmount = summary.remainingDays > 0 ? summary.remainingAmount / summary.remainingDays : 0;
    return summary;
  }

  static getCategoryUsagePercent(budgetAmount: number, usedAmount: number): number {
    return budgetAmount > 0 ? usedAmount / budgetAmount * 100 : 0;
  }
}
