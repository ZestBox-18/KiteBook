/**
 * Copyright (C), 2026-07-03
 * @author ZestBox
 * @date 2026/07/03
 * @version 1.0
 * @description: 首页周收支概览卡片
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { AppThemeState } from 'base';
import { WindowUtil } from 'kite_utils';

const HOME_INCOME_COLOR: string = '#16A34A';
const HOME_EXPENSE_COLOR: string = '#EF4444';

@ComponentV2
export struct WeeklyOverviewCardComponent {
  @Param incomeText: string = '¥0.00';
  @Param expenseText: string = '¥0.00';
  @Param balanceText: string = '+¥0.00';
  @Param balancePositive: boolean = true;
  @Param trendValues: number[] = [18, 34, 48, 38, 42, 22, 17];

  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;

  private trendSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private trendContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.trendSettings);

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('本周收支')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontPrimary)
          .layoutWeight(1)
        Row({ space: 4 }) {
          Text('本周')
            .fontSize(14)
            .fontColor(this.themeState.fontSecondary)
          SymbolGlyph($r('sys.symbol.chevron_down'))
            .fontSize(12)
            .fontColor([this.themeState.fontSecondary as ResourceColor])
        }
      }
      .width('100%')

      Row() {
        this.WeekSummaryMetric('收入', this.incomeText, HOME_INCOME_COLOR)
        Divider().vertical(true).height(44).color(this.themeState.compDivider)
        this.WeekSummaryMetric('支出', this.expenseText, HOME_EXPENSE_COLOR)
        Divider().vertical(true).height(44).color(this.themeState.compDivider)
        this.WeekSummaryMetric('结余', this.balanceText,
          this.balancePositive ? HOME_INCOME_COLOR : this.themeState.brand as ResourceColor)
      }
      .width('100%')

      this.WeeklyTrendLine()
    }
    .width('100%')
    .padding(14)
    .borderRadius(22)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private WeekSummaryMetric(label: string, value: string, color: ResourceColor) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private WeeklyTrendLine() {
    Column() {
      Canvas(this.trendContext)
        .width('100%')
        .height(48)
        .onReady(() => {
          this.drawWeeklyTrend();
        })
      .width('100%')
      .height(48)

      Row() {
        this.WeekDayLabel('周一')
        this.WeekDayLabel('周二')
        this.WeekDayLabel('周三')
        this.WeekDayLabel('周四')
        this.WeekDayLabel('周五')
        this.WeekDayLabel('周六')
        this.WeekDayLabel('周日')
      }
      .width('100%')
      .margin({ top: 6 })
    }
    .width('100%')
  }

  @Builder
  private WeekDayLabel(label: string) {
    Text(label)
      .fontSize(12)
      .fontColor(this.themeState.fontSecondary)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
  }

  private drawWeeklyTrend(): void {
    const chartWidth: number = Math.max(this.getViewportWidth() - 68, 260);
    const chartHeight: number = 48;
    const maxTrendValue: number = this.getMaxTrendValue();
    const leftPadding: number = 10;
    const rightPadding: number = 10;
    const topPadding: number = 6;
    const bottomPadding: number = 10;
    const plotWidth: number = chartWidth - leftPadding - rightPadding;
    const plotHeight: number = chartHeight - topPadding - bottomPadding;

    this.trendContext.clearRect(0, 0, chartWidth, chartHeight);
    this.trendContext.strokeStyle = this.themeState.compDivider as string;
    this.trendContext.lineWidth = 1;
    this.trendContext.beginPath();
    this.trendContext.moveTo(0, chartHeight - 1);
    this.trendContext.lineTo(chartWidth, chartHeight - 1);
    this.trendContext.stroke();

    this.trendContext.strokeStyle = this.themeState.brand as string;
    this.trendContext.lineWidth = 2;
    this.trendContext.beginPath();
    this.trendValues.forEach((value: number, index: number) => {
      const x: number = leftPadding + plotWidth * index / (this.trendValues.length - 1);
      const y: number = topPadding + plotHeight * (1 - value / maxTrendValue);
      if (index === 0) {
        this.trendContext.moveTo(x, y);
      } else {
        this.trendContext.lineTo(x, y);
      }
    });
    this.trendContext.stroke();

    this.trendValues.forEach((value: number, index: number) => {
      const x: number = leftPadding + plotWidth * index / (this.trendValues.length - 1);
      const y: number = topPadding + plotHeight * (1 - value / maxTrendValue);
      this.trendContext.beginPath();
      this.trendContext.fillStyle = this.themeState.compBackgroundPrimary as string;
      this.trendContext.arc(x, y, 4, 0, Math.PI * 2);
      this.trendContext.fill();
      this.trendContext.strokeStyle = this.themeState.brand as string;
      this.trendContext.lineWidth = 2;
      this.trendContext.stroke();
    });
  }

  private getViewportWidth(): number {
    const windowWidthPx: number = this.winUtil.mainWindowInfo.windowSize.width;
    if (windowWidthPx <= 0) {
      return 360;
    }
    return this.getUIContext().px2vp(windowWidthPx);
  }

  private getMaxTrendValue(): number {
    let maxValue: number = 0;
    this.trendValues.forEach((value: number) => {
      if (value > maxValue) {
        maxValue = value;
      }
    });
    return maxValue > 0 ? maxValue * 1.15 : 1;
  }
}
