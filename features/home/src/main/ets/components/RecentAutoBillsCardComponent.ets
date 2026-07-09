/**
 * Copyright (C), 2026-07-03
 * @author ZestBox
 * @date 2026/07/03
 * @version 1.0
 * @description: 首页最近自动入账卡片
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { AppThemeState, BillBean, BillTypeEnum } from 'base';

const HOME_INCOME_COLOR: string = '#16A34A';
const HOME_EXPENSE_COLOR: string = '#EF4444';
const HOME_DANGER_COLOR: string = '#E55454';

@ComponentV2
export struct RecentAutoBillsCardComponent {
  @Param recentBills: BillBean[] = [];
  @Event onViewAll: () => void = () => {
  };
  @Event onEditBill: (billId: number) => void = (_billId: number): void => {
  };
  @Event onDeleteBill: (billId: number) => void = (_billId: number): void => {
  };
  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('最近自动入账')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontPrimary)
          .layoutWeight(1)
        Row({ space: 4 }) {
          Text('全部账单')
            .fontSize(14)
            .fontColor(this.themeState.fontSecondary)
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(13)
            .fontColor([this.themeState.fontSecondary])
        }
        .onClick(() => {
          this.onViewAll();
        })
      }
      .width('100%')

      if (this.recentBills.length === 0) {
        Text('暂无自动入账记录')
          .fontSize(14)
          .fontColor(this.themeState.fontSecondary)
          .width('100%')
          .padding({ top: 20, bottom: 20 })
          .textAlign(TextAlign.Center)
      } else {
        List({ space: 0 }) {
          ForEach(this.recentBills.slice(0, 3), (bill: BillBean) => {
            ListItem() {
              this.RecentBillRowContent(bill)
            }
            .swipeAction({
              end: this.RecentBillSwipeAction(bill)
            })
          }, (bill: BillBean) => `${bill.id}`)
        }
        .width('100%')
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .padding(14)
    .borderRadius(22)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private RecentBillRowContent(bill: BillBean) {
    Row({ space: 12 }) {
      SymbolGlyph(bill.getCategoryIcon())
        .fontSize(22)
        .fontColor([this.getBillTintColor(bill)])
        .width(42)
        .height(42)
        .borderRadius(12)
        .backgroundColor(this.getBillSoftColor())
        .padding(9)

      Column() {
        Text(bill.category)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontPrimary)
        Text(`${bill.account} · 屏幕识别`)
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text(bill.formatAmount())
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getBillTintColor(bill))
        Text(bill.getTimeString())
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
  }

  @Builder
  private RecentBillSwipeAction(bill: BillBean) {
    Row({ space: 8 }) {
      Button('编辑')
        .width(72)
        .height(40)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.brand)
        .backgroundColor(this.themeState.compBackgroundNeutral)
        .borderRadius(12)
        .onClick(() => {
          this.onEditBill(bill.id);
        })

      Button('删除')
        .width(72)
        .height(40)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontOnPrimary)
        .backgroundColor(HOME_DANGER_COLOR)
        .borderRadius(12)
        .onClick(() => {
          this.onDeleteBill(bill.id);
        })
    }
    .padding({ right: 4 })
    .alignItems(VerticalAlign.Center)
  }

  private getBillTintColor(bill: BillBean): ResourceColor {
    if (bill.type === BillTypeEnum.INCOME) {
      return HOME_INCOME_COLOR;
    }
    if (bill.type === BillTypeEnum.TRANSFER) {
      return this.themeState.brand as ResourceColor;
    }
    return HOME_EXPENSE_COLOR;
  }

  private getBillSoftColor(): ResourceColor {
    return this.themeState.compBackgroundNeutral as ResourceColor;
  }
}
