/**
 * Copyright (C), 2026-05-25
 * @author ZestBox
 * @date 2026/05/25
 * @version 1.0
 * @description: 预算数据实体
 */

export class BudgetBean {
  id: number = 0;
  uuid: string = '';
  remoteId: string = '';
  ledgerId: number = 1;
  category: string = '';
  amount: number = 0;
  month: string = '';
  syncStatus: string = 'pending';
  syncVersion: number = 0;
  deletedAt: number = 0;
  createdAt: number = 0;
  updatedAt: number = 0;
}
