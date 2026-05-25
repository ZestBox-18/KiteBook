import { BudgetAnalysisBean, BudgetAnalysisSummaryBean, BudgetStatusEnum } from '../models/BudgetAnalysisBean';
import { ReportDataHelper } from '../utils/ReportDataHelper';

@ComponentV2
export struct BudgetReport {
  @Param refreshToken: number = 0;
  @Local reportData: BudgetAnalysisBean[] = [];
  @Local summaryData: BudgetAnalysisSummaryBean | null = null;
  @Local currentPeriod: string = '';
  @Local currentMonthAnchor: number = 0;
  @Local loading: boolean = false;
  
  aboutToAppear(): void {
    this.currentMonthAnchor = new Date(new Date().getFullYear(), new Date().getMonth(), 1).getTime();
    this.currentPeriod = this.getCurrentPeriod();
    this.loadReportData();
  }

  @Monitor('refreshToken')
  onRefreshTokenChanged(): void {
    this.loadReportData();
  }
  
  build() {
    Column() {
      Row() {
        Text('预算周期: ' + this.currentPeriod).fontSize(16).fontColor('#212121').fontWeight(FontWeight.Medium)
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
      this.SummaryCard();
      this.BudgetList();
    }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
  }
  
  @Builder
  SummaryCard() {
    Column() {
      if (this.summaryData) {
        Row() {
          Column() {
            Text('总预算').fontSize(12).fontColor('#757575')
            Text('¥' + this.formatAmount(this.summaryData.totalBudget))
              .fontSize(18).fontColor('#2196F3').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
          Divider().vertical(true).height(40).color('#E0E0E0')
          Column() {
            Text($r('app.string.reports_budget_used')).fontSize(12).fontColor('#757575')
            Text('¥' + this.formatAmount(this.summaryData.totalUsed))
              .fontSize(18).fontColor('#FF9800').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
          Divider().vertical(true).height(40).color('#E0E0E0')
          Column() {
            Text($r('app.string.reports_budget_remaining')).fontSize(12).fontColor('#757575')
            Text('¥' + this.formatAmount(this.summaryData.totalRemaining))
              .fontSize(18).fontColor('#4CAF50').fontWeight(FontWeight.Bold).margin({ top: 4 })
          }.layoutWeight(1)
        }.width('100%').padding(16)
      }
    }.width('100%').backgroundColor('#FFFFFF').borderRadius(8).margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })
  }
  
  @Builder
  BudgetList() {
    Column() {
      Text('预算详情').fontSize(16).fontColor('#212121').fontWeight(FontWeight.Medium).width('100%').margin({ bottom: 12 })
      if (this.reportData.length > 0) {
        List() {
          ForEach(this.reportData, (item: BudgetAnalysisBean) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.budgetName).fontSize(14).fontColor('#212121').fontWeight(FontWeight.Medium).layoutWeight(1)
                  Text(this.getStatusText(item.budgetStatus)).fontSize(12).fontColor('#FFFFFF')
                    .backgroundColor(this.getStatusColor(item.budgetStatus)).borderRadius(4)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                }.width('100%').margin({ bottom: 8 })
                Stack() {
                  Row().width('100%').height(8).backgroundColor('#E0E0E0').borderRadius(4)
                  Row().width(Math.min(item.usageRate, 100) + '%').height(8)
                    .backgroundColor(this.getProgressColor(item.budgetStatus)).borderRadius(4)
                }.width('100%').margin({ bottom: 8 })
                Row() {
                  Text('预算: ¥' + this.formatAmount(item.budgetAmount)).fontSize(12).fontColor('#757575')
                  Blank()
                  Text('已用: ¥' + this.formatAmount(item.usedAmount)).fontSize(12).fontColor('#757575')
                  Blank()
                  if (item.budgetStatus === BudgetStatusEnum.EXCEEDED) {
                    Text('超支: ¥' + this.formatAmount(item.exceededAmount)).fontSize(12).fontColor('#F44336')
                  } else {
                    Text('剩余: ¥' + this.formatAmount(item.remainingAmount)).fontSize(12).fontColor('#4CAF50')
                  }
                }.width('100%')
              }.width('100%').padding({ top: 12, bottom: 12 })
            }
          }, (item: BudgetAnalysisBean) => item.budgetName)
        }.width('100%').layoutWeight(1).divider({ strokeWidth: 1, color: '#E0E0E0', startMargin: 16, endMargin: 16 })
      } else {
        Column() {
          Text(this.loading ? '正在读取预算数据...' : '当前月份还没有预算记录')
            .fontSize(14)
            .fontColor('#757575')
          if (!this.loading) {
            Text('预算表已接入真实数据，后续写入预算后这里会直接显示结果。')
              .fontSize(12)
              .fontColor('#9E9E9E')
              .margin({ top: 8 })
          }
        }
        .width('100%')
        .height(180)
        .justifyContent(FlexAlign.Center)
      }
    }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(8).margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })
  }
  
  private async loadReportData(): Promise<void> {
    this.loading = true;
    try {
      const reportData: BudgetAnalysisBean[] = await ReportDataHelper.loadBudgetReport(this.currentMonthAnchor);
      this.reportData = reportData;
      this.summaryData = new BudgetAnalysisSummaryBean(reportData);
    } finally {
      this.loading = false;
    }
  }
  
  private getCurrentPeriod(): string {
    const now = new Date();
    return now.getFullYear() + '年' + ((now.getMonth() + 1).toString().padStart(2, '0')) + '月';
  }
  
  private getStatusText(status: BudgetStatusEnum): string {
    if (status === BudgetStatusEnum.NORMAL) return '正常';
    if (status === BudgetStatusEnum.WARNING) return '预警';
    return '超支';
  }
  
  private getStatusColor(status: BudgetStatusEnum): string {
    if (status === BudgetStatusEnum.NORMAL) return '#4CAF50';
    if (status === BudgetStatusEnum.WARNING) return '#FF9800';
    return '#F44336';
  }
  
  private getProgressColor(status: BudgetStatusEnum): string {
    return this.getStatusColor(status);
  }
  
  private formatAmount(amount: number): string {
    if (amount >= 10000) return (amount / 10000).toFixed(2) + '万';
    return amount.toFixed(2);
  }
}
