/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 首页数据处理工具
 */

import { BillItem } from '../entities/BillItem';
import { BudgetItem } from '../entities/BudgetItem';
import { AccountItem } from '../entities/AccountItem';
import { dbManager, Clog } from 'kite_utils';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[HomeDataHelper]';

/**
 * 计算本月收入
 */
export function calculateMonthIncome(bills: BillItem[]): number {
  let income = 0;
  for (const bill of bills) {
    if (bill.type === 'income') {
      income += bill.amount;
    }
  }
  return income;
}

/**
 * 计算本月支出
 */
export function calculateMonthExpense(bills: BillItem[]): number {
  let expense = 0;
  for (const bill of bills) {
    if (bill.type === 'expense') {
      expense += bill.amount;
    }
  }
  return expense;
}

/**
 * 计算本月结余
 */
export function calculateMonthBalance(income: number, expense: number): number {
  return income - expense;
}

/**
 * 格式化金额（保留两位小数，千分位分隔）
 */
export function formatAmount(amount: number): string {
  const fixed = amount.toFixed(2);
  const parts = fixed.split('.');
  const intPart = parts[0];
  const decPart = parts[1];
  
  // 添加千分位分隔符
  let formatted = '';
  let count = 0;
  for (let i = intPart.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 === 0) {
      formatted = ',' + formatted;
    }
    formatted = intPart[i] + formatted;
    count++;
  }
  
  return formatted + '.' + decPart;
}

/**
 * 查询本月账单
 */
export async function queryBillsByMonth(month: string): Promise<BillItem[]> {
  try {
    const startDate = new Date(month + '-01').getTime();
    const endDate = new Date(month + '-31').getTime();
    
    const sql = `SELECT * FROM bills WHERE date >= ${startDate} AND date <= ${endDate} ORDER BY date DESC`;
    const result = await dbManager.dbStore?.querySql(sql, []);
    
    const bills: BillItem[] = [];
    // 解析查询结果（具体实现根据 dbManager API）
    // ...
    
    return bills;
  } catch (error) {
    const err = error as BusinessError;
    Clog.error(TAG, '查询账单失败', err);
    return [];
  }
}

/**
 * 查询本月预算
 */
export async function queryBudgetsByMonth(month: string): Promise<BudgetItem[]> {
  try {
    const sql = `SELECT * FROM budgets WHERE month = '${month}'`;
    const result = await dbManager.dbStore?.querySql(sql, []);
    
    const budgets: BudgetItem[] = [];
    // 解析查询结果
    // ...
    
    return budgets;
  } catch (error) {
    const err = error as BusinessError;
    Clog.error(TAG, '查询预算失败', err);
    return [];
  }
}

/**
 * 查询账户余额
 */
export async function queryAccounts(): Promise<AccountItem[]> {
  try {
    const sql = 'SELECT * FROM accounts';
    const result = await dbManager.dbStore?.querySql(sql, []);
    
    const accounts: AccountItem[] = [];
    // 解析查询结果
    // ...
    
    return accounts;
  } catch (error) {
    const err = error as BusinessError;
    Clog.error(TAG, '查询账户失败', err);
    return [];
  }
}

/**
 * 计算预算进度
 */
export function calculateBudgetProgress(
  budget: BudgetItem,
  bills: BillItem[]
): BudgetItem {
  let usedAmount = 0;
  for (const bill of bills) {
    if (bill.category === budget.category && bill.type === 'expense') {
      usedAmount += bill.amount;
    }
  }
  
  budget.usedAmount = usedAmount;
  budget.progress = budget.budgetAmount > 0 ? usedAmount / budget.budgetAmount : 0;
  
  return budget;
}
