import { TimeDimensionEnum } from '../models/TimeDimensionEnum';
import { CategoryStatBean, CategoryStatSummaryBean } from '../models/CategoryStatBean';
import { PieChartComponent } from '../components/PieChartComponent';
import { ReportDataHelper } from '../utils/ReportDataHelper';
import { AppThemeState } from 'base';
import { AppStorageV2 } from '@kit.ArkUI';

interface TimeDimensionItem { label: Resource; value: TimeDimensionEnum; }

@ComponentV2
export struct CategoryReport {
  @Param refreshToken: number = 0;
  @Local currentTimeDimension: TimeDimensionEnum = TimeDimensionEnum.MONTH;
  @Local reportData: CategoryStatBean[] = [];
  @Local summaryData: CategoryStatSummaryBean | null = null;
  @Local loading: boolean = false;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  
  aboutToAppear(): void { this.loadReportData(); }

  @Monitor('refreshToken')
  onRefreshTokenChanged(): void {
    this.loadReportData();
  }
  
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
          .fontColor(this.currentTimeDimension === item.value ? this.themeState.fontOnPrimary : this.themeState.fontSecondary)
          .backgroundColor(this.currentTimeDimension === item.value ? this.themeState.brand : this.themeState.compBackgroundNeutral)
          .borderRadius(16).padding({ left: 16, right: 16, top: 6, bottom: 6 }).margin({ left: 4, right: 4 })
          .onClick(() => { this.currentTimeDimension = item.value; this.loadReportData(); })
      }, (item: TimeDimensionItem) => item.value)
    }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 12, bottom: 12 })
  }
  
  @Builder
  PieChartArea() {
    Column() {
      Text($r('app.string.reports_ratio')).fontSize(16).fontColor(this.themeState.fontPrimary).fontWeight(FontWeight.Medium).margin({ bottom: 12 })
      if (this.reportData.length > 0) {
        PieChartComponent({ chartWidth: 300, chartHeight: 280, data: this.reportData, showLegend: true })
        if (this.summaryData) {
          Row() {
            Text('总金额: ¥' + this.formatAmount(this.summaryData.totalAmount)).fontSize(14).fontColor(this.themeState.fontSecondary)
            Text(' | ').fontSize(14).fontColor(this.themeState.compDivider)
            Text('总笔数: ' + this.summaryData.totalCount + '笔').fontSize(14).fontColor(this.themeState.fontSecondary)
          }.margin({ top: 12 })
        }
      } else {
        Column() { Text(this.loading ? '加载中...' : $r('app.string.reports_no_data')).fontSize(14).fontColor(this.themeState.fontSecondary) }
        .width('100%').height(280).justifyContent(FlexAlign.Center).backgroundColor(this.themeState.compBackgroundPrimary).borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(8)
    .border({ width: 1, color: this.themeState.compDivider })
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
  }
  
  @Builder
  CategoryList() {
    Column() {
      Text('分类详情').fontSize(16).fontColor(this.themeState.fontPrimary).fontWeight(FontWeight.Medium).width('100%').margin({ bottom: 12 })
      if (this.reportData.length > 0) {
        List() {
          ForEach(this.reportData, (item: CategoryStatBean, index: number) => {
            ListItem() {
              Row() {
                Text((index + 1).toString()).fontSize(14).fontColor(this.themeState.fontSecondary).width(24)
                SymbolGlyph(item.categoryIcon)
                  .fontSize(20)
                  .fontColor([item.categoryColor])
                  .width(32)
                Column() {
                  Text(item.categoryName).fontSize(14).fontColor(this.themeState.fontPrimary).fontWeight(FontWeight.Medium)
                  Text(item.count + '笔').fontSize(12).fontColor(this.themeState.fontSecondary).margin({ top: 2 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 8 })
                Column() {
                  Text('¥' + this.formatAmount(item.amount)).fontSize(14).fontColor(this.themeState.fontPrimary).fontWeight(FontWeight.Medium)
                  Text(item.ratio.toFixed(1) + '%').fontSize(12).fontColor(item.categoryColor).margin({ top: 2 })
                }.alignItems(HorizontalAlign.End)
              }.width('100%').padding({ top: 12, bottom: 12 })
            }
          }, (item: CategoryStatBean) => item.categoryName)
        }.width('100%').layoutWeight(1).divider({ strokeWidth: 1, color: this.themeState.compDivider, startMargin: 48, endMargin: 16 })
      } else {
        Column() {
          Text(this.loading ? '正在读取分类统计...' : '当前时间范围内暂无支出分类数据')
            .fontSize(14)
            .fontColor(this.themeState.fontSecondary)
        }
        .width('100%')
        .height(180)
        .justifyContent(FlexAlign.Center)
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
      const reportData: CategoryStatBean[] = await ReportDataHelper.loadCategoryReport(this.currentTimeDimension);
      this.reportData = reportData;
      this.summaryData = new CategoryStatSummaryBean(reportData);
    } finally {
      this.loading = false;
    }
  }
  
  private formatAmount(amount: number): string {
    if (amount >= 10000) return (amount / 10000).toFixed(2) + '万';
    return amount.toFixed(2);
  }
}
