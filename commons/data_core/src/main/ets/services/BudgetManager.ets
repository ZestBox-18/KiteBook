/**
 * Copyright (C), 2026-05-25
 * @author ZestBox
 * @date 2026/05/25
 * @version 1.0
 * @description: 预算数据库操作管理类
 */

import { dbManager, resultSet2Record, Clog } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { BudgetBean, SyncStatusEnum } from 'base';

const TAG: string = '[BudgetManager]';
const TABLE_NAME: string = 'budgets';

export class BudgetManager {
  private static createLocalUuid(): string {
    return `budget-${Date.now()}-${Math.floor(Math.random() * 1000000)}`;
  }

  /**
   * 将查询结果行转换为预算实体。
   */
  private static mapRowsToBudgets(rows: Record<string, object>[]): BudgetBean[] {
    return rows.map((row: Record<string, object>) => {
      const budget: BudgetBean = new BudgetBean();
      budget.id = Number(row['id']);
      budget.uuid = String(row['uuid'] ?? '');
      budget.remoteId = String(row['remote_id'] ?? '');
      budget.ledgerId = Number(row['ledger_id'] ?? 1);
      budget.category = String(row['category']);
      budget.amount = Number(row['amount']);
      budget.month = String(row['month']);
      budget.syncStatus = String(row['sync_status'] ?? SyncStatusEnum.PENDING);
      budget.syncVersion = Number(row['sync_version'] ?? 0);
      budget.deletedAt = Number(row['deleted_at'] ?? 0);
      budget.createdAt = Number(row['created_at']);
      budget.updatedAt = Number(row['updated_at']);
      return budget;
    });
  }

  /**
   * 将时间戳转换为预算表使用的月份主键。
   */
  static buildMonthKey(timestamp: number): string {
    const date: Date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}`;
  }

  /**
   * 查询指定月份的预算列表。
   */
  static async getBudgetsByMonth(month: string): Promise<BudgetBean[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('month', month);
    predicates.equalTo('deleted_at', 0);
    predicates.orderByAsc('id');

    return new Promise<BudgetBean[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          resolve(BudgetManager.mapRowsToBudgets(rows));
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询预算失败, code=${err.code}, msg=${err.message}`);
          reject([]);
        });
    });
  }

  /**
   * 查询全部预算记录，供导出等场景复用。
   */
  static async getAllBudgets(): Promise<BudgetBean[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('deleted_at', 0);
    predicates.orderByAsc('month');
    predicates.orderByAsc('id');

    return new Promise<BudgetBean[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          resolve(BudgetManager.mapRowsToBudgets(rows));
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询全部预算失败, code=${err.code}, msg=${err.message}`);
          reject([]);
        });
    });
  }

  /**
   * 查询指定月份某个分类的预算。
   */
  static async getBudgetByCategory(month: string, category: string): Promise<BudgetBean | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('month', month);
    predicates.equalTo('category', category);
    predicates.equalTo('deleted_at', 0);

    return new Promise<BudgetBean | null>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          if (rows.length === 0) {
            resolve(null);
            return;
          }
          const budgets: BudgetBean[] = BudgetManager.mapRowsToBudgets(rows);
          resolve(budgets[0]);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询分类预算失败, code=${err.code}, msg=${err.message}`);
          reject(null);
        });
    });
  }

  /**
   * 返回指定月份的总预算额度。
   */
  static async getMonthBudgetTotal(monthTimestamp: number): Promise<number> {
    const budgets: BudgetBean[] = await BudgetManager.getBudgetsByMonth(BudgetManager.buildMonthKey(monthTimestamp));
    let totalAmount: number = 0;
    budgets.forEach((item: BudgetBean) => {
      totalAmount += item.amount;
    });
    return totalAmount;
  }

  /**
   * 保存某个分类的预算，存在则更新，不存在则新增；传入 0 或负数时删除预算。
   */
  static async saveBudget(category: string, amount: number, month: string): Promise<void> {
    const existingBudget: BudgetBean | null = await BudgetManager.getBudgetByCategory(month, category);
    if (amount <= 0) {
      if (existingBudget !== null) {
        await BudgetManager.deleteBudget(existingBudget.id);
      }
      return;
    }

    if (existingBudget === null) {
      await BudgetManager.addBudget(category, amount, month);
      return;
    }

    await BudgetManager.updateBudget(existingBudget.id, amount);
  }

  /**
   * 新增预算记录。
   */
  private static async addBudget(category: string, amount: number, month: string): Promise<number> {
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      uuid: BudgetManager.createLocalUuid(),
      remote_id: '',
      ledger_id: 1,
      category: category,
      amount: amount,
      month: month,
      sync_status: SyncStatusEnum.PENDING,
      sync_version: 0,
      deleted_at: 0,
      created_at: now,
      updated_at: now
    };

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.insert(TABLE_NAME, data)
        .then((id: number) => {
          resolve(id);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 新增预算失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 更新预算金额。
   */
  private static async updateBudget(id: number, amount: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    const data: relationalStore.ValuesBucket = {
      amount: amount,
      sync_status: SyncStatusEnum.PENDING,
      updated_at: Date.now()
    };

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then((num: number) => {
          resolve(num);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 更新预算失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 删除预算记录。
   */
  private static async deleteBudget(id: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      deleted_at: now,
      updated_at: now,
      sync_status: SyncStatusEnum.PENDING
    };

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then((num: number) => {
          resolve(num);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 删除预算失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }
}
