/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 数据概览卡片
 */

import { BudgetItem } from '../entities/BudgetItem';
import { IncomeExpenseStats } from './IncomeExpenseStats';
import { AccountBalance } from './AccountBalance';
import { BudgetProgressList } from './BudgetProgressList';

@ComponentV2
export struct DataOverviewCard {
  @Param monthIncome: number = 0;
  @Param monthExpense: number = 0;
  @Param monthBalance: number = 0;
  @Param accountBalance: number = 0;
  @Param budgets: BudgetItem[] = [];
  @Param isLoading: boolean = false;

  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
          .width(48)
          .height(48)
          .color($r('app.color.brand'))
      } else {
        // 收支统计
        IncomeExpenseStats({
          monthIncome: this.monthIncome,
          monthExpense: this.monthExpense,
          monthBalance: this.monthBalance,
          isLoading: this.isLoading
        })

        Divider()
          .margin({ top: 16, bottom: 16 })

        // 账户余额
        AccountBalance({
          accountBalance: this.accountBalance
        })

        if (this.budgets.length > 0) {
          Divider()
            .margin({ top: 16, bottom: 16 })

          // 预算进度
          BudgetProgressList({
            budgets: this.budgets
          })
        }
      }
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding(20)
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
  }
}
