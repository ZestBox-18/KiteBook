/**
 * Copyright (C), 2026-06-17
 * @author ZestBox
 * @date 2026/06/17
 * @version 1.0
 * @description: 首页本月预算详情页
 */

import { hdsMaterial, HdsAnimationMode, HdsNavDestination, ScrollEffectType } from '@kit.UIDesignKit';
import {
  AppThemeState,
  BillBean,
  BillTypeEnum,
  BudgetBean,
  CommonConstants,
  mainTabController
} from 'base';
import { BillManager, BudgetManager } from 'data_core';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { Clog, WindowUtil } from 'kite_utils';

class BudgetUsageItem {
  category: string = '';
  budgetAmount: number = 0;
  usedAmount: number = 0;

  constructor(category: string, budgetAmount: number, usedAmount: number) {
    this.category = category;
    this.budgetAmount = budgetAmount;
    this.usedAmount = usedAmount;
  }
}

const TAG: string = '[BudgetDetail]';

@ComponentV2
export struct BudgetDetail {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local monthText: string = '';
  @Local totalBudget: number = 0;
  @Local totalUsed: number = 0;
  @Local totalRemaining: number = 0;
  @Local items: BudgetUsageItem[] = [];

  private readonly monthAnchor: number = new Date(new Date().getFullYear(), new Date().getMonth(), 1).getTime();

  aboutToAppear(): void {
    this.monthText = this.buildMonthText();
    this.loadBudgetData();
  }

  private buildMonthText(): string {
    const date: Date = new Date(this.monthAnchor);
    return `${date.getFullYear()}年${date.getMonth() + 1}月`;
  }

  private async loadBudgetData(): Promise<void> {
    try {
      const monthKey: string = BudgetManager.buildMonthKey(this.monthAnchor);
      const budgets: BudgetBean[] = await BudgetManager.getBudgetsByMonth(monthKey);
      const monthEnd: number = new Date(new Date(this.monthAnchor).getFullYear(), new Date(this.monthAnchor).getMonth() + 1, 1)
        .getTime();
      const expenseBills: BillBean[] = await BillManager.getBillsByRange(this.monthAnchor, monthEnd, BillTypeEnum.EXPENSE);
      const usedMap: Map<string, number> = new Map();
      expenseBills.forEach((bill: BillBean) => {
        const currentAmount: number = usedMap.get(bill.category) ?? 0;
        usedMap.set(bill.category, currentAmount + bill.amount);
      });

      const usageItems: BudgetUsageItem[] = budgets.map((item: BudgetBean) =>
        new BudgetUsageItem(item.category, item.amount, usedMap.get(item.category) ?? 0));
      usageItems.sort((first: BudgetUsageItem, second: BudgetUsageItem) => second.usedAmount - first.usedAmount);
      this.items = usageItems;

      let budgetTotal: number = 0;
      let usedTotal: number = 0;
      usageItems.forEach((item: BudgetUsageItem) => {
        budgetTotal += item.budgetAmount;
        usedTotal += item.usedAmount;
      });
      this.totalBudget = budgetTotal;
      this.totalUsed = usedTotal;
      this.totalRemaining = budgetTotal - usedTotal;
    } catch (err) {
      Clog.error(TAG, '加载预算详情失败', err);
    }
  }

  private formatAmount(amount: number): string {
    const fixed: string = Math.abs(amount).toFixed(2);
    const parts: string[] = fixed.split('.');
    const integerPart: string = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    return `¥${integerPart}.${parts[1]}`;
  }

  private getUsagePercent(item: BudgetUsageItem): number {
    if (item.budgetAmount <= 0) {
      return 0;
    }
    const percent: number = item.usedAmount / item.budgetAmount * 100;
    return percent > 100 ? 100 : percent;
  }

  build() {
    HdsNavDestination() {
      List({ space: 10 }) {
        ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

        ListItem() {
          Column({ space: 14 }) {
            Row() {
              this.SummaryMetric('预算', this.formatAmount(this.totalBudget), this.themeState.fontPrimary)
              this.SummaryDivider()
              this.SummaryMetric('已用', this.formatAmount(this.totalUsed), '#E55454')
              this.SummaryDivider()
              this.SummaryMetric('剩余', this.formatAmount(this.totalRemaining),
                this.totalRemaining >= 0 ? '#10B981' : '#F97316')
            }
            .width('100%')
          }
          .width('100%')
          .padding(18)
        }
        .backgroundColor(this.themeState.compBackgroundPrimary)
        .borderRadius(22)

        ListItemGroup({
          header: this.SectionHeader('分类预算', this.monthText),
          style: ListItemGroupStyle.CARD
        }) {
          if (this.items.length === 0) {
            ListItem() {
              Text('本月还没有设置预算')
                .fontSize(14)
                .fontColor(this.themeState.fontSecondary)
                .width('100%')
                .padding(16)
            }
          } else {
            ForEach(this.items, (item: BudgetUsageItem) => {
              ListItem() {
                this.BudgetRow(item)
              }
            }, (item: BudgetUsageItem) => item.category)
          }
        }
        .divider({
          strokeWidth: 0.5,
          color: this.themeState.compDivider,
          startMargin: 16,
          endMargin: 16
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('[shared_assets].color.start_window_background'))
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .contentEndOffset(this.winUtil.mainWindowInfo.navIndicatorHeight + 16)
    }
    .titleBar({
      padding: {
        start: LengthMetrics.vp(20),
        end: LengthMetrics.vp(2)
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
        }
      },
      content: {
        title: {
          mainTitle: '本月预算',
          subTitle: '预算使用与剩余额度'
        }
      },
      avoidLayoutSafeArea: true
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
  private SectionHeader(title: string, subtitle: string) {
    Row() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)
      Text(subtitle)
        .fontSize(12)
        .fontColor(this.themeState.fontSecondary)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
  }

  @Builder
  private SummaryMetric(label: string, value: string, color: ResourceColor) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Text(value)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private SummaryDivider() {
    Column()
      .width(1)
      .height(40)
      .backgroundColor(this.themeState.compDivider)
      .margin({ left: 12, right: 12 })
  }

  @Builder
  private BudgetRow(item: BudgetUsageItem) {
    Column({ space: 8 }) {
      Row() {
        Text(item.category)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .layoutWeight(1)
        Text(`${this.formatAmount(item.usedAmount)} / ${this.formatAmount(item.budgetAmount)}`)
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
      }
      .width('100%')

      Progress({ value: this.getUsagePercent(item), total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(8)
        .color(this.getUsagePercent(item) >= 100 ? '#F97316' : this.themeState.brand)
        .backgroundColor('#E5E7EB')

      Row() {
        Text(`已用 ${this.getUsagePercent(item).toFixed(0)}%`)
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
        Blank()
        Text(`剩余 ${this.formatAmount(item.budgetAmount - item.usedAmount)}`)
          .fontSize(12)
          .fontColor(item.budgetAmount - item.usedAmount >= 0 ? '#10B981' : '#F97316')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }
}
