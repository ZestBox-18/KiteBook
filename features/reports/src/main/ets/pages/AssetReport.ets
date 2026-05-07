import { TimeDimensionEnum } from '../models/TimeDimensionEnum';
import { AssetAnalysisBean, AssetAnalysisSummaryBean } from '../models/AssetAnalysisBean';

interface TimeDimensionItem { label: Resource; value: TimeDimensionEnum; }

@ComponentV2
export struct AssetReport {
  @Local currentTimeDimension: TimeDimensionEnum = TimeDimensionEnum.MONTH;
  @Local reportData: AssetAnalysisBean[] = [];
  @Local summaryData: AssetAnalysisSummaryBean | null = null;
  
  aboutToAppear(): void { this.loadReportData(); }
  
  build() {
    Column() {
      this.TimeDimensionSelector();
      this.SummaryCard();
      Text('资产分析功能开发中...').fontSize(16).fontColor('#757575').margin({ top: 20 })
    }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
  }
  
  @Builder
  TimeDimensionSelector() {
    Row() {
      ForEach([
        { label: $r('app.string.reports_time_week'), value: TimeDimensionEnum.WEEK },
        { label: $r('app.string.reports_time_month'), value: TimeDimensionEnum.MONTH },
        { label: $r('app.string.reports_time_year'), value: TimeDimensionEnum.YEAR }
      ] as TimeDimensionItem[], (item: TimeDimensionItem) => {
        Button(item.label).fontSize(14)
          .fontColor(this.currentTimeDimension === item.value ? '#FFFFFF' : '#757575')
          .backgroundColor(this.currentTimeDimension === item.value ? '#2196F3' : '#F5F5F5')
          .borderRadius(16).padding({ left: 16, right: 16, top: 6, bottom: 6 }).margin({ left: 4, right: 4 })
          .onClick(() => { this.currentTimeDimension = item.value; this.loadReportData(); })
      }, (item: TimeDimensionItem) => item.value)
    }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 12, bottom: 12 })
  }
  
  @Builder
  SummaryCard() {
    Column() {
      if (this.summaryData) {
        Row() {
          Column() {
            Text('当前资产').fontSize(12).fontColor('#757575')
            Text('¥' + this.formatAmount(this.summaryData.currentTotalAsset))
              .fontSize(18).fontColor('#2196F3').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
          Divider().vertical(true).height(40).color('#E0E0E0')
          Column() {
            Text('净资产').fontSize(12).fontColor('#757575')
            Text('¥' + this.formatAmount(this.summaryData.currentNetAsset))
              .fontSize(18).fontColor('#4CAF50').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
          Divider().vertical(true).height(40).color('#E0E0E0')
          Column() {
            Text('增长率').fontSize(12).fontColor('#757575')
            Text(this.summaryData.assetGrowthRate.toFixed(2) + '%')
              .fontSize(18).fontColor(this.summaryData.assetGrowthRate >= 0 ? '#4CAF50' : '#F44336')
              .fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
        }.width('100%').padding(16)
      }
    }.width('100%').backgroundColor('#FFFFFF').borderRadius(8).margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })
  }
  
  private loadReportData(): void {
    setTimeout(() => {
      this.reportData = this.generateMockData();
      this.summaryData = new AssetAnalysisSummaryBean(this.reportData);
    }, 500);
  }
  
  private generateMockData(): AssetAnalysisBean[] {
    const data: AssetAnalysisBean[] = [];
    const now = Date.now();
    let baseAsset = 50000;
    for (let i = 5; i >= 0; i--) {
      const timestamp = now - i * 30 * 24 * 60 * 60 * 1000;
      const date = new Date(timestamp);
      const timeLabel = date.getFullYear() + '年' + ((date.getMonth() + 1).toString().padStart(2, '0')) + '月';
      baseAsset += (Math.random() - 0.3) * 5000;
      const totalAsset = Math.max(baseAsset, 10000);
      data.push(new AssetAnalysisBean(timeLabel, totalAsset, totalAsset * 0.6, totalAsset * 0.4, Math.random() * 10000, timestamp));
    }
    return data;
  }
  
  private formatAmount(amount: number): string {
    if (amount >= 10000) return (amount / 10000).toFixed(2) + '万';
    return amount.toFixed(2);
  }
}
