/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 预算进度组件
 */

import { BudgetItem } from '../entities/BudgetItem';
import { formatAmount } from '../utils/HomeDataHelper';

@ComponentV2
export struct BudgetProgress {
  @Param budget: BudgetItem = new BudgetItem();
  
  build() {
    Column() {
      Row() {
        // 分类名称
        Text(this.budget.category)
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
        
        // 金额信息
        Text(`¥${formatAmount(this.budget.usedAmount)} / ¥${formatAmount(this.budget.budgetAmount)}`)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      // 进度条
      Row() {
        Row()
          .width(`${this.budget.progress * 100}%`)
          .height('100%')
          .backgroundColor(
            this.budget.progress >= 1 ? $r('app.color.expense') :
            this.budget.progress >= 0.8 ? $r('app.color.warning') :
            $r('app.color.income')
          )
          .borderRadius(4)
      }
      .width('100%')
      .height(8)
      .backgroundColor($r('sys.color.background_secondary'))
      .borderRadius(4)
    }
    .width('100%')
  }
}
