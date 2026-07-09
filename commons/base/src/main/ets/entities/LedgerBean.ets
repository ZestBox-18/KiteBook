/**
 * Copyright (C), 2026-07-09
 * @author ZestBox
 * @date 2026/07/09
 * @version 1.0
 * @description: 账本与成员数据模型
 */

export enum LedgerTypeEnum {
  PERSONAL = 'personal',
  SHARED = 'shared',
  PUBLIC_FUND = 'public_fund'
}

export enum LedgerMemberRoleEnum {
  OWNER = 'owner',
  ADMIN = 'admin',
  EDITOR = 'editor',
  VIEWER = 'viewer'
}

export enum LedgerMemberStatusEnum {
  ACTIVE = 'active',
  INVITED = 'invited',
  REMOVED = 'removed'
}

export enum SyncStatusEnum {
  PENDING = 'pending',
  SYNCED = 'synced',
  CONFLICT = 'conflict'
}

export class LedgerBean {
  id: number = 0;
  uuid: string = '';
  remoteId: string = '';
  name: string = '';
  type: string = LedgerTypeEnum.PERSONAL;
  icon: string = 'book';
  description: string = '';
  currency: string = 'CNY';
  ownerUserId: string = 'local_user';
  isCurrent: boolean = false;
  syncStatus: string = SyncStatusEnum.PENDING;
  syncVersion: number = 0;
  deletedAt: number = 0;
  createdAt: number = 0;
  updatedAt: number = 0;
}

export class LedgerMemberBean {
  id: number = 0;
  uuid: string = '';
  remoteId: string = '';
  ledgerId: number = 0;
  userId: string = '';
  displayName: string = '';
  role: string = LedgerMemberRoleEnum.OWNER;
  status: string = LedgerMemberStatusEnum.ACTIVE;
  isLocalOnly: boolean = true;
  syncStatus: string = SyncStatusEnum.PENDING;
  syncVersion: number = 0;
  deletedAt: number = 0;
  createdAt: number = 0;
  updatedAt: number = 0;
}
