/**
 * Copyright (C), 2026-07-09
 * @author ZestBox
 * @date 2026/07/09
 * @version 1.0
 * @description: 账单分摊数据库操作管理类
 */

import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { BillSplitBean } from 'base';
import { dbManager, resultSet2Record, Clog } from 'kite_utils';

const TAG: string = '[BillSplitManager]';
const TABLE_NAME: string = 'bill_splits';

export class BillSplitManager {
  private static createLocalUuid(): string {
    return `split-${Date.now()}-${Math.floor(Math.random() * 1000000)}`;
  }

  private static mapRowToSplit(row: Record<string, object>): BillSplitBean {
    const split: BillSplitBean = new BillSplitBean();
    split.id = Number(row['id']);
    split.uuid = String(row['uuid'] ?? '');
    split.remoteId = String(row['remote_id'] ?? '');
    split.billId = Number(row['bill_id']);
    split.ledgerId = Number(row['ledger_id']);
    split.memberId = Number(row['member_id']);
    split.amount = Number(row['amount']);
    split.ratio = Number(row['ratio'] ?? 0);
    split.shares = Number(row['shares'] ?? 0);
    split.syncStatus = String(row['sync_status'] ?? 'pending');
    split.syncVersion = Number(row['sync_version'] ?? 0);
    split.deletedAt = Number(row['deleted_at'] ?? 0);
    split.createdAt = Number(row['created_at']);
    split.updatedAt = Number(row['updated_at']);
    return split;
  }

  static async getSplitsByBillId(billId: number): Promise<BillSplitBean[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('bill_id', billId);
    predicates.equalTo('deleted_at', 0);
    predicates.orderByAsc('id');

    return new Promise<BillSplitBean[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          resolve(rows.map((row: Record<string, object>) => BillSplitManager.mapRowToSplit(row)));
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `查询账单分摊失败: ${err.message}`);
          reject([]);
        });
    });
  }

  static async replaceBillSplits(billId: number, ledgerId: number, splits: BillSplitBean[]): Promise<void> {
    await BillSplitManager.softDeleteSplitsByBillId(billId);
    for (let index: number = 0; index < splits.length; index++) {
      const split: BillSplitBean = splits[index];
      split.billId = billId;
      split.ledgerId = ledgerId;
      await BillSplitManager.addSplit(split);
    }
  }

  static async addSplit(split: BillSplitBean): Promise<number> {
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      uuid: split.uuid.length > 0 ? split.uuid : BillSplitManager.createLocalUuid(),
      remote_id: split.remoteId,
      bill_id: split.billId,
      ledger_id: split.ledgerId,
      member_id: split.memberId,
      amount: split.amount,
      ratio: split.ratio,
      shares: split.shares,
      sync_status: split.syncStatus,
      sync_version: split.syncVersion,
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
          Clog.error(TAG, `新增账单分摊失败: ${err.message}`);
          reject(-1);
        });
    });
  }

  private static async softDeleteSplitsByBillId(billId: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('bill_id', billId);
    predicates.equalTo('deleted_at', 0);
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      deleted_at: now,
      updated_at: now,
      sync_status: 'pending'
    };

    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then(() => {
          resolve();
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `删除旧分摊失败: ${err.message}`);
          reject(err);
        });
    });
  }
}
