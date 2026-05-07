/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 预算实体类
 */

@ObservedV2
export class BudgetItem {
  @Trace id: number = 0;
  @Trace category: string = '';
  @Trace budgetAmount: number = 0;    // 预算金额
  @Trace usedAmount: number = 0;      // 已使用金额
  @Trace progress: number = 0;        // 使用进度（0-1）
  @Trace month: string = '';
}
