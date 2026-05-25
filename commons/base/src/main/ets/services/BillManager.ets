/**
 * Copyright (C), 2025-05-13
 * @author ZestBox
 * @date 2025/05/13
 * @version 1.0
 * @description: 账单数据库操作管理类
 */

import { dbManager, resultSet2Record, Clog } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { BillBean, BillGroup, BillTypeEnum } from '../entities/BillBean';
import { AccountManager } from './AccountManager';
import { AccountBean, AccountTypeEnum } from '../entities/AccountBean';

const TAG: string = '[BillManager]';
const TABLE_NAME: string = 'bills';

export class BillManager {
  /**
   * 将查询结果行映射为账单实体，避免不同查询重复手写转换逻辑。
   */
  private static mapRowsToBills(rows: Record<string, object>[]): BillBean[] {
    return rows.map((row: Record<string, object>) => {
      const bill: BillBean = new BillBean();
      bill.id = Number(row['id']);
      bill.type = String(row['type']);
      bill.category = String(row['category']);
      bill.amount = Number(row['amount']);
      bill.account = String(row['account']);
      bill.date = Number(row['date']);
      bill.remark = String(row['remark'] ?? '');
      bill.createdAt = Number(row['created_at']);
      bill.updatedAt = Number(row['updated_at']);
      return bill;
    });
  }

  /**
   * 根据账单和账户类型计算余额变动值。
   */
  private static async calculateAccountBalanceDelta(bill: BillBean): Promise<number> {
    const account: AccountBean | null = await AccountManager.getAccountByName(bill.account);
    if (account === null) {
      return 0;
    }
    if (account.type === AccountTypeEnum.LIABILITY) {
      return bill.type === BillTypeEnum.INCOME ? -bill.amount : bill.amount;
    }
    return bill.type === BillTypeEnum.INCOME ? bill.amount : -bill.amount;
  }

  /**
   * 将账单影响同步到账户余额，正负方向由账单类型和账户类型共同决定。
   */
  private static async applyBillToAccountBalance(bill: BillBean, reverse: boolean = false): Promise<void> {
    const delta: number = await BillManager.calculateAccountBalanceDelta(bill);
    if (delta === 0) {
      return;
    }
    const balanceDelta: number = reverse ? -delta : delta;
    await AccountManager.updateAccountBalanceByName(bill.account, balanceDelta);
  }

  /**
   * 查询单条账单明细，供更新和删除前恢复账户余额使用。
   */
  static async getBillById(id: number): Promise<BillBean | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);

    return new Promise<BillBean | null>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          if (rows.length === 0) {
            resolve(null);
            return;
          }
          const bills: BillBean[] = BillManager.mapRowsToBills(rows);
          resolve(bills[0]);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询账单详情失败, code=${err.code}, msg=${err.message}`);
          reject(null);
        });
    });
  }

  /**
   * 合并旧账单和补丁，得到更新后的完整账单数据。
   */
  private static buildUpdatedBill(originalBill: BillBean, patch: Partial<BillBean>): BillBean {
    const nextBill: BillBean = new BillBean();
    nextBill.id = originalBill.id;
    nextBill.type = patch.type !== undefined ? patch.type : originalBill.type;
    nextBill.category = patch.category !== undefined ? patch.category : originalBill.category;
    nextBill.amount = patch.amount !== undefined ? patch.amount : originalBill.amount;
    nextBill.account = patch.account !== undefined ? patch.account : originalBill.account;
    nextBill.date = patch.date !== undefined ? patch.date : originalBill.date;
    nextBill.remark = patch.remark !== undefined ? patch.remark : originalBill.remark;
    nextBill.createdAt = originalBill.createdAt;
    nextBill.updatedAt = Date.now();
    return nextBill;
  }

  /**
   * 添加账单
   * @param bill 账单数据
   * @returns 新增记录的ID，失败返回-1
   */
  static async addBill(bill: BillBean): Promise<number> {
    const now = Date.now();
    const data: relationalStore.ValuesBucket = {
      type: bill.type,
      category: bill.category,
      amount: bill.amount,
      account: bill.account,
      date: bill.date,
      remark: bill.remark,
      created_at: now,
      updated_at: now
    };

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.insert(TABLE_NAME, data)
        .then(async (id: number) => {
          if (id === -1) {
            reject(-1);
          } else {
            await BillManager.applyBillToAccountBalance(bill);
            resolve(id);
          }
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 添加账单失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 删除账单
   * @param id 账单ID
   * @returns 删除的记录数
   */
  static async deleteBill(id: number): Promise<number> {
    const existingBill: BillBean | null = await BillManager.getBillById(id);
    if (existingBill === null) {
      return -1;
    }
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.delete(predicates)
        .then(async (num: number) => {
          if (num === -1) {
            reject(-1);
          } else {
            await BillManager.applyBillToAccountBalance(existingBill, true);
            resolve(num);
          }
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 删除账单失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 更新账单
   * @param id 账单ID
   * @param patch 更新数据
   * @returns 更新的记录数
   */
  static async updateBill(id: number, patch: Partial<BillBean>): Promise<number> {
    const originalBill: BillBean | null = await BillManager.getBillById(id);
    if (originalBill === null) {
      return -1;
    }
    const updatedBill: BillBean = BillManager.buildUpdatedBill(originalBill, patch);
    const data: relationalStore.ValuesBucket = {
      updated_at: Date.now()
    };
    if (patch.type !== undefined) {
      data.type = patch.type;
    }
    if (patch.category !== undefined) {
      data.category = patch.category;
    }
    if (patch.amount !== undefined) {
      data.amount = patch.amount;
    }
    if (patch.account !== undefined) {
      data.account = patch.account;
    }
    if (patch.date !== undefined) {
      data.date = patch.date;
    }
    if (patch.remark !== undefined) {
      data.remark = patch.remark;
    }

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then(async (num: number) => {
          if (num === -1) {
            reject(-1);
          } else {
            await BillManager.applyBillToAccountBalance(originalBill, true);
            await BillManager.applyBillToAccountBalance(updatedBill);
            resolve(num);
          }
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 更新账单失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 查询最近N天的账单（按日期分组）
   * @param days 天数，默认3天
   * @returns 按日期分组的账单列表
   */
  static async getRecentBills(days: number = 3): Promise<BillGroup[]> {
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const startTime = now.getTime() - (days - 1) * 24 * 60 * 60 * 1000;

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.greaterThanOrEqualTo('date', startTime);
    predicates.orderByDesc('date');

    return new Promise<BillGroup[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          const bills: BillBean[] = BillManager.mapRowsToBills(rows);

          // 按日期分组
          const groups = BillManager.groupBillsByDate(bills);
          Clog.info(TAG, `查询最近账单成功: days=${days}, count=${bills.length}, groupCount=${groups.length}`);
          resolve(groups);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询最近账单失败, code=${err.code}, msg=${err.message}`);
          reject([]);
        });
    });
  }

  /**
   * 查询指定月份的账单，可按账单类型进一步过滤。
   */
  static async getBillsByMonth(monthTimestamp: number, type: string = ''): Promise<BillGroup[]> {
    const currentMonthDate: Date = new Date(monthTimestamp);
    const startDate: Date = new Date(currentMonthDate.getFullYear(), currentMonthDate.getMonth(), 1);
    const endDate: Date = new Date(currentMonthDate.getFullYear(), currentMonthDate.getMonth() + 1, 1);

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.greaterThanOrEqualTo('date', startDate.getTime());
    predicates.lessThan('date', endDate.getTime());
    if (type.length > 0) {
      predicates.equalTo('type', type);
    }
    predicates.orderByDesc('date');

    return new Promise<BillGroup[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          const bills: BillBean[] = BillManager.mapRowsToBills(rows);
          const groups: BillGroup[] = BillManager.groupBillsByDate(bills);
          const monthText: string =
            `${startDate.getFullYear()}-${(startDate.getMonth() + 1).toString().padStart(2, '0')}`;
          Clog.info(TAG,
            `查询月份账单成功: month=${monthText}, type=${type.length > 0 ? type : 'all'}, count=${bills.length}, groupCount=${groups.length}`);
          resolve(groups);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询月份账单失败, code=${err.code}, msg=${err.message}`);
          reject([]);
        });
    });
  }

  /**
   * 查询指定时间区间内的账单明细，供报表等需要原始流水的场景复用。
   */
  static async getBillsByRange(startTime: number, endTime: number, type: string = ''): Promise<BillBean[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.greaterThanOrEqualTo('date', startTime);
    predicates.lessThan('date', endTime);
    if (type.length > 0) {
      predicates.equalTo('type', type);
    }
    predicates.orderByAsc('date');

    return new Promise<BillBean[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          const bills: BillBean[] = BillManager.mapRowsToBills(rows);
          resolve(bills);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询区间账单失败, code=${err.code}, msg=${err.message}`);
          reject([]);
        });
    });
  }

  /**
   * 按日期分组账单
   * @param bills 账单列表
   * @returns 分组后的账单
   */
  static groupBillsByDate(bills: BillBean[]): BillGroup[] {
    const groupMap: Map<string, BillGroup> = new Map();

    for (const bill of bills) {
      const date = new Date(bill.date);
      const dateStr = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;

      let group = groupMap.get(dateStr);
      if (!group) {
        group = new BillGroup();
        group.date = dateStr;
        group.dateTimestamp = new Date(dateStr).getTime();
        group.totalExpense = 0;
        group.totalIncome = 0;
        group.bills = [];
        groupMap.set(dateStr, group);
      }

      group.bills.push(bill);
      if (bill.type === BillTypeEnum.EXPENSE) {
        group.totalExpense += bill.amount;
      } else {
        group.totalIncome += bill.amount;
      }
    }

    // 转换为数组并按日期降序排序
    const groups = Array.from(groupMap.values());
    groups.sort((a, b) => b.dateTimestamp - a.dateTimestamp);
    return groups;
  }

  /**
   * 插入示例数据
   */
  static async insertSampleData(): Promise<void> {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    // 创建示例账单
    const bill1 = new BillBean();
    bill1.type = BillTypeEnum.EXPENSE;
    bill1.category = '餐饮';
    bill1.amount = 35.00;
    bill1.account = '微信';
    bill1.date = today.getTime() + 12 * 60 * 60 * 1000;
    bill1.remark = '午餐';

    const bill2 = new BillBean();
    bill2.type = BillTypeEnum.EXPENSE;
    bill2.category = '交通';
    bill2.amount = 6.00;
    bill2.account = '支付宝';
    bill2.date = today.getTime() + 9 * 60 * 60 * 1000;
    bill2.remark = '地铁';

    const bill3 = new BillBean();
    bill3.type = BillTypeEnum.INCOME;
    bill3.category = '工资';
    bill3.amount = 15000.00;
    bill3.account = '银行卡';
    bill3.date = today.getTime() + 10 * 60 * 60 * 1000;
    bill3.remark = '5月工资';

    const bill4 = new BillBean();
    bill4.type = BillTypeEnum.EXPENSE;
    bill4.category = '购物';
    bill4.amount = 299.00;
    bill4.account = '支付宝';
    bill4.date = today.getTime() - 24 * 60 * 60 * 1000 + 15 * 60 * 60 * 1000;
    bill4.remark = '买衣服';

    const bill5 = new BillBean();
    bill5.type = BillTypeEnum.EXPENSE;
    bill5.category = '餐饮';
    bill5.amount = 88.00;
    bill5.account = '微信';
    bill5.date = today.getTime() - 24 * 60 * 60 * 1000 + 19 * 60 * 60 * 1000;
    bill5.remark = '晚餐聚餐';

    const bill6 = new BillBean();
    bill6.type = BillTypeEnum.EXPENSE;
    bill6.category = '娱乐';
    bill6.amount = 50.00;
    bill6.account = '微信';
    bill6.date = today.getTime() - 2 * 24 * 60 * 60 * 1000 + 20 * 60 * 60 * 1000;
    bill6.remark = '电影票';

    const bill7 = new BillBean();
    bill7.type = BillTypeEnum.EXPENSE;
    bill7.category = '餐饮';
    bill7.amount = 42.00;
    bill7.account = '支付宝';
    bill7.date = today.getTime() - 2 * 24 * 60 * 60 * 1000 + 12 * 60 * 60 * 1000;
    bill7.remark = '午餐外卖';

    const bill8 = new BillBean();
    bill8.type = BillTypeEnum.INCOME;
    bill8.category = '理财';
    bill8.amount = 128.50;
    bill8.account = '银行卡';
    bill8.date = today.getTime() - 2 * 24 * 60 * 60 * 1000 + 9 * 60 * 60 * 1000;
    bill8.remark = '基金收益';

    const sampleBills: BillBean[] = [bill1, bill2, bill3, bill4, bill5, bill6, bill7, bill8];

    for (const bill of sampleBills) {
      await BillManager.addBill(bill);
    }
    console.info(`${TAG} 示例数据插入完成`);
  }
}
