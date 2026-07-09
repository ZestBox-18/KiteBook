/**
 * Copyright (C), 2026-07-09
 * @author ZestBox
 * @date 2026/07/09
 * @version 1.0
 * @description: 共享账单分摊数据模型
 */

export enum BillSplitModeEnum {
  NONE = 'none',
  AVERAGE = 'average',
  RATIO = 'ratio',
  AMOUNT = 'amount',
  SHARES = 'shares',
  SINGLE = 'single'
}

export class BillSplitBean {
  id: number = 0;
  uuid: string = '';
  remoteId: string = '';
  billId: number = 0;
  ledgerId: number = 0;
  memberId: number = 0;
  amount: number = 0;
  ratio: number = 0;
  shares: number = 0;
  syncStatus: string = 'pending';
  syncVersion: number = 0;
  deletedAt: number = 0;
  createdAt: number = 0;
  updatedAt: number = 0;
}
