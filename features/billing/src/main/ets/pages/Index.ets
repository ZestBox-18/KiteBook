/**
 * Copyright (C), 2026-05-22
 * @author ZestBox
 * @date 2026/05/22
 * @version 1.0
 * @description: 账单模块主页
 */

import { hdsMaterial, HdsNavigation, ScrollEffectType } from '@kit.UIDesignKit';
import {
  AppThemeState,
  BillBean,
  BillGroup,
  BillManager,
  BillTypeEnum,
  Clog,
  CommonConstants,
  SystemOptions,
  WindowUtil,
  billSyncController
} from 'base';
import { AppStorageV2, LengthMetrics, PersistenceV2, curves } from '@kit.ArkUI';
import { CapsuleSegmentButtonV2, SegmentButtonV2Items } from '@ohos.arkui.advanced.SegmentButtonV2';
import { ColorMetrics } from '@ohos.arkui.node';
import promptAction from '@ohos.promptAction';

const TAG: string = '[BillingIndex]';
const FILTER_ALL: string = 'all';
const FILTER_EXPENSE: string = BillTypeEnum.EXPENSE;
const FILTER_INCOME: string = BillTypeEnum.INCOME;

@Entry
@ComponentV2
export struct Index {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;
  @Local monthAnchor: number = new Date(new Date().getFullYear(), new Date().getMonth(), 1).getTime();
  @Local billFilter: string = FILTER_ALL;
  @Local billGroups: BillGroup[] = [];
  @Local totalExpense: number = 0;
  @Local totalIncome: number = 0;
  @Local totalBalance: number = 0;
  @Local totalCount: number = 0;
  @Local loading: boolean = false;

  private billSyncListenerId: number = -1;
  private readonly filterItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '全部' },
    { text: '支出' },
    { text: '收入' }
  ]);

  aboutToAppear(): void {
    if (this.billSyncListenerId < 0) {
      this.billSyncListenerId = billSyncController.register(() => {
        this.loadBills();
      });
    }
    this.loadBills();
  }

  aboutToDisappear(): void {
    if (this.billSyncListenerId >= 0) {
      billSyncController.unregister(this.billSyncListenerId);
      this.billSyncListenerId = -1;
    }
  }

  /**
   * 返回当前筛选条件对应的分段索引。
   */
  private getSelectedFilterIndex(): number {
    if (this.billFilter === FILTER_EXPENSE) {
      return 1;
    }
    if (this.billFilter === FILTER_INCOME) {
      return 2;
    }
    return 0;
  }

  /**
   * 根据分段索引切换账单类型筛选。
   */
  private updateFilterByIndex(selectedIndex: number): void {
    if (selectedIndex === 1) {
      this.billFilter = FILTER_EXPENSE;
    } else if (selectedIndex === 2) {
      this.billFilter = FILTER_INCOME;
    } else {
      this.billFilter = FILTER_ALL;
    }
    this.loadBills();
  }

  /**
   * 加载当前月份和筛选条件下的账单列表，并刷新统计概览。
   */
  private async loadBills(): Promise<void> {
    this.loading = true;
    try {
      const queryType: string = this.billFilter === FILTER_ALL ? '' : this.billFilter;
      const groups: BillGroup[] = await BillManager.getBillsByMonth(this.monthAnchor, queryType);
      this.billGroups = groups;
      this.updateSummary();
    } catch (err) {
      Clog.error(TAG, '加载账单失败', err);
      this.showToast('账单加载失败');
    } finally {
      this.loading = false;
    }
  }

  /**
   * 根据当前账单分组重新计算收支和笔数摘要。
   */
  private updateSummary(): void {
    let expense: number = 0;
    let income: number = 0;
    let count: number = 0;
    this.billGroups.forEach((group: BillGroup) => {
      expense += group.totalExpense;
      income += group.totalIncome;
      count += group.bills.length;
    });
    this.totalExpense = expense;
    this.totalIncome = income;
    this.totalBalance = income - expense;
    this.totalCount = count;
  }

  /**
   * 返回当前月份的标题文案。
   */
  private getMonthTitleText(): string {
    const monthDate: Date = new Date(this.monthAnchor);
    return `${monthDate.getFullYear()}年${monthDate.getMonth() + 1}月`;
  }

  /**
   * 切换月份，支持前后按月浏览账单。
   */
  private shiftMonth(offset: number): void {
    const currentMonth: Date = new Date(this.monthAnchor);
    this.monthAnchor = new Date(currentMonth.getFullYear(), currentMonth.getMonth() + offset, 1).getTime();
    this.loadBills();
  }

  /**
   * 判断传入月份是否是当前自然月，用于禁用“下个月”按钮。
   */
  private isCurrentMonth(): boolean {
    const current: Date = new Date();
    const anchorDate: Date = new Date(this.monthAnchor);
    return current.getFullYear() === anchorDate.getFullYear() && current.getMonth() === anchorDate.getMonth();
  }

  /**
   * 统一格式化金额文案。
   */
  private formatAmount(amount: number): string {
    const fixed: string = amount.toFixed(2);
    const parts: string[] = fixed.split('.');
    const integerPart: string = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    return `${integerPart}.${parts[1]}`;
  }

  /**
   * 按显隐语义返回带人民币符号的普通金额文案。
   */
  private getCurrencyText(amount: number): string {
    return `¥${this.formatAmount(amount)}`;
  }

  /**
   * 返回带正负号的结余文案。
   */
  private getSignedBalanceText(): string {
    const prefix: string = this.totalBalance >= 0 ? '+' : '-';
    return `${prefix}¥${this.formatAmount(Math.abs(this.totalBalance))}`;
  }

  /**
   * 返回某一天的分组标题，今天/昨天优先，其余显示完整日期。
   */
  private getGroupTitle(dateText: string): string {
    const date: Date = new Date(dateText);
    const now: Date = new Date();
    const todayStart: number = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const groupStart: number = new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime();
    if (groupStart === todayStart) {
      return '今天';
    }
    if (groupStart === todayStart - 24 * 60 * 60 * 1000) {
      return '昨天';
    }
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  /**
   * 返回分组头部的日流水概览。
   */
  private getGroupTurnoverText(group: BillGroup): string {
    const turnover: number = group.totalIncome - group.totalExpense;
    const prefix: string = turnover >= 0 ? '+' : '-';
    return `${prefix}¥${this.formatAmount(Math.abs(turnover))}`;
  }

  /**
   * 长按账单后弹出操作菜单，目前先支持删除。
   */
  private async showBillActionMenu(bill: BillBean): Promise<void> {
    try {
      const result: promptAction.ActionMenuSuccessResponse = await promptAction.showActionMenu({
        title: '账单操作',
        buttons: [
          { text: '删除账单', color: '#E55454' }
        ]
      });
      if (result.index === 0) {
        await this.deleteBill(bill.id);
      }
    } catch {
    }
  }

  /**
   * 删除账单并刷新当前月份列表。
   */
  private async deleteBill(billId: number): Promise<void> {
    try {
      await BillManager.deleteBill(billId);
      this.showToast('已删除账单');
      billSyncController.notifyBillChanged();
      await this.loadBills();
    } catch (err) {
      Clog.error(TAG, '删除账单失败', err);
      this.showToast('删除失败，请稍后重试');
    }
  }

  /**
   * 统一弹出提示文案。
   */
  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 1800
      });
    } catch {
    }
  }

  @Builder
  private SummaryCard() {
    ListItem() {
      Column({ space: 14 }) {
        Row() {
          Text(this.getMonthTitleText())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)

          Blank()

          Row({ space: 6 }) {
            Button() {
              SymbolGlyph($r('sys.symbol.chevron_left'))
                .fontSize(16)
                .fontWeight(this.optionSystem.iconThickness)
                .fontColor([this.themeState.fontPrimary as ResourceColor])
            }
            .width(32)
            .height(32)
            .padding(0)
            .backgroundColor(this.themeState.compBackgroundPrimary)
            .borderRadius(16)
            .stateEffect(false)
            .onClick(() => {
              this.shiftMonth(-1);
            })

            Button() {
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(16)
                .fontWeight(this.optionSystem.iconThickness)
                .fontColor([this.isCurrentMonth() ? this.themeState.fontSecondary as ResourceColor :
                  this.themeState.fontPrimary as ResourceColor])
            }
            .width(32)
            .height(32)
            .padding(0)
            .backgroundColor(this.themeState.compBackgroundPrimary)
            .borderRadius(16)
            .stateEffect(false)
            .enabled(!this.isCurrentMonth())
            .onClick(() => {
              if (!this.isCurrentMonth()) {
                this.shiftMonth(1);
              }
            })
          }
        }
        .width('100%')

        Row() {
          this.SummaryMetric('支出', this.getCurrencyText(this.totalExpense), '#E55454')
          this.SummaryDivider()
          this.SummaryMetric('收入', this.getCurrencyText(this.totalIncome), '#10B981')
          this.SummaryDivider()
          this.SummaryMetric('结余', this.getSignedBalanceText(),
            this.totalBalance >= 0 ? this.themeState.fontPrimary as ResourceColor : '#F97316')
        }
        .width('100%')

        Row() {
          Text(`共 ${this.totalCount} 笔`)
            .fontSize(13)
            .fontColor(this.themeState.fontSecondary)
          Blank()
          if (this.loading) {
            Text('加载中...')
              .fontSize(13)
              .fontColor(this.themeState.brand)
          }
        }
        .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor(this.themeState.compBackgroundPrimary)
      .borderRadius(22)
    }
  }

  @Builder
  private SummaryMetric(label: string, value: string, color: ResourceColor) {
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
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
  }

  @Builder
  private SummaryDivider() {
    Column()
      .width(1)
      .height(36)
      .backgroundColor(this.themeState.compDivider)
      .margin({ left: 12, right: 12 })
  }

  @Builder
  private FilterSection() {
    ListItem() {
      CapsuleSegmentButtonV2({
        items: this.filterItems,
        selectedIndex: this.getSelectedFilterIndex(),
        itemFontSize: LengthMetrics.vp(14),
        itemSelectedFontSize: LengthMetrics.vp(14),
        itemFontWeight: FontWeight.Medium,
        itemSelectedFontWeight: FontWeight.Bold,
        itemFontColor: ColorMetrics.resourceColor(this.themeState.fontPrimary as ResourceColor),
        itemSelectedFontColor: ColorMetrics.resourceColor(this.themeState.fontOnPrimary as ResourceColor),
        itemSelectedBackgroundColor: ColorMetrics.resourceColor(this.themeState.brand as ResourceColor),
        buttonBackgroundColor: ColorMetrics.resourceColor(this.themeState.compBackgroundPrimary as ResourceColor),
        buttonBorderRadius: LengthMetrics.vp(24),
        itemBorderRadius: LengthMetrics.vp(20),
        buttonPadding: LengthMetrics.vp(4),
        buttonMinHeight: LengthMetrics.vp(44),
        itemMinHeight: LengthMetrics.vp(36),
        $selectedIndex: (selectedIndex: number) => {
          this.updateFilterByIndex(selectedIndex);
        }
      })
      .width('100%')
    }
  }

  @Builder
  private BillListSection() {
    if (this.billGroups.length === 0) {
      ListItem() {
        Column({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.doc_text'))
            .fontSize(28)
            .fontWeight(this.optionSystem.iconThickness)
            .fontColor([this.themeState.fontSecondary as ResourceColor])
          Text('这个月份还没有账单')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.fontPrimary)
          Text('可以先去记一笔，再回来看月度账单')
            .fontSize(13)
            .fontColor(this.themeState.fontSecondary)
        }
        .width('100%')
        .padding({ top: 28, bottom: 28 })
      }
    } else {
      ForEach(this.billGroups, (group: BillGroup, groupIndex: number) => {
        ListItemGroup({
          header: this.BillGroupHeader(group),
          style: ListItemGroupStyle.CARD
        }) {
          ForEach(group.bills, (bill: BillBean, billIndex: number) => {
            ListItem() {
              this.BillRow(bill)
            }
            .opacity(1)
            .translate({ x: 0 })
            .animation({
              duration: 280,
              delay: (groupIndex * 3 + billIndex) * 45,
              curve: curves.springMotion(0.6, 0.9)
            })
            .gesture(
              LongPressGesture()
                .onAction(() => {
                  this.showBillActionMenu(bill);
                })
            )
          }, (bill: BillBean) => `${group.date}-${bill.id}`)
        }
        .divider({
          strokeWidth: 0.5,
          color: this.themeState.compDivider,
          startMargin: 52,
          endMargin: 16
        })
      }, (group: BillGroup) => group.date)
    }
  }

  @Builder
  private BillGroupHeader(group: BillGroup) {
    Row() {
      Text(this.getGroupTitle(group.date))
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontSecondary)
      Text(this.getGroupTurnoverText(group))
        .fontSize(12)
        .fontColor(this.themeState.brand)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
  }

  @Builder
  private BillRow(bill: BillBean) {
    Row() {
      SymbolGlyph(bill.getCategoryIcon())
        .fontSize(20)
        .fontColor([this.getBillTintColor(bill)])
        .width(36)
        .height(36)
        .borderRadius(8)
        .backgroundColor(this.getBillBgColor(bill))
        .padding(8)

      Column() {
        Text(bill.category)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
        Text(bill.remark.trim().length > 0 ? `${bill.getAccountDisplayText()} · ${bill.remark}` :
          bill.getAccountDisplayText())
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 2 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      Column() {
        Text(bill.formatAmount())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getBillTintColor(bill))
        Text(bill.getTimeString())
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  private getBillTintColor(bill: BillBean): ResourceColor {
    if (bill.type === BillTypeEnum.EXPENSE) {
      return '#E55454';
    }
    if (bill.type === BillTypeEnum.INCOME) {
      return '#10B981';
    }
    return this.themeState.brand as ResourceColor;
  }

  private getBillBgColor(bill: BillBean): ResourceColor {
    if (bill.type === BillTypeEnum.EXPENSE) {
      return '#FEE2E2';
    }
    if (bill.type === BillTypeEnum.INCOME) {
      return '#D1FAE5';
    }
    return '#DBEAFE';
  }

  build() {
    HdsNavigation(this.pageInfos) {
      List({ space: 10 }) {
        ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)
        this.SummaryCard()
        this.FilterSection()
        this.BillListSection()
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
      .contentEndOffset(this.winUtil.mainWindowInfo.navIndicatorHeight + CommonConstants.TAB_HEIGHT + 8)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .backgroundColor($r('app.color.start_window_background'))
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
            backgroundColor: $r('app.color.title_bar_bg')
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: {
            backgroundColor: $r('app.color.title_bar_bg')
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            }
          }
        }
      },
      content: {
        title: {
          mainTitle: '账单',
          subTitle: '按月份查看流水'
        }
      },
      avoidLayoutSafeArea: true
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }
}
