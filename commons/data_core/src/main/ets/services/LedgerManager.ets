/**
 * Copyright (C), 2026-07-09
 * @author ZestBox
 * @date 2026/07/09
 * @version 1.0
 * @description: 账本与成员数据库操作管理类
 */

import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { dbManager, resultSet2Record, Clog } from 'kite_utils';
import {
  LedgerBean,
  LedgerMemberBean,
  LedgerMemberRoleEnum,
  LedgerMemberStatusEnum,
  LedgerTypeEnum,
  SyncStatusEnum
} from 'base';

const TAG: string = '[LedgerManager]';
const LEDGER_TABLE_NAME: string = 'ledgers';
const MEMBER_TABLE_NAME: string = 'ledger_members';
const DEFAULT_LEDGER_ID: number = 1;
const DEFAULT_MEMBER_ID: number = 1;

export class LedgerManager {
  private static createLocalUuid(prefix: string): string {
    return `${prefix}-${Date.now()}-${Math.floor(Math.random() * 1000000)}`;
  }

  private static mapRowToLedger(row: Record<string, object>): LedgerBean {
    const ledger: LedgerBean = new LedgerBean();
    ledger.id = Number(row['id']);
    ledger.uuid = String(row['uuid'] ?? '');
    ledger.remoteId = String(row['remote_id'] ?? '');
    ledger.name = String(row['name']);
    ledger.type = String(row['type'] ?? LedgerTypeEnum.PERSONAL);
    ledger.icon = String(row['icon'] ?? 'book');
    ledger.description = String(row['description'] ?? '');
    ledger.currency = String(row['currency'] ?? 'CNY');
    ledger.ownerUserId = String(row['owner_user_id'] ?? 'local_user');
    ledger.isCurrent = Number(row['is_current'] ?? 0) === 1;
    ledger.syncStatus = String(row['sync_status'] ?? SyncStatusEnum.PENDING);
    ledger.syncVersion = Number(row['sync_version'] ?? 0);
    ledger.deletedAt = Number(row['deleted_at'] ?? 0);
    ledger.createdAt = Number(row['created_at']);
    ledger.updatedAt = Number(row['updated_at']);
    return ledger;
  }

  private static mapRowToMember(row: Record<string, object>): LedgerMemberBean {
    const member: LedgerMemberBean = new LedgerMemberBean();
    member.id = Number(row['id']);
    member.uuid = String(row['uuid'] ?? '');
    member.remoteId = String(row['remote_id'] ?? '');
    member.ledgerId = Number(row['ledger_id']);
    member.userId = String(row['user_id'] ?? '');
    member.displayName = String(row['display_name']);
    member.role = String(row['role'] ?? LedgerMemberRoleEnum.OWNER);
    member.status = String(row['status'] ?? LedgerMemberStatusEnum.ACTIVE);
    member.isLocalOnly = Number(row['is_local_only'] ?? 1) === 1;
    member.syncStatus = String(row['sync_status'] ?? SyncStatusEnum.PENDING);
    member.syncVersion = Number(row['sync_version'] ?? 0);
    member.deletedAt = Number(row['deleted_at'] ?? 0);
    member.createdAt = Number(row['created_at']);
    member.updatedAt = Number(row['updated_at']);
    return member;
  }

  static async ensureDefaultLedger(): Promise<void> {
    const ledger: LedgerBean | null = await LedgerManager.getLedgerById(DEFAULT_LEDGER_ID);
    if (ledger === null) {
      await LedgerManager.insertDefaultLedger();
    }
    const member: LedgerMemberBean | null = await LedgerManager.getMemberById(DEFAULT_MEMBER_ID);
    if (member === null) {
      await LedgerManager.insertDefaultOwnerMember();
    }
  }

  static async getLedgers(): Promise<LedgerBean[]> {
    const predicates = new relationalStore.RdbPredicates(LEDGER_TABLE_NAME);
    predicates.equalTo('deleted_at', 0);
    predicates.orderByDesc('is_current');
    predicates.orderByAsc('id');

    return new Promise<LedgerBean[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          resolve(rows.map((row: Record<string, object>) => LedgerManager.mapRowToLedger(row)));
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `查询账本失败: ${err.message}`);
          reject([]);
        });
    });
  }

  static async getCurrentLedger(): Promise<LedgerBean | null> {
    const predicates = new relationalStore.RdbPredicates(LEDGER_TABLE_NAME);
    predicates.equalTo('is_current', 1);
    predicates.equalTo('deleted_at', 0);
    predicates.limitAs(1);

    return new Promise<LedgerBean | null>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          if (rows.length === 0) {
            resolve(null);
            return;
          }
          resolve(LedgerManager.mapRowToLedger(rows[0]));
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `查询当前账本失败: ${err.message}`);
          reject(null);
        });
    });
  }

  static async getLedgerById(id: number): Promise<LedgerBean | null> {
    const predicates = new relationalStore.RdbPredicates(LEDGER_TABLE_NAME);
    predicates.equalTo('id', id);
    predicates.equalTo('deleted_at', 0);

    return new Promise<LedgerBean | null>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          if (rows.length === 0) {
            resolve(null);
            return;
          }
          resolve(LedgerManager.mapRowToLedger(rows[0]));
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `查询账本详情失败: ${err.message}`);
          reject(null);
        });
    });
  }

  static async addLedger(ledger: LedgerBean): Promise<number> {
    const now: number = Date.now();
    const uuid: string = ledger.uuid.length > 0 ? ledger.uuid : LedgerManager.createLocalUuid('ledger');
    const data: relationalStore.ValuesBucket = {
      uuid: uuid,
      remote_id: ledger.remoteId,
      name: ledger.name,
      type: ledger.type,
      icon: ledger.icon,
      description: ledger.description,
      currency: ledger.currency,
      owner_user_id: ledger.ownerUserId,
      is_current: ledger.isCurrent ? 1 : 0,
      sync_status: ledger.syncStatus,
      sync_version: ledger.syncVersion,
      deleted_at: 0,
      created_at: now,
      updated_at: now
    };

    if (ledger.isCurrent) {
      await LedgerManager.clearCurrentLedger();
    }

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.insert(LEDGER_TABLE_NAME, data)
        .then(async (id: number) => {
          if (id === -1) {
            reject(-1);
            return;
          }
          await LedgerManager.addMember(id, '我', LedgerMemberRoleEnum.OWNER, 'local_user');
          resolve(id);
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `新增账本失败: ${err.message}`);
          reject(-1);
        });
    });
  }

  static async setCurrentLedger(id: number): Promise<void> {
    await LedgerManager.clearCurrentLedger();
    const predicates = new relationalStore.RdbPredicates(LEDGER_TABLE_NAME);
    predicates.equalTo('id', id);
    const data: relationalStore.ValuesBucket = {
      is_current: 1,
      updated_at: Date.now()
    };
    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then(() => {
          resolve();
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `设置当前账本失败: ${err.message}`);
          reject(err);
        });
    });
  }

  static async getMembersByLedgerId(ledgerId: number): Promise<LedgerMemberBean[]> {
    const predicates = new relationalStore.RdbPredicates(MEMBER_TABLE_NAME);
    predicates.equalTo('ledger_id', ledgerId);
    predicates.equalTo('deleted_at', 0);
    predicates.notEqualTo('status', LedgerMemberStatusEnum.REMOVED);
    predicates.orderByAsc('id');

    return new Promise<LedgerMemberBean[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          resolve(rows.map((row: Record<string, object>) => LedgerManager.mapRowToMember(row)));
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `查询账本成员失败: ${err.message}`);
          reject([]);
        });
    });
  }

  static async addMember(
    ledgerId: number,
    displayName: string,
    role: string = LedgerMemberRoleEnum.EDITOR,
    userId: string = ''
  ): Promise<number> {
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      uuid: LedgerManager.createLocalUuid('member'),
      remote_id: '',
      ledger_id: ledgerId,
      user_id: userId,
      display_name: displayName,
      role: role,
      status: LedgerMemberStatusEnum.ACTIVE,
      is_local_only: userId.length === 0 ? 1 : 0,
      sync_status: SyncStatusEnum.PENDING,
      sync_version: 0,
      deleted_at: 0,
      created_at: now,
      updated_at: now
    };

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.insert(MEMBER_TABLE_NAME, data)
        .then((id: number) => {
          resolve(id);
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `新增账本成员失败: ${err.message}`);
          reject(-1);
        });
    });
  }

  private static async getMemberById(id: number): Promise<LedgerMemberBean | null> {
    const predicates = new relationalStore.RdbPredicates(MEMBER_TABLE_NAME);
    predicates.equalTo('id', id);
    predicates.equalTo('deleted_at', 0);

    return new Promise<LedgerMemberBean | null>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          if (rows.length === 0) {
            resolve(null);
            return;
          }
          resolve(LedgerManager.mapRowToMember(rows[0]));
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `查询账本成员详情失败: ${err.message}`);
          reject(null);
        });
    });
  }

  private static async clearCurrentLedger(): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(LEDGER_TABLE_NAME);
    predicates.equalTo('is_current', 1);
    const data: relationalStore.ValuesBucket = {
      is_current: 0,
      updated_at: Date.now()
    };
    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then(() => {
          resolve();
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `清理当前账本失败: ${err.message}`);
          reject(err);
        });
    });
  }

  private static async insertDefaultLedger(): Promise<void> {
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      id: DEFAULT_LEDGER_ID,
      uuid: 'local-ledger-default',
      remote_id: '',
      name: '默认账本',
      type: LedgerTypeEnum.PERSONAL,
      icon: 'book',
      description: '个人日常收支记录',
      currency: 'CNY',
      owner_user_id: 'local_user',
      is_current: 1,
      sync_status: SyncStatusEnum.PENDING,
      sync_version: 0,
      deleted_at: 0,
      created_at: now,
      updated_at: now
    };

    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.insert(LEDGER_TABLE_NAME, data)
        .then(() => {
          resolve();
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `写入默认账本失败: ${err.message}`);
          reject(err);
        });
    });
  }

  private static async insertDefaultOwnerMember(): Promise<void> {
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      id: DEFAULT_MEMBER_ID,
      uuid: 'local-member-owner',
      remote_id: '',
      ledger_id: DEFAULT_LEDGER_ID,
      user_id: 'local_user',
      display_name: '我',
      role: LedgerMemberRoleEnum.OWNER,
      status: LedgerMemberStatusEnum.ACTIVE,
      is_local_only: 1,
      sync_status: SyncStatusEnum.PENDING,
      sync_version: 0,
      deleted_at: 0,
      created_at: now,
      updated_at: now
    };

    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.insert(MEMBER_TABLE_NAME, data)
        .then(() => {
          resolve();
        })
        .catch((err: BusinessError) => {
          Clog.error(TAG, `写入默认账本成员失败: ${err.message}`);
          reject(err);
        });
    });
  }
}
