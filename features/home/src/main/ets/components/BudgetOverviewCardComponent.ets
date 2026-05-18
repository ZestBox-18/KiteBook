/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页预算概览卡片
 */

import { AppThemeState } from 'base';
import { HomeSwiperCardShellComponent } from './HomeSwiperCardShellComponent';

@ComponentV2
export struct BudgetOverviewCardComponent {
  @Param themeState: AppThemeState = new AppThemeState();
  @Param compactLayout: boolean = false;
  @Param currentMonthText: string = '';
  @Param budgetProgressValue: number = 0;
  @Param budgetUsagePercent: number = 0;
  @Param dailyBudgetText: string = '';
  @Param budgetRemainingText: string = '';
  @Param totalBudgetText: string = '';
  @Param monthlyExpenseText: string = '';
  @Param remainingDaysText: string = '';
  @Param opacityValue: number = 1;
  @Param scaleValue: number = 1;
  @Param rotateValue: number = 0;
  @Param zIndexValue: number = 0;
  @Param totalBudgetValue: number = 4000;

  /**
   * 构建预算概览卡片外壳并注入预算内容。
   */
  build() {
    HomeSwiperCardShellComponent({
      themeState: this.themeState,
      compactLayout: this.compactLayout,
      opacityValue: this.opacityValue,
      scaleValue: this.scaleValue,
      rotateValue: this.rotateValue,
      zIndexValue: this.zIndexValue,
      heightValue: 236,
      leftPadding: this.compactLayout ? 14 : 20,
      rightPadding: this.compactLayout ? 14 : 20,
      topPadding: this.compactLayout ? 14 : 16,
      bottomPadding: this.compactLayout ? 12 : 8,
      content: () => {
        this.CardContent();
      }
    })
  }

  @Builder
  /**
   * 构建预算概览卡片主体内容。
   */
  private CardContent() {
    Column() {
      this.CardHeader($r('sys.symbol.creditcard'), '本月预算', this.currentMonthText)

      Row({ space: this.compactLayout ? 10 : 16 }) {
        Stack({ alignContent: Alignment.Center }) {
          Progress({
            value: this.budgetProgressValue,
            total: this.totalBudgetValue,
            type: ProgressType.Ring
          })
            .width(this.compactLayout ? 102 : 122)
            .height(this.compactLayout ? 102 : 122)
            .color(this.themeState.brand)
            .backgroundColor('#EDE6DA')
            .style({ strokeWidth: this.compactLayout ? 10 : 12 })

          Column({ space: 2 }) {
            Text(`${Math.floor(this.budgetUsagePercent)}%`)
              .fontSize(this.compactLayout ? 20 : 24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontPrimary)
            Text('已使用')
              .fontSize(this.compactLayout ? 9 : 10)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width(this.compactLayout ? 112 : 138)
        .height(this.compactLayout ? 112 : 138)

        Column({ space: this.compactLayout ? 10 : 12 }) {
          this.MetricItem('剩余日均', this.dailyBudgetText)
          this.MetricItem('预算剩余', this.budgetRemainingText)
          this.MetricItem('总预算', this.totalBudgetText)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: this.compactLayout ? 8 : 22, right: this.compactLayout ? 0 : 6 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.compactLayout ? 10 : 14 })

      Row() {
        Text(`本月已支出 ${this.monthlyExpenseText}`)
          .fontSize(this.compactLayout ? 12 : 13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.remainingDaysText)
          .fontSize(this.compactLayout ? 12 : 13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.brand)
      }
      .width('100%')
      .padding({
        left: this.compactLayout ? 12 : 16,
        right: this.compactLayout ? 12 : 16,
        top: 12,
        bottom: 12
      })
      .backgroundColor('#FBF8F3')
      .borderRadius(14)
      .border({ width: 1, color: '#F1E8DA' })
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: this.compactLayout ? 10 : 0 })
    }
  }

  @Builder
  /**
   * 构建预算卡标题行，可选展示月份后缀。
   */
  private CardHeader(icon: Resource, title: string, suffix: string) {
    Row() {
      Row({ space: 10 }) {
        SymbolGlyph(icon)
          .fontSize(18)
          .fontColor([this.themeState.brand as ResourceColor])
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontPrimary)
      }
      if (suffix !== '') {
        Text(suffix)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.brand)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  /**
   * 构建预算卡右侧的单个指标项。
   */
  private MetricItem(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(this.compactLayout ? 11 : 12)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.brand)
      Text(value)
        .fontSize(this.compactLayout ? 14 : 17)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.fontPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
  }
}
