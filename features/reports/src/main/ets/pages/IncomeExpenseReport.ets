import { TimeDimensionEnum } from '../models/TimeDimensionEnum';
import { IncomeExpenseBean, IncomeExpenseSummaryBean } from '../models/IncomeExpenseBean';
import { LineChartComponent } from '../components/LineChartComponent';
import { ReportDataHelper } from '../utils/ReportDataHelper';
import { AppThemeState } from 'base';
import { AppStorageV2 } from '@kit.ArkUI';

interface TimeDimensionItem {
  label: Resource;
  value: TimeDimensionEnum;
}

@ComponentV2
export struct IncomeExpenseReport {
  @Param refreshToken: number = 0;
  @Local currentTimeDimension: TimeDimensionEnum = TimeDimensionEnum.MONTH;
  @Local reportData: IncomeExpenseBean[] = [];
  @Local summaryData: IncomeExpenseSummaryBean | null = null;
  @Local loading: boolean = false;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  
  aboutToAppear(): void {
    this.loadReportData();
  }

  @Monitor('refreshToken')
  onRefreshTokenChanged(): void {
    this.loadReportData();
  }
  
  build() {
    Column() {
      this.TimeDimensionSelector();
      this.SummaryCard();
      this.ChartArea();
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('[shared_assets].color.page_background'))
  }
  
  @Builder
  TimeDimensionSelector() {
    Row() {
      ForEach([
        { label: $r('app.string.reports_time_day'), value: TimeDimensionEnum.DAY },
        { label: $r('app.string.reports_time_week'), value: TimeDimensionEnum.WEEK },
        { label: $r('app.string.reports_time_month'), value: TimeDimensionEnum.MONTH },
        { label: $r('app.string.reports_time_year'), value: TimeDimensionEnum.YEAR }
      ] as TimeDimensionItem[], (item: TimeDimensionItem) => {
        Button(item.label)
          .fontSize(14)
          .fontColor(this.currentTimeDimension === item.value ? this.themeState.fontOnPrimary : this.themeState.fontSecondary)
          .backgroundColor(this.currentTimeDimension === item.value ? this.themeState.brand : this.themeState.compBackgroundNeutral)
          .borderRadius(16)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .margin({ left: 4, right: 4 })
          .onClick(() => {
            this.currentTimeDimension = item.value;
            this.loadReportData();
          })
      }, (item: TimeDimensionItem) => item.value)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 12, bottom: 12 })
  }
  
  @Builder
  SummaryCard() {
    Column() {
      if (this.summaryData) {
        Row() {
          Column() {
            Text($r('app.string.reports_income')).fontSize(12).fontColor(this.themeState.fontSecondary)
            Text('¥' + this.formatAmount(this.summaryData.totalIncome))
              .fontSize(18).fontColor('#4CAF50').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
          Divider().vertical(true).height(40).color(this.themeState.compDivider)
          Column() {
            Text($r('app.string.reports_expense')).fontSize(12).fontColor(this.themeState.fontSecondary)
            Text('¥' + this.formatAmount(this.summaryData.totalExpense))
              .fontSize(18).fontColor('#F44336').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
          Divider().vertical(true).height(40).color(this.themeState.compDivider)
          Column() {
            Text($r('app.string.reports_balance')).fontSize(12).fontColor(this.themeState.fontSecondary)
            Text('¥' + this.formatAmount(this.summaryData.totalBalance))
              .fontSize(18).fontColor(this.themeState.brand).fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
        }.width('100%').padding(16)
      }
    }
    .width('100%')
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(8)
    .border({ width: 1, color: this.themeState.compDivider })
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
  }
  
  @Builder
  ChartArea() {
    Column() {
      Text($r('app.string.reports_trend')).fontSize(16).fontColor(this.themeState.fontPrimary).fontWeight(FontWeight.Medium).margin({ bottom: 12 })
      if (this.reportData.length > 0) {
        LineChartComponent({
          chartWidth: 320, chartHeight: 220,
          incomeData: this.reportData, expenseData: this.reportData,
          showGrid: true, showLegend: true
        })
      } else {
        Column() {
          Text(this.loading ? '加载中...' : $r('app.string.reports_no_data')).fontSize(14).fontColor(this.themeState.fontSecondary)
        }.width('100%').height(220).justifyContent(FlexAlign.Center).backgroundColor(this.themeState.compBackgroundPrimary).borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(8)
    .border({ width: 1, color: this.themeState.compDivider })
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
  }
  
  private async loadReportData(): Promise<void> {
    this.loading = true;
    try {
      const reportData: IncomeExpenseBean[] = await ReportDataHelper.loadIncomeExpenseReport(this.currentTimeDimension);
      this.reportData = reportData;
      this.summaryData = new IncomeExpenseSummaryBean(reportData);
    } finally {
      this.loading = false;
    }
  }
  
  private formatAmount(amount: number): string {
    if (amount >= 10000) return (amount / 10000).toFixed(2) + '万';
    return amount.toFixed(2);
  }
}
