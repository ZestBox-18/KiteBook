/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 账本概览卡片
 */

import { BudgetItem } from '../entities/BudgetItem';
import { StatItem } from './StatItem';
import { BudgetProgress } from './BudgetProgress';
import { formatAmount } from '../utils/HomeDataHelper';

@ComponentV2
export struct OverviewCard {
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
          .color('#2FB04A')
      } else {
        // 收支统计
        Row() {
          StatItem({ label: '收入', value: this.monthIncome, prefix: '+' })
          StatItem({ label: '支出', value: this.monthExpense, prefix: '-' })
          StatItem({ label: '结余', value: this.monthBalance, prefix: '' })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        
        Divider()
          .margin({ top: 16, bottom: 16 })
        
        // 账户余额
        Row() {
          Text('账户余额')
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
          
          Blank()
          
          Text('¥' + formatAmount(this.accountBalance))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        
        if (this.budgets.length > 0) {
          Divider()
            .margin({ top: 16, bottom: 16 })
          
          // 预算进度
          ForEach(this.budgets, (budget: BudgetItem) => {
            BudgetProgress({ budget: budget })
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
