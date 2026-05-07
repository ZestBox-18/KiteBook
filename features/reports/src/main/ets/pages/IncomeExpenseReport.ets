import { TimeDimensionEnum } from '../models/TimeDimensionEnum';
import { IncomeExpenseBean, IncomeExpenseSummaryBean } from '../models/IncomeExpenseBean';
import { LineChartComponent } from '../components/LineChartComponent';

interface TimeDimensionItem {
  label: Resource;
  value: TimeDimensionEnum;
}

@ComponentV2
export struct IncomeExpenseReport {
  @Local currentTimeDimension: TimeDimensionEnum = TimeDimensionEnum.MONTH;
  @Local reportData: IncomeExpenseBean[] = [];
  @Local summaryData: IncomeExpenseSummaryBean | null = null;
  
  aboutToAppear(): void {
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
    .backgroundColor($r('app.color.page_background'))
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
          .fontColor(this.currentTimeDimension === item.value ? '#FFFFFF' : '#757575')
          .backgroundColor(this.currentTimeDimension === item.value ? '#2196F3' : '#F5F5F5')
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
            Text($r('app.string.reports_income')).fontSize(12).fontColor('#757575')
            Text('¥' + this.formatAmount(this.summaryData.totalIncome))
              .fontSize(18).fontColor('#4CAF50').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
          Divider().vertical(true).height(40).color('#E0E0E0')
          Column() {
            Text($r('app.string.reports_expense')).fontSize(12).fontColor('#757575')
            Text('¥' + this.formatAmount(this.summaryData.totalExpense))
              .fontSize(18).fontColor('#F44336').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
          Divider().vertical(true).height(40).color('#E0E0E0')
          Column() {
            Text($r('app.string.reports_balance')).fontSize(12).fontColor('#757575')
            Text('¥' + this.formatAmount(this.summaryData.totalBalance))
              .fontSize(18).fontColor('#2196F3').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
        }.width('100%').padding(16)
      }
    }
    .width('100%').backgroundColor('#FFFFFF').borderRadius(8).margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })
  }
  
  @Builder
  ChartArea() {
    Column() {
      Text($r('app.string.reports_trend')).fontSize(16).fontColor('#212121').fontWeight(FontWeight.Medium).margin({ bottom: 12 })
      if (this.reportData.length > 0) {
        LineChartComponent({
          chartWidth: 320, chartHeight: 220,
          incomeData: this.reportData, expenseData: this.reportData,
          showGrid: true, showLegend: true
        })
      } else {
        Column() {
          Text($r('app.string.reports_no_data')).fontSize(14).fontColor('#757575')
        }.width('100%').height(220).justifyContent(FlexAlign.Center).backgroundColor('#FFFFFF').borderRadius(8)
      }
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(8).margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })
  }
  
  private loadReportData(): void {
    setTimeout(() => {
      this.reportData = this.generateMockData();
      this.summaryData = new IncomeExpenseSummaryBean(this.reportData);
    }, 500);
  }
  
  private generateMockData(): IncomeExpenseBean[] {
    const data: IncomeExpenseBean[] = [];
    const now = Date.now();
    const dayMs = 24 * 60 * 60 * 1000;
    const count = 6;
    for (let i = count - 1; i >= 0; i--) {
      const timestamp = now - i * 30 * dayMs;
      const date = new Date(timestamp);
      const timeLabel = date.getFullYear() + '-' + ((date.getMonth() + 1).toString().padStart(2, '0')) + '-' + (date.getDate().toString().padStart(2, '0'));
      const income = Math.random() * 5000 + 2000;
      const expense = Math.random() * 4000 + 1000;
      data.push(new IncomeExpenseBean(timeLabel, income, expense, timestamp));
    }
    return data;
  }
  
  private formatAmount(amount: number): string {
    if (amount >= 10000) return (amount / 10000).toFixed(2) + '万';
    return amount.toFixed(2);
  }
}
