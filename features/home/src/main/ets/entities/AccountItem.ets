/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 账户实体类
 */

@ObservedV2
export class AccountItem {
  @Trace id: number = 0;
  @Trace name: string = '';
  @Trace balance: number = 0;
  @Trace type: string = '';
  @Trace icon: string = '';
  @Trace createdAt: number = 0;
  @Trace updatedAt: number = 0;
}
