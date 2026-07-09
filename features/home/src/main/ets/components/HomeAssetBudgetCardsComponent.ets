/**
 * Copyright (C), 2026-07-03
 * @author ZestBox
 * @date 2026/07/03
 * @version 1.0
 * @description: 首页资产和预算双卡组件
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { AppThemeState } from 'base';

@ComponentV2
export struct HomeAssetBudgetCardsComponent {
  @Param currentMonthText: string = '本月';
  @Param budgetRemainingText: string = '¥0.00';
  @Param usedBudgetText: string = '¥0.00';
  @Param totalBudgetText: string = '¥0.00';
  @Param dailyAvailableText: string = '¥0.00';
  @Param budgetUsagePercent: number = 0;
  @Param remainingDaysText: string = '剩余 1 天';
  @Event onBudgetClick: () => void = () => {
  };

  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;

  build() {
    Column() {
      this.MonthBudgetCard()
    }
    .width('100%')
  }

  @Builder
  private MonthBudgetCard() {
    Column() {
      Row() {
        Text('本月预算')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontPrimary)
          .layoutWeight(1)
        Text(this.currentMonthText.length > 0 ? this.currentMonthText : '本月')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.brand)
      }
      .width('100%')

      Row() {
        Stack() {
          Progress({ value: this.budgetUsagePercent, total: 100, type: ProgressType.Ring })
            .width(92)
            .height(92)
            .color(this.themeState.brand)
            .backgroundColor(this.themeState.compDivider)

          Column() {
            Text(`${Math.round(this.budgetUsagePercent)}%`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontPrimary)
            Text('已使用')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width(96)
        .height(96)

        Column() {
          Text('剩余预算')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.fontSecondary)
          Text(this.budgetRemainingText)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 6 })

          Row() {
            Text('已使用')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
            Text(this.usedBudgetText)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
              .margin({ left: 10 })
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text('总预算')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
            Text(this.totalBudgetText)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
              .margin({ left: 10 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .margin({ top: 16 })
        }
        .layoutWeight(1)
        .margin({ left: 26 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ top: 16 })
      .alignItems(VerticalAlign.Center)

      Row() {
        Row({ space: 10 }) {
          SymbolGlyph($r('sys.symbol.calendar'))
            .fontSize(18)
            .fontColor([this.themeState.brand as ResourceColor])
          Text('日均可用')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.fontPrimary)
          Text(this.dailyAvailableText)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.brand)
        }

        Text(this.remainingDaysText)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontSecondary)
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .height(40)
      .padding({ left: 14, right: 14 })
      .borderRadius(12)
      .border({ width: 1, color: this.themeState.compDivider })
      .margin({ top: 18 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 18, bottom: 18 })
    .borderRadius(22)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .onClick(() => {
      this.onBudgetClick();
    })
  }
}
