/**
 * Copyright (C), 2025-05-13
 * @author ZestBox
 * @date 2025/05/15
 * @version 1.0
 * @description: 账单列表项组件
 */

import { AppThemeState, BillBean, BillTypeEnum } from 'base';

@ComponentV2
export struct BillItemComponent {
  @Param bill: BillBean = new BillBean();
  @Param themeState: AppThemeState = new AppThemeState();

  build() {
    Row() {
      SymbolGlyph(this.bill.getCategoryIcon())
        .fontSize(20)
        .fontColor([this.bill.type === BillTypeEnum.EXPENSE ? '#EF4444' : '#10B981'])
        .width(36)
        .height(36)
        .borderRadius(8)
        .backgroundColor(this.bill.type === BillTypeEnum.EXPENSE ? '#FEE2E2' : '#D1FAE5')
        .padding(8)

      Column() {
        Text(this.bill.category)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
        if (this.bill.remark.length > 0) {
          Text(this.bill.remark)
            .fontSize(13)
            .fontColor(this.themeState.fontSecondary)
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      Column() {
        Text(this.bill.formatAmount())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.bill.type === BillTypeEnum.EXPENSE ? '#EF4444' : '#10B981')
        Text(this.bill.getTimeString())
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }
}
