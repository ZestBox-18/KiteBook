/**
 * Copyright (C), 2026-07-10
 * @author ZestBox
 * @date 2026/07/10
 * @version 3.0
 * @description: 月度预算管理与客观进度对比页面
 */

import {
  hdsMaterial,
  HdsAnimationMode,
  HdsNavDestination,
  HdsNavigationMenuItemOptions,
  ScrollEffectType
} from '@kit.UIDesignKit';
import {
  AppThemeState,
  BillBean,
  BillTypeEnum,
  BudgetBean,
  CategoryBean,
  CommonConstants,
  FabVisibilityState,
  budgetSyncController,
  billSyncController,
  mainTabController
} from 'base';
import { BillManager, BudgetManager, CategoryManager } from 'data_core';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { Clog, WindowUtil } from 'kite_utils';
import { BudgetProgressCalculator, BudgetProgressSummary } from '../utils';

const TAG: string = '[BudgetDetail]';
const WARNING_COLOR: string = '#F59E42';
const SUCCESS_COLOR: string = '#10B981';
const CARD_RADIUS: number = 28;
const MONTH_PICKER_MONTHS: string[] = [
  '01月',
  '02月',
  '03月',
  '04月',
  '05月',
  '06月',
  '07月',
  '08月',
  '09月',
  '10月',
  '11月',
  '12月'
];

class BudgetUsageItem {
  category: string = '';
  icon: Resource = $r('sys.symbol.ellipsis_circle');
  budgetAmount: number = 0;
  usedAmount: number = 0;

  constructor(category: string, icon: Resource, budgetAmount: number, usedAmount: number) {
    this.category = category;
    this.icon = icon;
    this.budgetAmount = budgetAmount;
    this.usedAmount = usedAmount;
  }
}

@ComponentV2
export struct BudgetDetail {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local fabVisibilityState: FabVisibilityState =
    AppStorageV2.connect(FabVisibilityState, 'fabVisibilityState', () => new FabVisibilityState())!;
  @Local monthAnchor: number = new Date(new Date().getFullYear(), new Date().getMonth(), 1).getTime();
  @Local monthText: string = '';
  @Local totalBudget: number = 0;
  @Local totalUsed: number = 0;
  @Local items: BudgetUsageItem[] = [];
  @Local progressSummary: BudgetProgressSummary = new BudgetProgressSummary();
  @Local loading: boolean = false;
  @Local isEditorVisible: boolean = false;
  @Local isMonthPickerVisible: boolean = false;
  @Local editingCategory: string = '';
  @Local editingAmountText: string = '';
  @Local pickerYearText: string = '';
  @Local pickerMonthText: string = '';
  private billSyncListenerId: number = -1;
  private budgetSyncListenerId: number = -1;

  aboutToAppear(): void {
    this.fabVisibilityState.visible = false;
    if (this.billSyncListenerId < 0) {
      this.billSyncListenerId = billSyncController.register(() => {
        this.loadBudgetData();
      });
    }
    if (this.budgetSyncListenerId < 0) {
      this.budgetSyncListenerId = budgetSyncController.register(() => {
        this.loadBudgetData();
      });
    }
    this.loadBudgetData();
  }

  aboutToDisappear(): void {
    this.fabVisibilityState.visible = true;
    if (this.billSyncListenerId >= 0) {
      billSyncController.unregister(this.billSyncListenerId);
      this.billSyncListenerId = -1;
    }
    if (this.budgetSyncListenerId >= 0) {
      budgetSyncController.unregister(this.budgetSyncListenerId);
      this.budgetSyncListenerId = -1;
    }
  }

  private buildMonthText(): string {
    const date: Date = new Date(this.monthAnchor);
    return `${date.getFullYear()}年${date.getMonth() + 1}月`;
  }

  private shiftMonth(offset: number): void {
    const current: Date = new Date(this.monthAnchor);
    this.monthAnchor = new Date(current.getFullYear(), current.getMonth() + offset, 1).getTime();
    this.closeEditor();
    this.loadBudgetData();
  }

  private openMonthPicker(): void {
    const selected: Date = new Date(this.monthAnchor);
    this.pickerYearText = `${selected.getFullYear()}年`;
    const monthNumber: number = selected.getMonth() + 1;
    this.pickerMonthText = `${monthNumber < 10 ? '0' : ''}${monthNumber}月`;
    this.isMonthPickerVisible = true;
  }

  private closeMonthPicker(): void {
    this.isMonthPickerVisible = false;
  }

  private getYearOptions(): string[] {
    const currentYear: number = new Date().getFullYear();
    const years: string[] = [];
    for (let year: number = 1970; year <= currentYear; year++) {
      years.push(`${year}年`);
    }
    return years;
  }

  private getMonthPickerRange(): string[][] {
    return [this.getYearOptions(), MONTH_PICKER_MONTHS];
  }

  private buildPickerMonthAnchor(): number {
    const year: number = Number(this.pickerYearText.replace('年', ''));
    const month: number = Number(this.pickerMonthText.replace('月', ''));
    return new Date(year, month - 1, 1).getTime();
  }

  private confirmMonthPicker(): void {
    const nextMonthAnchor: number = this.buildPickerMonthAnchor();
    const now: Date = new Date();
    const currentMonthAnchor: number = new Date(now.getFullYear(), now.getMonth(), 1).getTime();
    if (nextMonthAnchor > currentMonthAnchor) {
      this.showToast('不能选择未来月份');
      return;
    }
    this.monthAnchor = nextMonthAnchor;
    this.closeMonthPicker();
    this.closeEditor();
    this.loadBudgetData();
  }

  private getTitleMenu(): HdsNavigationMenuItemOptions[] {
    return [{
      content: {
        icon: $r('sys.symbol.calendar'),
        label: '切换月份',
        isEnabled: true,
        action: () => {
          this.openMonthPicker();
        }
      }
    }];
  }

  private isCurrentMonth(): boolean {
    const now: Date = new Date();
    const selected: Date = new Date(this.monthAnchor);
    return now.getFullYear() === selected.getFullYear() && now.getMonth() === selected.getMonth();
  }

  private async loadBudgetData(): Promise<void> {
    this.loading = true;
    this.monthText = this.buildMonthText();
    try {
      const selectedDate: Date = new Date(this.monthAnchor);
      const monthEnd: number = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, 1).getTime();
      const result: [BudgetBean[], BillBean[], CategoryBean[]] = await Promise.all([
        BudgetManager.getBudgetsByMonth(BudgetManager.buildMonthKey(this.monthAnchor)),
        BillManager.getBillsByRange(this.monthAnchor, monthEnd, BillTypeEnum.EXPENSE),
        CategoryManager.getCategoriesByType(BillTypeEnum.EXPENSE)
      ]);
      this.rebuildUsageItems(result[0], result[1], result[2]);
    } catch (err) {
      Clog.error(TAG, '加载预算详情失败', err);
      this.items = [];
      this.totalBudget = 0;
      this.totalUsed = 0;
      this.progressSummary = new BudgetProgressSummary();
    } finally {
      this.loading = false;
    }
  }

  private rebuildUsageItems(budgets: BudgetBean[], bills: BillBean[], categories: CategoryBean[]): void {
    const budgetMap: Map<string, number> = new Map();
    budgets.forEach((budget: BudgetBean) => {
      budgetMap.set(budget.category, budget.amount);
    });
    const usedMap: Map<string, number> = new Map();
    bills.forEach((bill: BillBean) => {
      usedMap.set(bill.category, (usedMap.get(bill.category) ?? 0) + bill.amount);
    });

    const usageItems: BudgetUsageItem[] = [];
    categories.forEach((category: CategoryBean) => {
      usageItems.push(new BudgetUsageItem(
        category.name,
        category.getIconResource(),
        budgetMap.get(category.name) ?? 0,
        usedMap.get(category.name) ?? 0
      ));
    });
    usageItems.sort((first: BudgetUsageItem, second: BudgetUsageItem) => {
      if (first.budgetAmount > 0 && second.budgetAmount <= 0) {
        return -1;
      }
      if (first.budgetAmount <= 0 && second.budgetAmount > 0) {
        return 1;
      }
      return second.usedAmount - first.usedAmount;
    });
    this.items = usageItems;

    let budgetTotal: number = 0;
    budgets.forEach((budget: BudgetBean) => {
      budgetTotal += budget.amount;
    });
    let usedTotal: number = 0;
    bills.forEach((bill: BillBean) => {
      usedTotal += bill.amount;
    });
    this.totalBudget = budgetTotal;
    this.totalUsed = usedTotal;
    this.progressSummary = BudgetProgressCalculator.build(this.monthAnchor, budgetTotal, usedTotal, Date.now());
  }

  private openEditor(item: BudgetUsageItem): void {
    const uiContext: UIContext = this.getUIContext();
    uiContext.animateTo({ duration: 0 }, () => {
      this.editingCategory = item.category;
      this.editingAmountText = item.budgetAmount > 0 ? item.budgetAmount.toFixed(2) : '';
    });
    uiContext.animateTo({ duration: 0 }, () => {
      this.isEditorVisible = true;
    });
  }

  private openCategoryPicker(): void {
    if (this.items.length === 0) {
      this.showToast('暂无可设置的支出分类');
      return;
    }
    const firstItem: BudgetUsageItem = this.items[0];
    const uiContext: UIContext = this.getUIContext();
    uiContext.animateTo({ duration: 0 }, () => {
      this.editingCategory = firstItem.category;
      this.editingAmountText = firstItem.budgetAmount > 0 ? firstItem.budgetAmount.toFixed(2) : '';
    });
    uiContext.animateTo({ duration: 0 }, () => {
      this.isEditorVisible = true;
    });
  }

  private selectCategory(item: BudgetUsageItem): void {
    this.editingCategory = item.category;
    this.editingAmountText = item.budgetAmount > 0 ? item.budgetAmount.toFixed(2) : '';
  }

  private closeEditor(): void {
    this.isEditorVisible = false;
    this.editingCategory = '';
    this.editingAmountText = '';
  }

  private async saveBudget(): Promise<void> {
    const normalized: string = this.editingAmountText.trim();
    const amount: number = normalized.length === 0 ? 0 : Number(normalized);
    if (!Number.isFinite(amount) || amount < 0) {
      this.showToast('请输入正确的预算金额');
      return;
    }
    try {
      await BudgetManager.saveBudget(
        this.editingCategory,
        amount,
        BudgetManager.buildMonthKey(this.monthAnchor)
      );
      this.closeEditor();
      await this.loadBudgetData();
      budgetSyncController.notifyBudgetChanged();
      this.showToast(amount > 0 ? '预算已保存' : '预算已清除');
    } catch (err) {
      Clog.error(TAG, '保存预算失败', err);
      this.showToast('预算保存失败');
    }
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch (err) {
      Clog.warn(TAG, 'Toast 显示失败', err);
    }
  }

  private formatAmount(amount: number): string {
    const fixed: string = Math.abs(amount).toFixed(2);
    const parts: string[] = fixed.split('.');
    const integerPart: string = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    const prefix: string = amount < 0 ? '-' : '';
    return `${prefix}¥${integerPart}.${parts[1]}`;
  }

  private formatAmountSmart(amount: number): string {
    const absoluteAmount: number = Math.abs(amount);
    const decimalPart: number = absoluteAmount - Math.floor(absoluteAmount);
    const fractionDigits: number = decimalPart < 0.005 ? 0 : 2;
    const fixed: string = absoluteAmount.toFixed(fractionDigits);
    const parts: string[] = fixed.split('.');
    const integerPart: string = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    const prefix: string = amount < 0 ? '-' : '';
    if (fractionDigits === 0) {
      return `${prefix}¥${integerPart}`;
    }
    return `${prefix}¥${integerPart}.${parts[1]}`;
  }

  private formatPercent(value: number): string {
    return `${value.toFixed(1)}%`;
  }

  private formatSignedPercent(value: number): string {
    const prefix: string = value > 0 ? '+' : '';
    return `${prefix}${value.toFixed(1)}%`;
  }

  private getRingProgress(): number {
    return Math.min(100, Math.max(0, this.progressSummary.usagePercent));
  }

  private getCategoryUsagePercent(item: BudgetUsageItem): number {
    return BudgetProgressCalculator.getCategoryUsagePercent(item.budgetAmount, item.usedAmount);
  }

  private getCategoryProgressValue(item: BudgetUsageItem): number {
    return Math.min(100, Math.max(0, this.getCategoryUsagePercent(item)));
  }

  private getCategoryDifference(item: BudgetUsageItem): number {
    return this.getCategoryUsagePercent(item) - this.progressSummary.timeProgressPercent;
  }

  private getCategoryDifferenceText(item: BudgetUsageItem): string {
    const difference: number = this.getCategoryDifference(item);
    if (Math.abs(difference) < 0.05) {
      return '与时间进度一致';
    }
    const direction: string = difference > 0 ? '高于' : '低于';
    return `${direction}时间进度 ${Math.abs(difference).toFixed(1)}%`;
  }

  private getDifferenceDescription(): string {
    const difference: number = this.progressSummary.progressDifference;
    if (Math.abs(difference) < 0.05) {
      return '预算消耗与时间进度一致';
    }
    const direction: string = difference > 0 ? '领先' : '低于';
    return `预算消耗${direction}时间进度 ${Math.abs(difference).toFixed(1)} 个百分点`;
  }

  build() {
    HdsNavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        List({ space: 12 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)
          ListItem() {
            this.MonthSwitcher()
          }

          ListItem() {
            this.MonthOverviewCard()
          }

          ListItem() {
            this.ProgressComparisonCard()
          }

          ListItem() {
            this.CategoryBudgetCard()
          }
        }
        .width('100%')
        .height('100%')
        .padding({ left: 18, right: 18 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .contentEndOffset(82 + this.winUtil.mainWindowInfo.navIndicatorHeight)

        Button() {
          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.slider_horizontal_2')).fontSize(20)
              .fontColor([this.themeState.fontOnPrimary as ResourceColor])
            Text('调整预算').fontSize(16).fontWeight(FontWeight.Bold).fontColor(this.themeState.fontOnPrimary)
          }
        }
        .width('78%')
        .height(54)
        .padding(0)
        .borderRadius(27)
        .backgroundColor(this.themeState.brand as ResourceColor)
        .shadow({ radius: 18, color: '#2245AEF5', offsetY: 8 })
        .margin({ bottom: this.winUtil.mainWindowInfo.navIndicatorHeight + 16 })
        .onClick(() => {
          this.openCategoryPicker();
        })
      }
      .width('100%').height('100%')
      .backgroundColor($r('[shared_assets].color.start_window_background'))
    }
    .titleBar({
      padding: {
        start: LengthMetrics.vp(20),
        end: LengthMetrics.vp(20)
      },
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
          backgroundStyle: { backgroundColor: $r('[shared_assets].color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('[shared_assets].color.text_primary'),
              subTitleColor: $r('[shared_assets].color.text_secondary')
            },
            backIconStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              iconColor: $r('[shared_assets].color.text_primary')
            },
            menuStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              textColor: $r('[shared_assets].color.text_secondary'),
              iconColor: $r('[shared_assets].color.text_primary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: { backgroundColor: $r('[shared_assets].color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('[shared_assets].color.text_primary'),
              subTitleColor: $r('[shared_assets].color.text_secondary')
            },
            backIconStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              iconColor: $r('[shared_assets].color.text_primary')
            },
            menuStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              iconColor: $r('[shared_assets].color.text_primary')
            }
          }
        }
      },
      content: {
        title: { mainTitle: '预算管理', subTitle: '规划支出，安心生活' },
        menu: { value: this.getTitleMenu(), maxCount: 1 }
      },
      avoidLayoutSafeArea: true
    })
    .bindSheet($$this.isEditorVisible, this.BudgetEditorSheet(), {
      height: 520,
      preferType: SheetType.BOTTOM,
      showClose: false,
      enableFloatingDragBar: true
    })
    .bindSheet($$this.isMonthPickerVisible, this.MonthPickerSheet(), {
      height: 360,
      preferType: SheetType.BOTTOM,
      showClose: false,
      enableFloatingDragBar: true
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .onBackPressed(() => {
      mainTabController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
      return false;
    })
  }

  @Builder
  private MonthSwitcher() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(28)
          .fontColor([this.themeState.fontPrimary as ResourceColor])
      }
      .width(40)
      .height(40)
      .padding(0)
      .borderRadius(20)
      .backgroundColor(this.themeState.compBackgroundPrimary)
      .onClick(() => {
        this.shiftMonth(-1);
      })

      Text(this.monthText)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.fontPrimary)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(28)
          .fontColor([this.isCurrentMonth() ? this.themeState.fontSecondary as ResourceColor :
            this.themeState.fontPrimary as ResourceColor])
      }
      .width(40)
      .height(40)
      .padding(0)
      .borderRadius(20)
      .backgroundColor(this.themeState.compBackgroundPrimary)
      .enabled(!this.isCurrentMonth())
      .onClick(() => {
        this.shiftMonth(1);
      })
    }
    .width('100%').padding({ left: 2, right: 2 })
  }

  @Builder
  private MonthOverviewCard() {
    Column() {
      Row({ space: 12 }) {
        Column({ space: 12 }) {
          Text('本月总预算').fontSize(16).fontColor(this.themeState.fontPrimary)
          Text(this.formatAmountSmart(this.totalBudget))
            .fontSize(42)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.brand)
            .maxLines(1)
            .width('100%')
            .minFontSize(12)
            .maxFontSize(42)
            .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Stack() {
          Progress({ value: this.getRingProgress(), total: 100, type: ProgressType.Ring })
            .width(126).height(126).color(this.themeState.brand).backgroundColor('#E7ECF4')
          Column({ space: 5 }) {
            Text('预算进度').fontSize(14).fontColor(this.themeState.fontSecondary)
            Text(this.formatPercent(this.progressSummary.usagePercent)).fontSize(22).fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.brand)
          }.alignItems(HorizontalAlign.Center)
        }
        .width(130)
        .height(130)

        Row() {
          Divider().vertical(true).height(76).color(this.themeState.compDivider)
          Column({ space: 8 }) {
            Text('日均可用').fontSize(16).fontColor(this.themeState.fontSecondary)
            Text(this.formatAmountSmart(this.progressSummary.dailyAvailableAmount))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.brand)
              .maxLines(1)
              .width('100%')
              .textAlign(TextAlign.Center)
              .minFontSize(11)
              .maxFontSize(24)
              .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(142)
      .alignItems(VerticalAlign.Center)

      Divider().color(this.themeState.compDivider).margin({ top: 14, bottom: 12 })

      Row() {
        Row() {
          Text('已使用').fontSize(15).fontColor(this.themeState.fontSecondary)
            .width(58).textAlign(TextAlign.End)
          Text(this.formatAmountSmart(this.totalUsed))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)
            .maxLines(1)
            .layoutWeight(1)
            .margin({ left: 22 })
            .minFontSize(11)
            .maxFontSize(24)
            .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
        }
        .layoutWeight(1)
        .padding({ left: 18, right: 10 })
        .alignItems(VerticalAlign.Center)

        Divider().vertical(true).height(36).color(this.themeState.compDivider)

        Row() {
          Text('剩余').fontSize(15).fontColor(this.themeState.fontSecondary)
            .width(40).textAlign(TextAlign.End)
          Text(this.formatAmountSmart(this.progressSummary.remainingAmount))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(SUCCESS_COLOR)
            .maxLines(1)
            .layoutWeight(1)
            .margin({ left: 22 })
            .minFontSize(11)
            .maxFontSize(24)
            .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
        }
        .layoutWeight(1)
        .padding({ left: 22, right: 4 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(44)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(260)
    .padding({
      left: 24,
      right: 24,
      top: 26,
      bottom: 20
    })
    .borderRadius(CARD_RADIUS)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private ProgressComparisonCard() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 5 }) {
          Text('时间进度').fontSize(12).fontColor(this.themeState.fontSecondary)
          Text(this.formatPercent(this.progressSummary.timeProgressPercent)).fontSize(18).fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.brand).maxLines(1)
        }.layoutWeight(1).alignItems(HorizontalAlign.Center)

        Divider().vertical(true).height(42).color(this.themeState.compDivider)
        Column({ space: 5 }) {
          Text('预算进度').fontSize(12).fontColor(this.themeState.fontSecondary)
          Text(this.formatPercent(this.progressSummary.usagePercent)).fontSize(18).fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.brand).maxLines(1)
        }.layoutWeight(1).alignItems(HorizontalAlign.Center)

        Divider().vertical(true).height(42).color(this.themeState.compDivider)
        Column({ space: 5 }) {
          Text('进度差').fontSize(12).fontColor(this.themeState.fontSecondary)
          Text(this.formatSignedPercent(this.progressSummary.progressDifference))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.progressSummary.progressDifference > 0 ? WARNING_COLOR : this.themeState.fontSecondary)
            .maxLines(1)
        }.layoutWeight(1).alignItems(HorizontalAlign.Center)
      }.width('100%')

      Divider().color(this.themeState.compDivider)
      Text(this.getDifferenceDescription()).fontSize(12).fontColor(this.themeState.fontSecondary)
        .width('100%').textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 18,
      bottom: 16
    })
    .borderRadius(CARD_RADIUS)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private CategoryBudgetCard() {
    Column() {
      Row() {
        Text('分类预算').fontSize(18).fontWeight(FontWeight.Bold).fontColor(this.themeState.fontPrimary)
        Blank()
        Row({ space: 4 }) {
          Text('管理').fontSize(14).fontWeight(FontWeight.Medium).fontColor(this.themeState.brand)
          SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(20).fontColor([this.themeState.brand as ResourceColor])
            .width(24).height(24)
        }.onClick(() => {
          this.openCategoryPicker();
        })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 14,
        bottom: 7
      })

      if (this.loading) {
        this.EmptyState('正在读取预算数据…')
      } else if (this.items.length === 0) {
        this.EmptyState('暂无支出分类，请先在分类管理中添加')
      } else {
        ForEach(this.items, (item: BudgetUsageItem, index: number) => {
          this.BudgetRow(item)
          if (index < this.items.length - 1) {
            Divider().color(this.themeState.compDivider).margin({ left: 62, right: 16 })
          }
        }, (item: BudgetUsageItem) => item.category)
      }
    }
    .width('100%').borderRadius(CARD_RADIUS).backgroundColor(this.themeState.compBackgroundPrimary).clip(true)
  }

  @Builder
  private BudgetRow(item: BudgetUsageItem) {
    Row({ space: 11 }) {
      SymbolGlyph(item.icon)
        .fontSize(22)
        .fontColor([this.themeState.brand as ResourceColor])
        .width(38)
        .height(38)
        .padding(8)
        .borderRadius(12)
        .backgroundColor(this.themeState.backgroundPrimary)
      Column({ space: 5 }) {
        Row() {
          Text(item.category).fontSize(15).fontWeight(FontWeight.Medium).fontColor(this.themeState.fontPrimary)
          Blank()
          if (item.budgetAmount > 0) {
            Text(`${this.formatAmountSmart(item.usedAmount)} / ${this.formatAmountSmart(item.budgetAmount)}`)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontPrimary)
              .maxLines(1)
              .minFontSize(9)
              .maxFontSize(12)
              .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
          } else {
            Text(`已支出 ${this.formatAmountSmart(item.usedAmount)}`)
              .fontSize(12)
              .fontColor(this.themeState.fontSecondary)
              .maxLines(1)
              .minFontSize(9)
              .maxFontSize(12)
              .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
          }
        }.width('100%')

        if (item.budgetAmount > 0) {
          Row({ space: 10 }) {
            Progress({ value: this.getCategoryProgressValue(item), total: 100, type: ProgressType.Linear })
              .height(6).color(this.themeState.brand).backgroundColor(this.themeState.compDivider).layoutWeight(1)
            Text(this.formatPercent(this.getCategoryUsagePercent(item)))
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.brand)
              .width(48)
              .textAlign(TextAlign.End)
          }.width('100%')

          Text(this.getCategoryDifferenceText(item)).fontSize(10)
            .fontColor(this.getCategoryDifference(item) > 0 ? WARNING_COLOR : this.themeState.fontSecondary)
            .width('100%').textAlign(TextAlign.End)
        } else {
          Text('未设置预算').fontSize(12).fontColor(this.themeState.brand)
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)

      SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(20)
        .fontColor([this.themeState.fontSecondary as ResourceColor])
        .width(24).height(24)
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 10,
      bottom: 10
    })
    .onClick(() => {
      this.openEditor(item);
    })
  }

  @Builder
  private EmptyState(message: string) {
    Column({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.list_bullet')).fontSize(30).fontColor([this.themeState.fontSecondary as ResourceColor])
      Text(message).fontSize(14).fontColor(this.themeState.fontSecondary)
    }.width('100%').height(150).justifyContent(FlexAlign.Center)
  }

  @Builder
  private BudgetEditorSheet() {
    Column({ space: 12 }) {
      Row() {
        Text('调整分类预算').fontSize(19).fontWeight(FontWeight.Bold).fontColor(this.themeState.fontPrimary)
        Blank()
        Button('完成')
          .height(34)
          .fontSize(13)
          .fontColor(this.themeState.brand)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.closeEditor();
          })
      }.width('100%')

      Text(`${this.monthText} · 选择分类后设置预算金额`).fontSize(13).fontColor(this.themeState.fontSecondary)
        .width('100%')

      Grid() {
        ForEach(this.items, (item: BudgetUsageItem) => {
          GridItem() {
            Column({ space: 5 }) {
              SymbolGlyph(item.icon).fontSize(21)
                .fontColor([this.editingCategory === item.category ? this.themeState.fontOnPrimary as ResourceColor :
                  this.themeState.brand as ResourceColor])
              Text(item.category).fontSize(12).fontWeight(FontWeight.Medium)
                .fontColor(this.editingCategory === item.category ? this.themeState.fontOnPrimary :
                  this.themeState.fontPrimary)
            }
            .width('100%')
            .height(68)
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .backgroundColor(this.editingCategory === item.category ? this.themeState.brand as ResourceColor :
              this.themeState.compBackgroundPrimary)
            .border({
              width: 1, color: this.editingCategory === item.category ? this.themeState.brand as ResourceColor :
                this.themeState.compDivider
            })
          }
          .onClick(() => {
            this.selectCategory(item);
          })
        }, (item: BudgetUsageItem) => item.category)
      }
      .width('100%')
      .height(148)
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(10)
      .columnsGap(10)

      Text(`设置${this.editingCategory}预算 · 输入 0 或留空可清除`).fontSize(13)
        .fontColor(this.themeState.fontSecondary).width('100%')
      TextInput({ text: this.editingAmountText, placeholder: '请输入预算金额' })
        .type(InputType.Number)
        .height(52)
        .fontSize(20)
        .fontColor(this.themeState.fontPrimary)
        .placeholderColor(this.themeState.fontSecondary)
        .backgroundColor(this.themeState.compBackgroundPrimary)
        .borderRadius(16)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.editingAmountText = value;
        })
      Row({ space: 10 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontColor(this.themeState.fontPrimary)
          .backgroundColor(this.themeState.backgroundPrimary)
          .borderRadius(14)
          .border({ width: 1, color: this.themeState.compDivider })
          .onClick(() => {
            this.closeEditor();
          })
        Button('保存')
          .layoutWeight(1)
          .height(44)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontOnPrimary)
          .backgroundColor(this.themeState.brand as ResourceColor)
          .borderRadius(14)
          .onClick(() => {
            this.saveBudget();
          })
      }
    }
    .width('100%').height('100%')
    .padding({
      left: 20,
      right: 20,
      top: 24,
      bottom: this.winUtil.mainWindowInfo.navIndicatorHeight + 16
    })
    .backgroundColor($r('[shared_assets].color.title_bar_bg'))
  }

  @Builder
  private MonthPickerSheet() {
    Column({ space: 12 }) {
      Row() {
        Text('切换月份').fontSize(19).fontWeight(FontWeight.Bold).fontColor(this.themeState.fontPrimary)
        Blank()
        Button('取消')
          .height(34)
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.closeMonthPicker();
          })
      }.width('100%')

      Text('选择要查看的预算月份').fontSize(13).fontColor(this.themeState.fontSecondary).width('100%')

      TextPicker({ range: this.getMonthPickerRange(), value: [this.pickerYearText, this.pickerMonthText] })
        .width('100%')
        .layoutWeight(1)
        .canLoop(false)
        .disappearTextStyle({
          font: { size: 14, weight: FontWeight.Regular },
          color: this.themeState.fontSecondary
        })
        .textStyle({
          font: { size: 16, weight: FontWeight.Regular },
          color: this.themeState.fontPrimary
        })
        .selectedTextStyle({
          font: { size: 20, weight: FontWeight.Medium },
          color: this.themeState.fontPrimary
        })
        .onChange((value: string | string[]) => {
          if (Array.isArray(value) && value.length >= 2) {
            this.pickerYearText = value[0];
            this.pickerMonthText = value[1];
          }
        })

      Row({ space: 10 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontColor(this.themeState.fontPrimary)
          .backgroundColor(this.themeState.backgroundPrimary)
          .borderRadius(14)
          .border({ width: 1, color: this.themeState.compDivider })
          .onClick(() => {
            this.closeMonthPicker();
          })
        Button('确定')
          .layoutWeight(1)
          .height(44)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontOnPrimary)
          .backgroundColor(this.themeState.brand as ResourceColor)
          .borderRadius(14)
          .onClick(() => {
            this.confirmMonthPicker();
          })
      }
    }
    .width('100%').height('100%')
    .padding({
      left: 20,
      right: 20,
      top: 24,
      bottom: this.winUtil.mainWindowInfo.navIndicatorHeight + 16
    })
    .backgroundColor($r('[shared_assets].color.title_bar_bg'))
  }
}
