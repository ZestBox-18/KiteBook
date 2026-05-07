import { TimeDimensionEnum } from '../models/TimeDimensionEnum';
import { CategoryStatBean, CategoryStatSummaryBean } from '../models/CategoryStatBean';
import { PieChartComponent } from '../components/PieChartComponent';

interface TimeDimensionItem { label: Resource; value: TimeDimensionEnum; }
interface CategoryData { name: string; icon: string; color: string; }

@ComponentV2
export struct CategoryReport {
  @Local currentTimeDimension: TimeDimensionEnum = TimeDimensionEnum.MONTH;
  @Local reportData: CategoryStatBean[] = [];
  @Local summaryData: CategoryStatSummaryBean | null = null;
  
  aboutToAppear(): void { this.loadReportData(); }
  
  build() {
    Column() {
      this.TimeDimensionSelector();
      this.PieChartArea();
      this.CategoryList();
    }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
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
        Button(item.label).fontSize(14)
          .fontColor(this.currentTimeDimension === item.value ? '#FFFFFF' : '#757575')
          .backgroundColor(this.currentTimeDimension === item.value ? '#2196F3' : '#F5F5F5')
          .borderRadius(16).padding({ left: 16, right: 16, top: 6, bottom: 6 }).margin({ left: 4, right: 4 })
          .onClick(() => { this.currentTimeDimension = item.value; this.loadReportData(); })
      }, (item: TimeDimensionItem) => item.value)
    }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 12, bottom: 12 })
  }
  
  @Builder
  PieChartArea() {
    Column() {
      Text($r('app.string.reports_ratio')).fontSize(16).fontColor('#212121').fontWeight(FontWeight.Medium).margin({ bottom: 12 })
      if (this.reportData.length > 0) {
        PieChartComponent({ chartWidth: 300, chartHeight: 280, data: this.reportData, showLegend: true })
        if (this.summaryData) {
          Row() {
            Text('总金额: ¥' + this.formatAmount(this.summaryData.totalAmount)).fontSize(14).fontColor('#757575')
            Text(' | ').fontSize(14).fontColor('#E0E0E0')
            Text('总笔数: ' + this.summaryData.totalCount + '笔').fontSize(14).fontColor('#757575')
          }.margin({ top: 12 })
        }
      } else {
        Column() { Text($r('app.string.reports_no_data')).fontSize(14).fontColor('#757575') }
        .width('100%').height(280).justifyContent(FlexAlign.Center).backgroundColor('#FFFFFF').borderRadius(8)
      }
    }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(8).margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })
  }
  
  @Builder
  CategoryList() {
    Column() {
      Text('分类详情').fontSize(16).fontColor('#212121').fontWeight(FontWeight.Medium).width('100%').margin({ bottom: 12 })
      if (this.reportData.length > 0) {
        List() {
          ForEach(this.reportData, (item: CategoryStatBean, index: number) => {
            ListItem() {
              Row() {
                Text((index + 1).toString()).fontSize(14).fontColor('#757575').width(24)
                Text(item.categoryIcon).fontSize(24).width(32)
                Column() {
                  Text(item.categoryName).fontSize(14).fontColor('#212121').fontWeight(FontWeight.Medium)
                  Text(item.count + '笔').fontSize(12).fontColor('#757575').margin({ top: 2 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 8 })
                Column() {
                  Text('¥' + this.formatAmount(item.amount)).fontSize(14).fontColor('#212121').fontWeight(FontWeight.Medium)
                  Text(item.ratio.toFixed(1) + '%').fontSize(12).fontColor(item.categoryColor).margin({ top: 2 })
                }.alignItems(HorizontalAlign.End)
              }.width('100%').padding({ top: 12, bottom: 12 })
            }
          }, (item: CategoryStatBean) => item.categoryName)
        }.width('100%').layoutWeight(1).divider({ strokeWidth: 1, color: '#E0E0E0', startMargin: 48, endMargin: 16 })
      }
    }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(8).margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })
  }
  
  private loadReportData(): void {
    setTimeout(() => {
      this.reportData = this.generateMockData();
      this.summaryData = new CategoryStatSummaryBean(this.reportData);
    }, 500);
  }
  
  private generateMockData(): CategoryStatBean[] {
    const categories: CategoryData[] = [
      { name: '餐饮', icon: '🍽', color: '#FF9800' },
      { name: '交通', icon: '🚗', color: '#2196F3' },
      { name: '购物', icon: '🛍', color: '#E91E63' },
      { name: '娱乐', icon: '🎮', color: '#9C27B0' },
      { name: '医疗', icon: '🏥', color: '#F44336' },
      { name: '教育', icon: '📚', color: '#4CAF50' }
    ];
    const data = categories.map(cat => new CategoryStatBean(cat.name, cat.icon, cat.color, Math.random() * 3000 + 500, Math.floor(Math.random() * 20) + 1));
    data.sort((a, b) => b.amount - a.amount);
    return data;
  }
  
  private formatAmount(amount: number): string {
    if (amount >= 10000) return (amount / 10000).toFixed(2) + '万';
    return amount.toFixed(2);
  }
}
