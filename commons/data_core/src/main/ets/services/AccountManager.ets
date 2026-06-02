/**
 * Copyright (C), 2026-05-21
 * @author ZestBox
 * @date 2026/05/21
 * @version 1.0
 * @description: 账户数据库操作管理类
 */

import { dbManager, resultSet2Record, Clog } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { AccountBean, AccountTypeEnum } from 'base';

const TAG: string = '[AccountManager]';
const TABLE_NAME: string = 'accounts';
const BILL_TABLE_NAME: string = 'bills';

class AccountSeed {
  name: string = '';
  balance: number = 0;
  type: string = AccountTypeEnum.ASSET;
  icon: string = 'creditcard';

  constructor(name: string, balance: number, type: string, icon: string) {
    this.name = name;
    this.balance = balance;
    this.type = type;
    this.icon = icon;
  }
}

/**
 * 账户数据库操作管理类，统一处理默认账户和账户查询。
 */
export class AccountManager {
  /**
   * 构建默认账户列表，供空库时回填基础数据。
   */
  private static buildDefaultAccounts(): AccountBean[] {
    const seeds: AccountSeed[] = [
      new AccountSeed('支付宝', 8650.35, AccountTypeEnum.ASSET, 'creditcard'),
      new AccountSeed('微信', 3268.50, AccountTypeEnum.ASSET, 'house'),
      new AccountSeed('银行卡', 42180.00, AccountTypeEnum.ASSET, 'creditcard'),
      new AccountSeed('花呗', 2580.00, AccountTypeEnum.LIABILITY, 'arrow_up_circle')
    ];
    const accounts: AccountBean[] = [];
    seeds.forEach((item: AccountSeed) => {
      const account: AccountBean = new AccountBean();
      account.name = item.name;
      account.balance = item.balance;
      account.type = item.type;
      account.icon = item.icon;
      accounts.push(account);
    });
    return accounts;
  }

  /**
   * 查询全部账户列表，按主键稳定输出。
   */
  static async getAccounts(): Promise<AccountBean[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByAsc('id');

    return new Promise<AccountBean[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          const accounts: AccountBean[] = rows.map((row: Record<string, object>) => {
            const account: AccountBean = new AccountBean();
            account.id = Number(row['id']);
            account.name = String(row['name']);
            account.balance = Number(row['balance']);
            account.type = String(row['type']);
            account.icon = String(row['icon'] ?? 'creditcard');
            account.createdAt = Number(row['created_at']);
            account.updatedAt = Number(row['updated_at']);
            return account;
          });
          Clog.info(TAG, `查询账户成功: count=${accounts.length}`);
          resolve(accounts);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询账户失败, code=${err.code}, msg=${err.message}`);
          reject([]);
        });
    });
  }

  /**
   * 按账户名称查询单个账户，供账单记账时同步更新余额。
   */
  static async getAccountByName(name: string): Promise<AccountBean | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('name', name);

    return new Promise<AccountBean | null>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          if (rows.length === 0) {
            resolve(null);
            return;
          }
          const row: Record<string, object> = rows[0];
          const account: AccountBean = new AccountBean();
          account.id = Number(row['id']);
          account.name = String(row['name']);
          account.balance = Number(row['balance']);
          account.type = String(row['type']);
          account.icon = String(row['icon'] ?? 'creditcard');
          account.createdAt = Number(row['created_at']);
          account.updatedAt = Number(row['updated_at']);
          resolve(account);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询账户失败, code=${err.code}, msg=${err.message}`);
          reject(null);
        });
    });
  }

  /**
   * 按主键查询账户详情，供编辑和删除前校验使用。
   */
  static async getAccountById(id: number): Promise<AccountBean | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);

    return new Promise<AccountBean | null>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          if (rows.length === 0) {
            resolve(null);
            return;
          }
          const row: Record<string, object> = rows[0];
          const account: AccountBean = new AccountBean();
          account.id = Number(row['id']);
          account.name = String(row['name']);
          account.balance = Number(row['balance']);
          account.type = String(row['type']);
          account.icon = String(row['icon'] ?? 'creditcard');
          account.createdAt = Number(row['created_at']);
          account.updatedAt = Number(row['updated_at']);
          resolve(account);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询账户详情失败, code=${err.code}, msg=${err.message}`);
          reject(null);
        });
    });
  }

  /**
   * 按名称增量更新账户余额，供账单增删改时复用。
   */
  static async updateAccountBalanceByName(name: string, delta: number): Promise<boolean> {
    if (delta === 0) {
      return true;
    }
    const account: AccountBean | null = await AccountManager.getAccountByName(name);
    if (account === null) {
      Clog.warn(TAG, `账户不存在，跳过余额更新: ${name}`);
      return false;
    }

    const nextBalance: number = account.balance + delta;
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', account.id);
    const data: relationalStore.ValuesBucket = {
      balance: nextBalance,
      updated_at: Date.now()
    };

    return new Promise<boolean>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then((num: number) => {
          resolve(num > 0);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 更新账户余额失败, code=${err.code}, msg=${err.message}`);
          reject(false);
        });
    });
  }

  /**
   * 更新账户基础信息；当账户名称变更时，同步历史账单中的来源与目标账户名称。
   */
  static async updateAccount(
    id: number,
    name: string,
    balance: number,
    type: string,
    icon: string
  ): Promise<number> {
    const originalAccount: AccountBean | null = await AccountManager.getAccountById(id);
    if (originalAccount === null) {
      return -1;
    }

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    const data: relationalStore.ValuesBucket = {
      name: name,
      balance: balance,
      type: type,
      icon: icon,
      updated_at: Date.now()
    };

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then(async (num: number) => {
          if (num <= 0) {
            reject(-1);
            return;
          }
          if (originalAccount.name !== name) {
            await AccountManager.renameBillsForSourceAccount(originalAccount.name, name);
            await AccountManager.renameBillsForTargetAccount(originalAccount.name, name);
          }
          resolve(num);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 更新账户失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 判断账户是否已被任意账单引用，用于删除前保护。
   */
  static async hasReferencedBills(name: string): Promise<boolean> {
    const sourceMatched: boolean = await AccountManager.hasBillReferenceByColumn('account', name);
    if (sourceMatched) {
      return true;
    }
    return AccountManager.hasBillReferenceByColumn('target_account', name);
  }

  /**
   * 删除账户；仅在没有账单引用时允许删除。
   */
  static async deleteAccount(id: number): Promise<number> {
    const account: AccountBean | null = await AccountManager.getAccountById(id);
    if (account === null) {
      return -1;
    }
    const hasReferencedBills: boolean = await AccountManager.hasReferencedBills(account.name);
    if (hasReferencedBills) {
      return -2;
    }

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.delete(predicates)
        .then((num: number) => {
          resolve(num);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 删除账户失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 新增账户记录，供资产管理页创建用户自定义账户。
   */
  static async addAccount(name: string, balance: number, type: string, icon: string): Promise<number> {
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      name: name,
      balance: balance,
      type: type,
      icon: icon,
      created_at: now,
      updated_at: now
    };

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.insert(TABLE_NAME, data)
        .then((id: number) => {
          if (id === -1) {
            reject(-1);
          } else {
            resolve(id);
          }
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 新增账户失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 当账户表为空时回填默认账户，避免首页和记账页没有可用账户。
   */
  static async ensureDefaultAccounts(): Promise<void> {
    const accounts: AccountBean[] = await AccountManager.getAccounts();
    if (accounts.length > 0) {
      return;
    }
    const defaults: AccountBean[] = AccountManager.buildDefaultAccounts();
    for (const account of defaults) {
      await AccountManager.addSeedAccount(account);
    }
    Clog.info(TAG, `默认账户初始化完成: count=${defaults.length}`);
  }

  /**
   * 写入默认账户数据，供空表初始化时复用。
   */
  private static async addSeedAccount(account: AccountBean): Promise<void> {
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      name: account.name,
      balance: account.balance,
      type: account.type,
      icon: account.icon,
      created_at: now,
      updated_at: now
    };

    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.insert(TABLE_NAME, data)
        .then((id: number) => {
          if (id === -1) {
            reject(-1);
          } else {
            resolve();
          }
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 写入默认账户失败, code=${err.code}, msg=${err.message}`);
          reject(err);
        });
    });
  }

  /**
   * 判断账单表的指定列中是否存在对账户名称的引用。
   */
  private static async hasBillReferenceByColumn(columnName: string, name: string): Promise<boolean> {
    const predicates = new relationalStore.RdbPredicates(BILL_TABLE_NAME);
    predicates.equalTo(columnName, name);

    return new Promise<boolean>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          resolve(rows.length > 0);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询账户引用失败, code=${err.code}, msg=${err.message}`);
          reject(false);
        });
    });
  }

  /**
   * 账户改名后同步账单来源账户字段。
   */
  private static async renameBillsForSourceAccount(originalName: string, nextName: string): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(BILL_TABLE_NAME);
    predicates.equalTo('account', originalName);
    const data: relationalStore.ValuesBucket = {
      account: nextName,
      updated_at: Date.now()
    };

    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then(() => {
          resolve();
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 同步来源账户名称失败, code=${err.code}, msg=${err.message}`);
          reject(err);
        });
    });
  }

  /**
   * 账户改名后同步账单目标账户字段。
   */
  private static async renameBillsForTargetAccount(originalName: string, nextName: string): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(BILL_TABLE_NAME);
    predicates.equalTo('target_account', originalName);
    const data: relationalStore.ValuesBucket = {
      target_account: nextName,
      updated_at: Date.now()
    };

    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then(() => {
          resolve();
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 同步目标账户名称失败, code=${err.code}, msg=${err.message}`);
          reject(err);
        });
    });
  }
}
