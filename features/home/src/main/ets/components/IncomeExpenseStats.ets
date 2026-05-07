/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 收支统计组件
 */

import { formatAmount } from '../utils/HomeDataHelper';

@ComponentV2
export struct IncomeExpenseStats {
  @Param monthIncome: number = 0;
  @Param monthExpense: number = 0;
  @Param monthBalance: number = 0;
  @Param isLoading: boolean = false;

  build() {
    Row() {
      // 收入统计
      Column() {
        Text('收入')
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))

        Text('+¥' + formatAmount(this.monthIncome))
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.income'))
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      // 支出统计
      Column() {
        Text('支出')
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))

        Text('-¥' + formatAmount(this.monthExpense))
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.expense'))
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      // 结余统计
      Column() {
        Text('结余')
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))

        Text('¥' + formatAmount(this.monthBalance))
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.brand'))
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
  }
}
