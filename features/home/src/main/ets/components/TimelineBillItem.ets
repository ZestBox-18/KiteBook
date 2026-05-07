/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 时间轴账单项组件
 */

import { BillItem } from '../entities/BillItem';
import { formatAmount } from '../utils/HomeDataHelper';

@ComponentV2
export struct TimelineBillItem {
  @Param bill: BillItem = new BillItem();
  @Param onBillClick: (bill: BillItem) => void = () => {};
  @Param onBillDelete: (bill: BillItem) => void = () => {};

  build() {
    Row() {
      // 时间轴节点
      Column() {
        // 时间轴线
        Row()
          .width(2)
          .height('100%')
          .backgroundColor('#E5E5EA')

        // 时间节点
        Circle({ width: 12, height: 12 })
          .fill(this.bill.type === 'income' ? $r('app.color.income') : $r('app.color.expense'))
      }
      .width(24)
      .height('100%')
      .alignItems(HorizontalAlign.Center)

      // 账单内容
      Column() {
        Row() {
          // 时间
          Text(this.formatTime(this.bill.date))
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))

          Blank()

          // 金额
          Text((this.bill.type === 'income' ? '+' : '-') + '¥' + formatAmount(this.bill.amount))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.bill.type === 'income' ? $r('app.color.income') : $r('app.color.expense'))
        }
        .width('100%')

        Row() {
          // 分类图标
          Text(this.bill.category.substring(0, 2))
            .fontSize(16)
            .width(32)
            .height(32)
            .textAlign(TextAlign.Center)
            .backgroundColor($r('sys.color.background_secondary'))
            .borderRadius(16)

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
          .margin({ left: 12 })
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .margin({ left: 8 })
      .padding({ top: 8, bottom: 8, left: 12, right: 12 })
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(12)
      .shadow({
        radius: 4,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 1
      })
    }
    .width('100%')
    .height(80)
    .onClick(() => {
      this.onBillClick(this.bill);
    })
  }

  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
}
