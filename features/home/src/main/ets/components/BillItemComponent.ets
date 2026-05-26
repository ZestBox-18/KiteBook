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

  private getBillTintColor(): ResourceColor {
    if (this.bill.type === BillTypeEnum.EXPENSE) {
      return '#EF4444';
    }
    if (this.bill.type === BillTypeEnum.INCOME) {
      return '#10B981';
    }
    return this.themeState.brand as ResourceColor;
  }

  private getBillBgColor(): ResourceColor {
    if (this.bill.type === BillTypeEnum.EXPENSE) {
      return '#FEE2E2';
    }
    if (this.bill.type === BillTypeEnum.INCOME) {
      return '#D1FAE5';
    }
    return '#DBEAFE';
  }

  /**
   * 构建单个账单列表项，展示分类、备注、金额和时间。
   */
  build() {
    Row() {
      SymbolGlyph(this.bill.getCategoryIcon())
        .fontSize(20)
        .fontColor([this.getBillTintColor()])
        .width(36)
        .height(36)
        .borderRadius(8)
        .backgroundColor(this.getBillBgColor())
        .padding(8)

      Column() {
        Text(this.bill.category)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
        Text(this.bill.remark.length > 0 ? `${this.bill.getAccountDisplayText()} · ${this.bill.remark}` :
          this.bill.getAccountDisplayText())
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      Column() {
        Text(this.bill.formatAmount())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getBillTintColor())
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
