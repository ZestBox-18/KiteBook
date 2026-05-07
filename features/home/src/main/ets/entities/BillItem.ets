/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 账单实体类
 */

@ObservedV2
export class BillItem {
  @Trace id: number = 0;
  @Trace type: string = '';      // 'income' | 'expense'
  @Trace category: string = '';
  @Trace amount: number = 0;
  @Trace account: string = '';
  @Trace date: number = 0;
  @Trace remark: string = '';
  @Trace createdAt: number = 0;
  @Trace updatedAt: number = 0;
}
