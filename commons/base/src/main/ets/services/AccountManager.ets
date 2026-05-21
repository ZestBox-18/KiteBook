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
import { AccountBean, AccountTypeEnum } from '../entities/AccountBean';

const TAG: string = '[AccountManager]';
const TABLE_NAME: string = 'accounts';

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
}
