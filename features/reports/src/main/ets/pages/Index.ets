/**
 * Copyright (C), 2026-06-17
 * @author ZestBox
 * @date 2026/06/17
 * @version 1.0
 * @description: 报表主页面
 */

import { hdsMaterial, HdsNavigation, ScrollEffectType } from '@kit.UIDesignKit';
import { AppThemeState, BillBean, BillTypeEnum, CommonConstants, billSyncController } from 'base';
import { BillManager } from 'data_core';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { CapsuleSegmentButtonV2, SegmentButtonV2Items } from '@ohos.arkui.advanced.SegmentButtonV2';
import { ColorMetrics } from '@ohos.arkui.node';
import { Clog, WindowUtil } from 'kite_utils';

const TAG: string = '[ReportsIndex]';
const PAGE_PADDING: number = 16;
const CARD_RADIUS: number = 22;
const PERIOD_WEEK: number = 0;
const PERIOD_MONTH: number = 1;
const PERIOD_YEAR: number = 2;
const VIEW_CALENDAR: number = 0;
const VIEW_LIST: number = 1;
const TREND_CHART_WIDTH: number = 330;
const TREND_CHART_HEIGHT: number = 178;
const DONUT_SIZE: number = 136;
const CALENDAR_GRID_HEIGHT: number = 388;
const INCOME_COLOR: string = '#16A34A';
const EXPENSE_COLOR: string = '#EF4444';
const WARNING_COLOR: string = '#FF8A00';
const WEEK_LABELS: string[] = ['日', '一', '二', '三', '四', '五', '六'];

class ReportTrendPoint {
  label: string = '';
  income: number = 0;
  expense: number = 0;
  timestamp: number = 0;

  constructor(label: string, timestamp: number) {
    this.label = label;
    this.timestamp = timestamp;
  }
}

class CategoryInsight {
  name: string = '';
  amount: number = 0;
  ratio: number = 0;
  count: number = 0;
  color: string = '';
  icon: Resource = $r('sys.symbol.ellipsis_circle');

  constructor(name: string, icon: Resource, color: string) {
    this.name = name;
    this.icon = icon;
    this.color = color;
  }
}

class ChannelShare {
  name: string = '';
  amount: number = 0;
  ratio: number = 0;
  color: string = '';
  iconText: string = '';

  constructor(name: string, color: string, iconText: string) {
    this.name = name;
    this.color = color;
    this.iconText = iconText;
  }
}

class CalendarDayReport {
  dateKey: string = '';
  day: number = 0;
  lunarText: string = '';
  monthOffset: number = 0;
  income: number = 0;
  expense: number = 0;
  bills: BillBean[] = [];

  constructor(dateKey: string, day: number, lunarText: string, monthOffset: number) {
    this.dateKey = dateKey;
    this.day = day;
    this.lunarText = lunarText;
    this.monthOffset = monthOffset;
  }
}

@Entry
@ComponentV2
export struct Index {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local viewIndex: number = VIEW_LIST;
  @Local periodIndex: number = PERIOD_MONTH;
  @Local monthAnchor: number = new Date(new Date().getFullYear(), new Date().getMonth(), 1).getTime();
  @Local totalIncome: number = 0;
  @Local totalExpense: number = 0;
  @Local totalBalance: number = 0;
  @Local totalBillCount: number = 0;
  @Local autoBillCount: number = 0;
  @Local pendingCount: number = 0;
  @Local trendPoints: ReportTrendPoint[] = [];
  @Local categoryInsights: CategoryInsight[] = [];
  @Local channelShares: ChannelShare[] = [];
  @Local calendarDays: CalendarDayReport[] = [];
  @Local selectedDateKey: string = '';
  @Local selectedDateIncome: number = 0;
  @Local selectedDateExpense: number = 0;
  @Local selectedDateBills: BillBean[] = [];

  private billSyncListenerId: number = -1;
  private trendSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private trendContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.trendSettings);
  private donutSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private donutContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.donutSettings);
  private readonly periodItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '周' },
    { text: '月' },
    { text: '年' }
  ]);
  private readonly viewItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '日历' },
    { text: '列表' }
  ]);

  aboutToAppear(): void {
    if (this.billSyncListenerId < 0) {
      this.billSyncListenerId = billSyncController.register(() => {
        this.loadReportData();
      });
    }
    this.loadReportData();
  }

  aboutToDisappear(): void {
    if (this.billSyncListenerId >= 0) {
      billSyncController.unregister(this.billSyncListenerId);
      this.billSyncListenerId = -1;
    }
  }

  @Monitor('trendPoints')
  onTrendPointsChanged(): void {
    this.drawTrendChart();
  }

  @Monitor('categoryInsights')
  onCategoryInsightsChanged(): void {
    this.drawDonutChart();
  }

  private async loadReportData(): Promise<void> {
    try {
      const startTime: number = this.getRangeStartTime();
      const endTime: number = this.getRangeEndTime();
      const bills: BillBean[] = await BillManager.getBillsByRange(startTime, endTime, '');
      this.rebuildReportData(bills);
    } catch (err) {
      Clog.error(TAG, '加载报表数据失败', err);
      this.rebuildReportData([]);
    }
  }

  private rebuildReportData(bills: BillBean[]): void {
    let income: number = 0;
    let expense: number = 0;
    let autoCount: number = 0;
    let pending: number = 0;
    const categoryMap: Map<string, CategoryInsight> = new Map();
    const channelMap: Map<string, ChannelShare> = new Map();
    const trends: ReportTrendPoint[] = this.buildEmptyTrendPoints();
    const calendarMap: Map<string, CalendarDayReport> = new Map();

    bills.forEach((bill: BillBean) => {
      if (bill.type === BillTypeEnum.INCOME) {
        income += bill.amount;
      } else if (bill.type === BillTypeEnum.EXPENSE) {
        expense += bill.amount;
        this.mergeCategory(categoryMap, bill);
        this.mergeChannel(channelMap, bill);
      }
      if (bill.remark.indexOf('屏幕识别') >= 0 || bill.remark.indexOf('截图识别') >= 0) {
        autoCount += 1;
      }
      if (bill.remark.indexOf('待确认') >= 0) {
        pending += 1;
      }
      this.mergeTrendPoint(trends, bill);
      this.mergeCalendarDay(calendarMap, bill);
    });

    this.totalIncome = income;
    this.totalExpense = expense;
    this.totalBalance = income - expense;
    this.totalBillCount = bills.length;
    this.autoBillCount = autoCount;
    this.pendingCount = pending;
    this.trendPoints = trends;
    this.categoryInsights = this.sortCategoryInsights(categoryMap, expense);
    this.channelShares = this.sortChannelShares(channelMap, expense);
    this.calendarDays = this.buildCalendarDays(calendarMap);
    this.refreshSelectedDate(bills);
  }

  private mergeCategory(categoryMap: Map<string, CategoryInsight>, bill: BillBean): void {
    let insight: CategoryInsight | undefined = categoryMap.get(bill.category);
    if (!insight) {
      insight = new CategoryInsight(bill.category, bill.getCategoryIcon(), this.getCategoryColor(categoryMap.size));
      categoryMap.set(bill.category, insight);
    }
    insight.amount += bill.amount;
    insight.count += 1;
  }

  private mergeChannel(channelMap: Map<string, ChannelShare>, bill: BillBean): void {
    const name: string = bill.account.trim().length > 0 ? bill.account : '未指定';
    let channel: ChannelShare | undefined = channelMap.get(name);
    if (!channel) {
      channel = new ChannelShare(name, this.getChannelColor(channelMap.size), this.getChannelIconText(name));
      channelMap.set(name, channel);
    }
    channel.amount += bill.amount;
  }

  private mergeTrendPoint(trends: ReportTrendPoint[], bill: BillBean): void {
    const billDate: Date = new Date(bill.date);
    for (let index: number = 0; index < trends.length; index++) {
      if (this.isBillInTrendBucket(billDate, index)) {
        if (bill.type === BillTypeEnum.INCOME) {
          trends[index].income += bill.amount;
        } else if (bill.type === BillTypeEnum.EXPENSE) {
          trends[index].expense += bill.amount;
        }
        return;
      }
    }
  }

  private mergeCalendarDay(calendarMap: Map<string, CalendarDayReport>, bill: BillBean): void {
    const billDate: Date = new Date(bill.date);
    const dateKey: string = this.formatDateKey(billDate);
    let summary: CalendarDayReport | undefined = calendarMap.get(dateKey);
    if (!summary) {
      summary = new CalendarDayReport(dateKey, billDate.getDate(), this.getLunarLikeText(billDate), 0);
      calendarMap.set(dateKey, summary);
    }
    if (bill.type === BillTypeEnum.INCOME) {
      summary.income += bill.amount;
    } else if (bill.type === BillTypeEnum.EXPENSE) {
      summary.expense += bill.amount;
    }
    summary.bills.push(bill);
  }

  private sortCategoryInsights(categoryMap: Map<string, CategoryInsight>, totalExpense: number): CategoryInsight[] {
    const list: CategoryInsight[] = Array.from(categoryMap.values());
    list.sort((left: CategoryInsight, right: CategoryInsight) => right.amount - left.amount);
    list.forEach((item: CategoryInsight) => {
      item.ratio = totalExpense > 0 ? item.amount / totalExpense * 100 : 0;
    });
    return list.slice(0, 4);
  }

  private sortChannelShares(channelMap: Map<string, ChannelShare>, totalExpense: number): ChannelShare[] {
    const list: ChannelShare[] = Array.from(channelMap.values());
    list.sort((left: ChannelShare, right: ChannelShare) => right.amount - left.amount);
    list.forEach((item: ChannelShare) => {
      item.ratio = totalExpense > 0 ? item.amount / totalExpense * 100 : 0;
    });
    return list.slice(0, 3);
  }

  private getRangeStartTime(): number {
    const date: Date = new Date(this.monthAnchor);
    if (this.viewIndex === VIEW_CALENDAR) {
      return new Date(date.getFullYear(), date.getMonth(), 1).getTime();
    }
    if (this.periodIndex === PERIOD_WEEK) {
      const today: Date = new Date();
      const weekDay: number = (today.getDay() + 6) % 7;
      return new Date(today.getFullYear(), today.getMonth(), today.getDate() - weekDay).getTime();
    }
    if (this.periodIndex === PERIOD_YEAR) {
      return new Date(date.getFullYear(), 0, 1).getTime();
    }
    return new Date(date.getFullYear(), date.getMonth(), 1).getTime();
  }

  private getRangeEndTime(): number {
    const date: Date = new Date(this.monthAnchor);
    if (this.viewIndex === VIEW_CALENDAR) {
      return new Date(date.getFullYear(), date.getMonth() + 1, 1).getTime();
    }
    if (this.periodIndex === PERIOD_WEEK) {
      const startDate: Date = new Date(this.getRangeStartTime());
      return new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + 7).getTime();
    }
    if (this.periodIndex === PERIOD_YEAR) {
      return new Date(date.getFullYear() + 1, 0, 1).getTime();
    }
    return new Date(date.getFullYear(), date.getMonth() + 1, 1).getTime();
  }

  private buildEmptyTrendPoints(): ReportTrendPoint[] {
    if (this.periodIndex === PERIOD_WEEK) {
      const labels: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      const startDate: Date = new Date(this.getRangeStartTime());
      return labels.map((label: string, index: number) => {
        const day: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + index);
        return new ReportTrendPoint(label, day.getTime());
      });
    }
    if (this.periodIndex === PERIOD_YEAR) {
      const year: number = new Date(this.monthAnchor).getFullYear();
      const points: ReportTrendPoint[] = [];
      for (let month: number = 0; month < 12; month++) {
        points.push(new ReportTrendPoint(`${month + 1}月`, new Date(year, month, 1).getTime()));
      }
      return points;
    }
    const monthDate: Date = new Date(this.monthAnchor);
    const year: number = monthDate.getFullYear();
    const month: number = monthDate.getMonth();
    const lastDay: number = new Date(year, month + 1, 0).getDate();
    const dayMarks: number[] = [1, 6, 11, 16, 21, 26, lastDay];
    return dayMarks.map((day: number) => new ReportTrendPoint(`${month + 1}/${day}`, new Date(year, month, day).getTime()));
  }

  private isBillInTrendBucket(billDate: Date, bucketIndex: number): boolean {
    if (this.periodIndex === PERIOD_WEEK) {
      const startDate: Date = new Date(this.getRangeStartTime());
      const currentStart: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + bucketIndex);
      const currentEnd: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + bucketIndex + 1);
      return billDate.getTime() >= currentStart.getTime() && billDate.getTime() < currentEnd.getTime();
    }
    if (this.periodIndex === PERIOD_YEAR) {
      return billDate.getMonth() === bucketIndex;
    }
    const monthDate: Date = new Date(this.monthAnchor);
    const year: number = monthDate.getFullYear();
    const month: number = monthDate.getMonth();
    const dayMarks: number[] = [1, 6, 11, 16, 21, 26, new Date(year, month + 1, 0).getDate()];
    const startDay: number = dayMarks[bucketIndex];
    const endDay: number = bucketIndex === dayMarks.length - 1 ? dayMarks[bucketIndex] + 1 : dayMarks[bucketIndex + 1];
    const start: number = new Date(year, month, startDay).getTime();
    const end: number = new Date(year, month, endDay).getTime();
    return billDate.getTime() >= start && billDate.getTime() < end;
  }

  private changePeriod(index: number): void {
    this.periodIndex = index;
    this.loadReportData();
  }

  private changeView(index: number): void {
    this.viewIndex = index;
    if (this.viewIndex === VIEW_CALENDAR) {
      this.periodIndex = PERIOD_MONTH;
      this.ensureSelectedDateInMonth();
    }
    this.loadReportData();
  }

  private shiftCurrentRange(offset: number): void {
    const date: Date = new Date(this.monthAnchor);
    if (this.viewIndex === VIEW_CALENDAR) {
      this.monthAnchor = new Date(date.getFullYear(), date.getMonth() + offset, 1).getTime();
      this.ensureSelectedDateInMonth();
    } else if (this.periodIndex === PERIOD_YEAR) {
      this.monthAnchor = new Date(date.getFullYear() + offset, 0, 1).getTime();
    } else {
      this.monthAnchor = new Date(date.getFullYear(), date.getMonth() + offset, 1).getTime();
    }
    this.loadReportData();
  }

  private getRangeTitle(): string {
    const date: Date = new Date(this.monthAnchor);
    if (this.periodIndex === PERIOD_YEAR) {
      return `${date.getFullYear()}年`;
    }
    if (this.periodIndex === PERIOD_WEEK) {
      const startDate: Date = new Date(this.getRangeStartTime());
      const endDate: Date = new Date(this.getRangeEndTime() - 1);
      return `${startDate.getMonth() + 1}/${startDate.getDate()}-${endDate.getMonth() + 1}/${endDate.getDate()}`;
    }
    return `${date.getFullYear()}年${date.getMonth() + 1}月`;
  }

  private getMonthTitle(): string {
    const date: Date = new Date(this.monthAnchor);
    return `${date.getFullYear()}年${(date.getMonth() + 1).toString().padStart(2, '0')}月`;
  }

  private getMainTitle(): string {
    return this.viewIndex === VIEW_CALENDAR ? '日历报表' : '报表';
  }

  private getSubTitle(): string {
    return this.viewIndex === VIEW_CALENDAR ? '按日期查看每日收支' : '消费分析与识别洞察';
  }

  private getTrendTitle(): string {
    if (this.periodIndex === PERIOD_WEEK) {
      return '本周收支趋势';
    }
    if (this.periodIndex === PERIOD_YEAR) {
      return '全年收支趋势';
    }
    return '本月收支趋势';
  }

  private getAmountText(amount: number, signed: boolean = false): string {
    const absAmount: number = Math.abs(amount);
    const fixed: string = absAmount.toFixed(2);
    const parts: string[] = fixed.split('.');
    const integerPart: string = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    const prefix: string = signed ? (amount >= 0 ? '¥' : '-¥') : '¥';
    return `${prefix}${integerPart}.${parts[1]}`;
  }

  private formatDateKey(date: Date): string {
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
    const day: string = date.getDate().toString().padStart(2, '0');
    return `${date.getFullYear()}-${month}-${day}`;
  }

  private getSelectedDateTitle(): string {
    if (this.selectedDateKey.length === 0) {
      return '';
    }
    const date: Date = new Date(this.selectedDateKey);
    return `${(date.getMonth() + 1).toString().padStart(2, '0')}月${date.getDate().toString().padStart(2, '0')}日`;
  }

  private ensureSelectedDateInMonth(): void {
    const monthDate: Date = new Date(this.monthAnchor);
    const currentMonthKey: string =
      `${monthDate.getFullYear()}-${(monthDate.getMonth() + 1).toString().padStart(2, '0')}`;
    if (this.selectedDateKey.length === 0 || this.selectedDateKey.substring(0, 7) !== currentMonthKey) {
      const today: Date = new Date();
      if (today.getFullYear() === monthDate.getFullYear() && today.getMonth() === monthDate.getMonth()) {
        this.selectedDateKey = this.formatDateKey(today);
      } else {
        this.selectedDateKey = this.formatDateKey(monthDate);
      }
    }
  }

  private buildCalendarDays(calendarMap: Map<string, CalendarDayReport>): CalendarDayReport[] {
    const monthDate: Date = new Date(this.monthAnchor);
    const monthStart: Date = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1);
    const gridStart: Date =
      new Date(monthStart.getFullYear(), monthStart.getMonth(), monthStart.getDate() - monthStart.getDay());
    const days: CalendarDayReport[] = [];
    for (let index: number = 0; index < 42; index++) {
      const date: Date = new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + index);
      const dateKey: string = this.formatDateKey(date);
      const monthOffset: number =
        (date.getFullYear() - monthDate.getFullYear()) * 12 + date.getMonth() - monthDate.getMonth();
      const cached: CalendarDayReport | undefined = calendarMap.get(dateKey);
      const item: CalendarDayReport =
        new CalendarDayReport(dateKey, date.getDate(), this.getLunarLikeText(date), monthOffset);
      if (cached) {
        item.income = cached.income;
        item.expense = cached.expense;
        item.bills = cached.bills;
      }
      days.push(item);
    }
    return days;
  }

  private refreshSelectedDate(monthBills: BillBean[]): void {
    this.ensureSelectedDateInMonth();
    const selectedBills: BillBean[] = monthBills.filter((bill: BillBean) => {
      return this.formatDateKey(new Date(bill.date)) === this.selectedDateKey;
    });
    let income: number = 0;
    let expense: number = 0;
    selectedBills.forEach((bill: BillBean) => {
      if (bill.type === BillTypeEnum.INCOME) {
        income += bill.amount;
      } else if (bill.type === BillTypeEnum.EXPENSE) {
        expense += bill.amount;
      }
    });
    this.selectedDateBills = selectedBills;
    this.selectedDateIncome = income;
    this.selectedDateExpense = expense;
  }

  private selectCalendarDate(dateKey: string): void {
    this.selectedDateKey = dateKey;
    let target: CalendarDayReport | undefined = undefined;
    for (let index: number = 0; index < this.calendarDays.length; index++) {
      if (this.calendarDays[index].dateKey === dateKey) {
        target = this.calendarDays[index];
        break;
      }
    }
    if (!target) {
      this.selectedDateBills = [];
      this.selectedDateIncome = 0;
      this.selectedDateExpense = 0;
      return;
    }
    this.selectedDateBills = target.bills;
    this.selectedDateIncome = target.income;
    this.selectedDateExpense = target.expense;
  }

  private isSelectedCalendarDay(item: CalendarDayReport): boolean {
    return item.dateKey === this.selectedDateKey;
  }

  private getCalendarDayPrimaryColor(item: CalendarDayReport): ResourceColor {
    if (this.isSelectedCalendarDay(item)) {
      return this.themeState.fontOnPrimary as ResourceColor;
    }
    return item.monthOffset === 0 ? this.themeState.fontPrimary as ResourceColor : this.themeState.fontSecondary as ResourceColor;
  }

  private getCalendarDaySecondaryColor(item: CalendarDayReport): ResourceColor {
    if (this.isSelectedCalendarDay(item)) {
      return this.themeState.fontOnPrimary as ResourceColor;
    }
    if (item.lunarText === '芒种' || item.lunarText === '端午节' || item.lunarText === '夏至') {
      return INCOME_COLOR;
    }
    return item.monthOffset === 0 ? this.themeState.fontPrimary as ResourceColor : this.themeState.fontSecondary as ResourceColor;
  }

  private getLunarLikeText(date: Date): string {
    const month: number = date.getMonth() + 1;
    const day: number = date.getDate();
    if (month === 6 && day === 5) {
      return '芒种';
    }
    if (month === 6 && day === 19) {
      return '端午节';
    }
    if (month === 6 && day === 21) {
      return '夏至';
    }
    const chineseDays: string[] = [
      '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
      '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '廿十',
      '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十', '初一'
    ];
    return chineseDays[(day - 1) % chineseDays.length];
  }

  private getCalendarIncomeDays(): number {
    let count: number = 0;
    this.calendarDays.forEach((item: CalendarDayReport) => {
      if (item.monthOffset === 0 && item.income > 0) {
        count += 1;
      }
    });
    return count;
  }

  private getCalendarExpenseDays(): number {
    let count: number = 0;
    this.calendarDays.forEach((item: CalendarDayReport) => {
      if (item.monthOffset === 0 && item.expense > 0) {
        count += 1;
      }
    });
    return count;
  }

  private getAutoRatio(): number {
    return this.totalBillCount > 0 ? Math.round(this.autoBillCount / this.totalBillCount * 100) : 0;
  }

  private getSuccessRatio(): number {
    if (this.totalBillCount === 0) {
      return 0;
    }
    return Math.round((this.totalBillCount - this.pendingCount) / this.totalBillCount * 100);
  }

  private getTopChannelName(): string {
    if (this.channelShares.length === 0) {
      return '暂无';
    }
    return this.channelShares[0].name;
  }

  private getTopChannelRatio(): number {
    if (this.channelShares.length === 0) {
      return 0;
    }
    return Math.round(this.channelShares[0].ratio);
  }

  private getCategoryColor(index: number): string {
    const colors: string[] = [
      this.themeState.brand as string,
      INCOME_COLOR,
      WARNING_COLOR,
      this.themeState.iconSecondary as string,
      EXPENSE_COLOR
    ];
    return colors[index % colors.length];
  }

  private getChannelColor(index: number): string {
    const colors: string[] = [this.themeState.brand as string, INCOME_COLOR, WARNING_COLOR];
    return colors[index % colors.length];
  }

  private getChannelIconText(name: string): string {
    if (name.indexOf('支付宝') >= 0) {
      return '支';
    }
    if (name.indexOf('微信') >= 0) {
      return '微';
    }
    if (name.indexOf('卡') >= 0 || name.indexOf('银行') >= 0) {
      return '卡';
    }
    return name.length > 0 ? name.substring(0, 1) : '账';
  }

  build() {
    HdsNavigation(this.pageInfos) {
      Scroll() {
        Column({ space: 12 }) {
          Blank().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)
          this.TopFilterSection()
          if (this.viewIndex === VIEW_CALENDAR) {
            this.CalendarReportContent()
          } else {
            this.TrendCard()
            this.CategoryCard()
            this.AiInsightCard()
            this.ChannelCard()
          }
          Blank().height(this.winUtil.mainWindowInfo.navIndicatorHeight + CommonConstants.TAB_HEIGHT + 8)
        }
        .width('100%')
        .padding({ left: PAGE_PADDING, right: PAGE_PADDING })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .backgroundColor($r('[shared_assets].color.start_window_background'))
    .mode(NavigationMode.Stack)
    .titleBar({
      style: {
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR,
          blurEffectiveStartOffset: LengthMetrics.vp(0),
          blurEffectiveEndOffset: LengthMetrics.vp(20)
        },
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        },
        originalStyle: {
          backgroundStyle: {
            backgroundColor: $r('[shared_assets].color.title_bar_bg')
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('[shared_assets].color.text_primary'),
              subTitleColor: $r('[shared_assets].color.text_secondary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: {
            backgroundColor: $r('[shared_assets].color.title_bar_bg')
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('[shared_assets].color.text_primary'),
              subTitleColor: $r('[shared_assets].color.text_secondary')
            }
          }
        }
      },
      content: {
        title: {
          mainTitle: this.getMainTitle(),
          subTitle: this.getSubTitle()
        }
      },
      avoidLayoutSafeArea: true
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }

  @Builder
  private TopFilterSection() {
    Column({ space: 10 }) {
      Row() {
        if (this.viewIndex === VIEW_LIST) {
          this.PeriodSwitch()
        } else {
          Blank().layoutWeight(1)
        }
        this.ViewSwitch()
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row() {
        Row({ space: 8 }) {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(14)
              .fontColor([this.themeState.fontSecondary as ResourceColor])
          }
          .width(32)
          .height(32)
          .padding(0)
          .borderRadius(16)
          .backgroundColor(this.themeState.compBackgroundPrimary)
          .onClick(() => {
            this.shiftCurrentRange(-1);
          })

          Row({ space: 4 }) {
            Text(this.viewIndex === VIEW_CALENDAR ? this.getMonthTitle() : this.getRangeTitle())
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontPrimary)
            SymbolGlyph($r('sys.symbol.chevron_down'))
              .fontSize(12)
              .fontColor([this.themeState.fontSecondary as ResourceColor])
          }
          .height(32)
          .padding({ left: 16, right: 14 })
          .borderRadius(16)
          .backgroundColor(this.themeState.compBackgroundPrimary)

          Button() {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(14)
              .fontColor([this.themeState.fontSecondary as ResourceColor])
          }
          .width(32)
          .height(32)
          .padding(0)
          .borderRadius(16)
          .backgroundColor(this.themeState.compBackgroundPrimary)
          .onClick(() => {
            this.shiftCurrentRange(1);
          })
        }

        Blank()
        if (this.viewIndex === VIEW_CALENDAR) {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.list_bullet'))
              .fontSize(18)
              .fontColor([this.themeState.fontSecondary as ResourceColor])
            Text('筛选')
              .fontSize(15)
              .fontColor(this.themeState.fontSecondary)
          }
          .height(32)
          .padding({ left: 8 })
        }
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private PeriodSwitch() {
    CapsuleSegmentButtonV2({
      items: this.periodItems,
      selectedIndex: this.periodIndex,
      itemFontSize: LengthMetrics.vp(14),
      itemSelectedFontSize: LengthMetrics.vp(14),
      itemFontWeight: FontWeight.Medium,
      itemSelectedFontWeight: FontWeight.Bold,
      itemFontColor: ColorMetrics.resourceColor(this.themeState.fontPrimary as ResourceColor),
      itemSelectedFontColor: ColorMetrics.resourceColor(this.themeState.fontOnPrimary as ResourceColor),
      itemSelectedBackgroundColor: ColorMetrics.resourceColor(this.themeState.brand as ResourceColor),
      buttonBackgroundColor: ColorMetrics.resourceColor(this.themeState.compBackgroundPrimary as ResourceColor),
      buttonBorderRadius: LengthMetrics.vp(20),
      itemBorderRadius: LengthMetrics.vp(18),
      buttonPadding: LengthMetrics.vp(4),
      buttonMinHeight: LengthMetrics.vp(42),
      itemMinHeight: LengthMetrics.vp(34),
      $selectedIndex: (selectedIndex: number) => {
        this.changePeriod(selectedIndex);
      }
    })
    .width(168)
  }

  @Builder
  private ViewSwitch() {
    CapsuleSegmentButtonV2({
      items: this.viewItems,
      selectedIndex: this.viewIndex,
      itemFontSize: LengthMetrics.vp(14),
      itemSelectedFontSize: LengthMetrics.vp(14),
      itemFontWeight: FontWeight.Medium,
      itemSelectedFontWeight: FontWeight.Bold,
      itemFontColor: ColorMetrics.resourceColor(this.themeState.fontPrimary as ResourceColor),
      itemSelectedFontColor: ColorMetrics.resourceColor(this.themeState.fontOnPrimary as ResourceColor),
      itemSelectedBackgroundColor: ColorMetrics.resourceColor(this.themeState.brand as ResourceColor),
      buttonBackgroundColor: ColorMetrics.resourceColor(this.themeState.compBackgroundPrimary as ResourceColor),
      buttonBorderRadius: LengthMetrics.vp(20),
      itemBorderRadius: LengthMetrics.vp(18),
      buttonPadding: LengthMetrics.vp(4),
      buttonMinHeight: LengthMetrics.vp(42),
      itemMinHeight: LengthMetrics.vp(34),
      $selectedIndex: (selectedIndex: number) => {
        this.changeView(selectedIndex);
      }
    })
    .width(148)
  }

  @Builder
  private CalendarReportContent() {
    Column({ space: 12 }) {
      this.CalendarGridCard()
      this.SelectedDateDetailCard()
      this.CalendarInsightBar()
    }
    .width('100%')
  }

  @Builder
  private CalendarGridCard() {
    Column({ space: 12 }) {
      Row() {
        ForEach(WEEK_LABELS, (label: string) => {
          Text(label)
            .fontSize(14)
            .fontColor(label === '日' || label === '六' ? this.themeState.fontSecondary : this.themeState.fontPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (label: string) => label)
      }
      .width('100%')

      Grid() {
        ForEach(this.calendarDays, (item: CalendarDayReport) => {
          GridItem() {
            this.CalendarDayCell(item)
          }
        }, (item: CalendarDayReport) => item.dateKey)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .columnsGap(2)
      .rowsGap(4)
      .height(CALENDAR_GRID_HEIGHT)
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 16, bottom: 16 })
    .borderRadius(CARD_RADIUS)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private CalendarDayCell(item: CalendarDayReport) {
    Column({ space: 2 }) {
      Text(`${item.day}`)
        .fontSize(this.isSelectedCalendarDay(item) ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCalendarDayPrimaryColor(item))
      Text(item.lunarText)
        .fontSize(12)
        .fontColor(this.getCalendarDaySecondaryColor(item))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.isSelectedCalendarDay(item)) {
        Text(`收 ${this.getAmountText(item.income)}`)
          .fontSize(12)
          .fontColor(this.themeState.fontOnPrimary)
          .maxLines(1)
        Text(`支 ${this.getAmountText(item.expense)}`)
          .fontSize(12)
          .fontColor(this.themeState.fontOnPrimary)
          .maxLines(1)
      } else if (item.income > 0 || item.expense > 0) {
        if (item.income > 0) {
          Text(`+${item.income.toFixed(2)}`)
            .fontSize(12)
            .fontColor(INCOME_COLOR)
            .maxLines(1)
        }
        if (item.expense > 0) {
          Text(`-${item.expense.toFixed(2)}`)
            .fontSize(12)
            .fontColor(EXPENSE_COLOR)
            .maxLines(1)
        }
        this.CalendarAmountBars(item)
      } else {
        Blank().height(28)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 5, bottom: 5, left: 2, right: 2 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(10)
    .backgroundColor(this.isSelectedCalendarDay(item) ? this.themeState.brand as ResourceColor : Color.Transparent)
    .onClick(() => {
      this.selectCalendarDate(item.dateKey);
    })
  }

  @Builder
  private CalendarAmountBars(item: CalendarDayReport) {
    Row({ space: 2 }) {
      if (item.income > 0) {
        Divider()
          .width(item.expense > 0 ? 18 : 36)
          .height(3)
          .color(INCOME_COLOR)
      }
      if (item.expense > 0) {
        Divider()
          .width(item.income > 0 ? 18 : 36)
          .height(3)
          .color(EXPENSE_COLOR)
      }
    }
    .height(5)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private SelectedDateDetailCard() {
    Column({ space: 12 }) {
      Row() {
        Text('当天明细')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontPrimary)
        Blank()
        Text(this.getSelectedDateTitle())
          .fontSize(15)
          .fontColor(this.themeState.fontPrimary)
        Text(`收 ${this.getAmountText(this.selectedDateIncome)}`)
          .fontSize(15)
          .fontColor(INCOME_COLOR)
          .margin({ left: 10 })
        Text(`支 ${this.getAmountText(this.selectedDateExpense)}`)
          .fontSize(15)
          .fontColor(EXPENSE_COLOR)
          .margin({ left: 10 })
      }
      .width('100%')

      if (this.selectedDateBills.length === 0) {
        this.EmptyHint('当天没有账单')
      } else {
        ForEach(this.selectedDateBills.slice(0, 4), (bill: BillBean) => {
          this.CalendarBillRow(bill)
        }, (bill: BillBean) => `${bill.id}`)
      }

      if (this.selectedDateBills.length > 4) {
        Text('没有更多了')
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(CARD_RADIUS)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private CalendarBillRow(bill: BillBean) {
    Row({ space: 12 }) {
      SymbolGlyph(bill.getCategoryIcon())
        .fontSize(22)
        .fontColor([bill.type === BillTypeEnum.INCOME ? INCOME_COLOR : EXPENSE_COLOR])
        .width(42)
        .height(42)
        .padding(9)
        .borderRadius(12)
        .backgroundColor(this.themeState.compBackgroundNeutral)
      Column({ space: 3 }) {
        Text(bill.category)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
        Text(bill.remark.length > 0 ? bill.remark : bill.getAccountDisplayText())
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column({ space: 3 }) {
        Text(bill.formatAmount())
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(bill.type === BillTypeEnum.INCOME ? INCOME_COLOR : this.themeState.fontPrimary)
        Text(bill.getTimeString())
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(56)
  }

  @Builder
  private CalendarInsightBar() {
    Row({ space: 10 }) {
      SymbolGlyph($r('sys.symbol.lightbulb'))
        .fontSize(20)
        .fontColor([this.themeState.brand as ResourceColor])
      Text('本月有支出记录')
        .fontSize(15)
        .fontColor(this.themeState.fontSecondary)
      Text(`${this.getCalendarExpenseDays()}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(EXPENSE_COLOR)
      Text('天 / 收入记录')
        .fontSize(15)
        .fontColor(this.themeState.fontSecondary)
      Text(`${this.getCalendarIncomeDays()}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(INCOME_COLOR)
      Text('天')
        .fontSize(15)
        .fontColor(this.themeState.fontSecondary)
      Blank()
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(18)
        .fontColor([this.themeState.fontSecondary as ResourceColor])
    }
    .width('100%')
    .height(58)
    .padding({ left: 14, right: 14 })
    .borderRadius(16)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private TrendCard() {
    Column({ space: 12 }) {
      this.SectionTitle($r('sys.symbol.list_bullet'), this.getTrendTitle(), this.themeState.brand as ResourceColor)

      Row() {
        this.SummaryMetric('收入', this.getAmountText(this.totalIncome), INCOME_COLOR)
        Divider().vertical(true).height(40).color(this.themeState.compDivider)
        this.SummaryMetric('支出', this.getAmountText(this.totalExpense), EXPENSE_COLOR)
        Divider().vertical(true).height(40).color(this.themeState.compDivider)
        this.SummaryMetric('结余', this.getAmountText(this.totalBalance, true),
          this.totalBalance >= 0 ? INCOME_COLOR : this.themeState.brand as ResourceColor)
      }
      .width('100%')

      Canvas(this.trendContext)
        .width('100%')
        .height(TREND_CHART_HEIGHT)
        .onReady(() => {
          this.drawTrendChart();
        })

      Row({ space: 24 }) {
        this.LegendItem('收入', this.themeState.brand as ResourceColor)
        this.LegendItem('支出', EXPENSE_COLOR)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .borderRadius(CARD_RADIUS)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private CategoryCard() {
    Row({ space: 14 }) {
      Column({ space: 14 }) {
        this.SectionTitle($r('sys.symbol.list_bullet'), '支出分类', this.themeState.brand as ResourceColor)
        Stack() {
          Canvas(this.donutContext)
            .width(DONUT_SIZE)
            .height(DONUT_SIZE)
            .onReady(() => {
              this.drawDonutChart();
            })
          Column({ space: 2 }) {
            Text(this.getAmountText(this.totalExpense))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontPrimary)
            Text('总支出')
              .fontSize(12)
              .fontColor(this.themeState.fontSecondary)
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width(DONUT_SIZE)
        .height(DONUT_SIZE)
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 8 }) {
        Row() {
          Text('分类')
            .fontSize(12)
            .fontColor(this.themeState.fontSecondary)
            .layoutWeight(1)
          Text('金额')
            .fontSize(12)
            .fontColor(this.themeState.fontSecondary)
            .width(78)
            .textAlign(TextAlign.End)
          Text('占比')
            .fontSize(12)
            .fontColor(this.themeState.fontSecondary)
            .width(44)
            .textAlign(TextAlign.End)
        }
        .width('100%')

        if (this.categoryInsights.length === 0) {
          this.EmptyHint('暂无支出分类')
        } else {
          ForEach(this.categoryInsights, (item: CategoryInsight) => {
            this.CategoryRow(item)
          }, (item: CategoryInsight) => item.name)
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .borderRadius(CARD_RADIUS)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private AiInsightCard() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        this.SectionTitle($r('sys.symbol.wand_and_stars'), '智能识别洞察', this.themeState.brand as ResourceColor)
        SymbolGlyph($r('sys.symbol.questionmark_circle'))
          .fontSize(16)
          .fontColor([this.themeState.fontSecondary as ResourceColor])
      }
      .width('100%')

      Row({ space: 10 }) {
        this.InsightTile($r('sys.symbol.wand_and_stars'), '自动记账占比', `${this.getAutoRatio()}%`, '较上月 +6%', this.themeState.brand as ResourceColor)
        this.InsightTile($r('sys.symbol.checkmark_circle'), '识别成功率', `${this.getSuccessRatio()}%`, '较上月 +3%', INCOME_COLOR)
        this.InsightTile($r('sys.symbol.doc_text'), '待确认笔数', `${this.pendingCount}笔`, '去确认', WARNING_COLOR)
        this.InsightTile($r('sys.symbol.creditcard'), '常用支付渠道', this.getTopChannelName(),
          `占比 ${this.getTopChannelRatio()}%`, this.themeState.iconEmphasize as ResourceColor)
      }
      .width('100%')

      Row({ space: 10 }) {
        SymbolGlyph($r('sys.symbol.lightbulb'))
          .fontSize(20)
          .fontColor([WARNING_COLOR])
        Text(`本期 AI 已帮您识别 ${this.autoBillCount} 笔，节省 ${this.getSavedHoursText()} 小时`)
          .fontSize(14)
          .fontColor(this.themeState.fontSecondary)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(16)
          .fontColor([this.themeState.fontSecondary as ResourceColor])
      }
      .width('100%')
      .height(42)
      .padding({ left: 12, right: 12 })
      .borderRadius(12)
      .border({ width: 1, color: this.themeState.compDivider })
    }
    .width('100%')
    .padding(16)
    .borderRadius(CARD_RADIUS)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private ChannelCard() {
    Column({ space: 12 }) {
      Row() {
        this.SectionTitle($r('sys.symbol.creditcard'), '支付渠道占比', this.themeState.brand as ResourceColor)
        Blank()
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(18)
          .fontColor([this.themeState.fontSecondary as ResourceColor])
      }
      .width('100%')

      if (this.channelShares.length === 0) {
        this.EmptyHint('暂无支付渠道数据')
      } else {
        ForEach(this.channelShares, (item: ChannelShare) => {
          this.ChannelRow(item)
        }, (item: ChannelShare) => item.name)
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(CARD_RADIUS)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private SectionTitle(icon: Resource, title: string, color: ResourceColor) {
    Row({ space: 8 }) {
      SymbolGlyph(icon)
        .fontSize(22)
        .fontColor([color])
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.fontPrimary)
    }
  }

  @Builder
  private SummaryMetric(label: string, value: string, color: ResourceColor) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private LegendItem(label: string, color: ResourceColor) {
    Row({ space: 6 }) {
      Divider().width(28).height(2).color(color)
      Text(label)
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
    }
  }

  @Builder
  private CategoryRow(item: CategoryInsight) {
    Row({ space: 8 }) {
      SymbolGlyph(item.icon)
        .fontSize(18)
        .fontColor([item.color])
        .width(32)
        .height(32)
        .padding(7)
        .borderRadius(8)
        .backgroundColor(`${item.color}18`)
      Column({ space: 5 }) {
        Text(item.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Progress({ value: item.ratio, total: 100, type: ProgressType.Linear })
          .height(4)
          .color(item.color)
          .backgroundColor(this.themeState.compDivider)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(this.getAmountText(item.amount))
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)
        .width(78)
        .textAlign(TextAlign.End)
        .maxLines(1)

      Text(`${item.ratio.toFixed(1)}%`)
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
        .width(44)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(44)
  }

  @Builder
  private InsightTile(icon: Resource, label: string, value: string, desc: string, color: ResourceColor) {
    Column({ space: 6 }) {
      SymbolGlyph(icon)
        .fontSize(22)
        .fontColor([color])
      Text(label)
        .fontSize(11)
        .fontColor(this.themeState.fontSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(desc)
        .fontSize(11)
        .fontColor(this.themeState.fontSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .height(118)
    .padding({ left: 6, right: 6 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(12)
    .backgroundColor(this.themeState.compBackgroundNeutral)
  }

  @Builder
  private ChannelRow(item: ChannelShare) {
    Row({ space: 10 }) {
      Text(item.iconText)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.fontOnPrimary)
        .width(26)
        .height(26)
        .textAlign(TextAlign.Center)
        .borderRadius(7)
        .backgroundColor(item.color)
      Text(item.name)
        .fontSize(14)
        .fontColor(this.themeState.fontPrimary)
        .width(72)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Progress({ value: item.ratio, total: 100, type: ProgressType.Linear })
        .height(8)
        .color(item.color)
        .backgroundColor(this.themeState.compDivider)
        .layoutWeight(1)
      Text(`${Math.round(item.ratio)}%`)
        .fontSize(14)
        .fontColor(this.themeState.fontPrimary)
        .width(36)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(32)
  }

  @Builder
  private EmptyHint(text: string) {
    Text(text)
      .fontSize(14)
      .fontColor(this.themeState.fontSecondary)
      .width('100%')
      .height(72)
      .textAlign(TextAlign.Center)
  }

  private getSavedHoursText(): string {
    return (this.autoBillCount * 0.03).toFixed(1);
  }

  private drawTrendChart(): void {
    const chartWidth: number = TREND_CHART_WIDTH;
    const chartHeight: number = TREND_CHART_HEIGHT;
    const left: number = 42;
    const right: number = 8;
    const top: number = 10;
    const bottom: number = 32;
    const plotWidth: number = chartWidth - left - right;
    const plotHeight: number = chartHeight - top - bottom;
    const maxValue: number = Math.max(this.getMaxTrendAmount(), 1);

    this.trendContext.clearRect(0, 0, chartWidth, chartHeight);
    this.trendContext.strokeStyle = this.themeState.compDivider as string;
    this.trendContext.lineWidth = 1;
    this.trendContext.setLineDash([4, 5]);
    for (let index: number = 0; index < 4; index++) {
      const y: number = top + plotHeight * index / 3;
      this.trendContext.beginPath();
      this.trendContext.moveTo(left, y);
      this.trendContext.lineTo(chartWidth - right, y);
      this.trendContext.stroke();
      this.trendContext.fillStyle = this.themeState.fontSecondary as string;
      this.trendContext.font = '12px sans-serif';
      this.trendContext.textAlign = 'right';
      this.trendContext.fillText(`${Math.round(maxValue * (3 - index) / 3)}`, left - 8, y + 4);
    }
    this.trendContext.setLineDash([]);
    this.drawTrendLine('income', this.themeState.brand as string, left, top, plotWidth, plotHeight, maxValue);
    this.drawTrendLine('expense', EXPENSE_COLOR, left, top, plotWidth, plotHeight, maxValue);
    this.drawTrendLabels(left, top + plotHeight, plotWidth);
  }

  private drawTrendLine(type: string, color: string, left: number, top: number, plotWidth: number, plotHeight: number,
    maxValue: number): void {
    if (this.trendPoints.length === 0) {
      return;
    }
    this.trendContext.strokeStyle = color;
    this.trendContext.lineWidth = 2;
    this.trendContext.beginPath();
    this.trendPoints.forEach((item: ReportTrendPoint, index: number) => {
      const value: number = type === 'income' ? item.income : item.expense;
      const x: number = left + plotWidth * index / Math.max(this.trendPoints.length - 1, 1);
      const y: number = top + plotHeight * (1 - value / maxValue);
      if (index === 0) {
        this.trendContext.moveTo(x, y);
      } else {
        this.trendContext.lineTo(x, y);
      }
    });
    this.trendContext.stroke();

    this.trendPoints.forEach((item: ReportTrendPoint, index: number) => {
      const value: number = type === 'income' ? item.income : item.expense;
      const x: number = left + plotWidth * index / Math.max(this.trendPoints.length - 1, 1);
      const y: number = top + plotHeight * (1 - value / maxValue);
      this.trendContext.beginPath();
      this.trendContext.fillStyle = this.themeState.compBackgroundPrimary as string;
      this.trendContext.arc(x, y, 4, 0, Math.PI * 2);
      this.trendContext.fill();
      this.trendContext.strokeStyle = color;
      this.trendContext.lineWidth = 2;
      this.trendContext.stroke();
    });
  }

  private drawTrendLabels(left: number, baseline: number, plotWidth: number): void {
    this.trendContext.fillStyle = this.themeState.fontSecondary as string;
    this.trendContext.font = '12px sans-serif';
    this.trendContext.textAlign = 'center';
    this.trendPoints.forEach((item: ReportTrendPoint, index: number) => {
      const x: number = left + plotWidth * index / Math.max(this.trendPoints.length - 1, 1);
      this.trendContext.fillText(item.label, x, baseline + 24);
    });
  }

  private getMaxTrendAmount(): number {
    let maxValue: number = 0;
    this.trendPoints.forEach((item: ReportTrendPoint) => {
      maxValue = Math.max(maxValue, item.income, item.expense);
    });
    return maxValue;
  }

  private drawDonutChart(): void {
    const center: number = DONUT_SIZE / 2;
    const radius: number = 52;
    const lineWidth: number = 28;
    let startAngle: number = -Math.PI / 2;

    this.donutContext.clearRect(0, 0, DONUT_SIZE, DONUT_SIZE);
    this.donutContext.lineWidth = lineWidth;
    this.donutContext.strokeStyle = this.themeState.compDivider as string;
    this.donutContext.beginPath();
    this.donutContext.arc(center, center, radius, 0, Math.PI * 2);
    this.donutContext.stroke();

    if (this.categoryInsights.length === 0 || this.totalExpense <= 0) {
      return;
    }

    this.categoryInsights.forEach((item: CategoryInsight) => {
      const sweep: number = item.amount / this.totalExpense * Math.PI * 2;
      this.donutContext.beginPath();
      this.donutContext.strokeStyle = item.color;
      this.donutContext.arc(center, center, radius, startAngle, startAngle + sweep);
      this.donutContext.stroke();
      startAngle += sweep;
    });
  }
}
