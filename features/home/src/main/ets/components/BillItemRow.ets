/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 账单项组件
 */

import { BillItem } from '../entities/BillItem';
import { formatAmount } from '../utils/HomeDataHelper';

@ComponentV2
export struct BillItemRow {
  @Param bill: BillItem = new BillItem();
  
  build() {
    Row() {
      // 分类图标
      Text(this.bill.category.substring(0, 2))
        .fontSize(20)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .backgroundColor($r('sys.color.background_secondary'))
        .borderRadius(20)
      
      // 分类和备注
      Column() {
        Text(this.bill.category)
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
        
        if (this.bill.remark) {
          Text(this.bill.remark)
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
      
      // 金额
      Text((this.bill.type === 'income' ? '+' : '-') + '¥' + formatAmount(this.bill.amount))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(
          this.bill.type === 'income' ? $r('app.color.income') : $r('app.color.expense')
        )
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
  }
}
