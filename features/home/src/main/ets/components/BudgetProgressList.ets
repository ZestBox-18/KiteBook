/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 预算进度列表组件
 */

import { BudgetItem } from '../entities/BudgetItem';
import { BudgetProgress } from './BudgetProgress';

@ComponentV2
export struct BudgetProgressList {
  @Param budgets: BudgetItem[] = [];

  build() {
    Column() {
      if (this.budgets.length > 0) {
        ForEach(this.budgets, (budget: BudgetItem) => {
          BudgetProgress({ budget: budget })
            .margin({ bottom: 12 })
        })
      }
    }
    .width('100%')
  }
}
