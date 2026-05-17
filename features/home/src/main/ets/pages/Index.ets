/**
 * Copyright (C), 2025-05-13
 * @author ZestBox
 * @date 2025/05/13
 * @version 1.0
 * @description: 首页主页面
 */

import { hdsMaterial, HdsNavigation, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import {
  AppThemeState,
  BillBean,
  BillGroup,
  BillManager,
  CommonConstants,
  RouterUrlConstants,
  SystemOptions,
  mainTabController
} from 'base';
import { Assets, Ordinary } from 'record';
import { AppStorageV2, curves, LengthMetrics, PersistenceV2 } from '@kit.ArkUI';
import { Clog, WindowUtil } from 'kite_utils';
import { BillItemComponent } from '../components/BillItemComponent';
import { EmptyStateComponent } from '../components/EmptyStateComponent';
import { SectionHeaderComponent } from '../components/SectionHeaderComponent';
import { DeleteSwipeButtonComponent } from '../components/DeleteSwipeButtonComponent';

const TAG: string = '[HomeIndex]';
const CARD_COUNT: number = 3;
const MIN_SCALE: number = 0.85;
const MAX_ROTATE: number = 5;
const GRADIENT_DELAY: number = 80;
const DEFAULT_MONTH_BUDGET: number = 4000;
const HOME_SWIPER_CARD_HEIGHT: number = 236;
const HOME_SWIPER_SECTION_HEIGHT: number = 274;

class AssetAccountBean {
  name: string = '';
  subtitle: string = '';
  amount: number = 0;
  icon: Resource = $r('sys.symbol.creditcard');
  isLiability: boolean = false;

  constructor(name: string, subtitle: string, amount: number, icon: Resource, isLiability: boolean) {
    this.name = name;
    this.subtitle = subtitle;
    this.amount = amount;
    this.icon = icon;
    this.isLiability = isLiability;
  }
}

enum BillSortTypeEnum {
  DATE_DESC = 'date_desc',
  DAY_TOTAL_DESC = 'day_total_desc',
  AMOUNT_DESC = 'amount_desc'
}

@Entry
@ComponentV2
export struct Index {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;
  @Local weekBillGroups: BillGroup[] = [];
  @Local monthBillGroups: BillGroup[] = [];
  @Local swiperIndex: number = 0;
  @Local opacityList: number[] = [1, 1, 1];
  @Local scaleList: number[] = [1, 1, 1];
  @Local rotateList: number[] = [0, 0, 0];
  @Local zIndexList: number[] = [0, 0, 0];
  @Local billSortType: BillSortTypeEnum = BillSortTypeEnum.DATE_DESC;
  @Local hideIncomeExpenseAmount: boolean = false;
  @Local hideAssetAmount: boolean = false;

  private indicatorController: IndicatorComponentController = new IndicatorComponentController();
  private swiperController: SwiperController = new SwiperController();

  private readonly assetAccounts: AssetAccountBean[] = [
    new AssetAccountBean('支付宝', '日常消费', 8650.35, $r('sys.symbol.creditcard'), false),
    new AssetAccountBean('微信', '零钱与零钱通', 3268.50, $r('sys.symbol.house'), false),
    new AssetAccountBean('招商银行卡', '储蓄账户', 42180.00, $r('sys.symbol.creditcard'), false),
    new AssetAccountBean('花呗', '本月待还', 2580.00, $r('sys.symbol.arrow_up_circle'), true)
  ];

  @Builder
  PagesMap(name: string) {
    if (name === RouterUrlConstants.ORDINARY) {
      Ordinary()
    }
    if (name === RouterUrlConstants.ASSETS) {
      Assets()
    }
  }

  @Builder
  DeleteSwipeBuilder(billId: number) {
    DeleteSwipeButtonComponent({ onDelete: () => this.deleteBill(billId) })
  }

  private navigateToSubPage(name: string): void {
    mainTabController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
    this.pageInfos.pushPath({ name: name });
  }

  private getHeaderTitle(): string {
    return this.swiperIndex === 2 ? '资产账户' : '本周账单';
  }

  private getHeaderAction(): string {
    if (this.swiperIndex === 2) {
      return '管理资产';
    }
    if (this.billSortType === BillSortTypeEnum.DATE_DESC) {
      return '按日总额排序';
    }
    if (this.billSortType === BillSortTypeEnum.DAY_TOTAL_DESC) {
      return '按金额排序';
    }
    return '按时间排序';
  }

  private handleHeaderAction(): void {
    if (this.swiperIndex === 2) {
      this.navigateToSubPage(RouterUrlConstants.ASSETS);
      return;
    }
    if (this.billSortType === BillSortTypeEnum.DATE_DESC) {
      this.billSortType = BillSortTypeEnum.DAY_TOTAL_DESC;
    } else if (this.billSortType === BillSortTypeEnum.DAY_TOTAL_DESC) {
      this.billSortType = BillSortTypeEnum.AMOUNT_DESC;
    } else {
      this.billSortType = BillSortTypeEnum.DATE_DESC;
    }
  }

  private async loadBillData(): Promise<void> {
    try {
      this.weekBillGroups = await BillManager.getRecentBills(7);
      this.monthBillGroups = await BillManager.getRecentBills(31);
    } catch (err) {
      Clog.error(TAG, '加载账单数据失败', err);
    }
  }

  private async deleteBill(billId: number): Promise<void> {
    try {
      await BillManager.deleteBill(billId);
      await this.loadBillData();
    } catch (err) {
      Clog.error(TAG, '删除账单失败', err);
    }
  }

  private getCurrentMonth(): string {
    const now = new Date();
    return `${now.getMonth() + 1}月`;
  }

  private getMonthlyExpense(): number {
    let totalExpense: number = 0;
    this.monthBillGroups.forEach((group: BillGroup) => {
      totalExpense += group.totalExpense;
    });
    return totalExpense;
  }

  private getMonthlyIncome(): number {
    let totalIncome: number = 0;
    this.monthBillGroups.forEach((group: BillGroup) => {
      totalIncome += group.totalIncome;
    });
    return totalIncome;
  }

  private getMonthlyBalance(): number {
    return this.getMonthlyIncome() - this.getMonthlyExpense();
  }

  private getBudgetRemaining(): number {
    const remaining: number = DEFAULT_MONTH_BUDGET - this.getMonthlyExpense();
    return remaining > 0 ? remaining : 0;
  }

  private getRemainingDaysOfMonth(): number {
    const now = new Date();
    const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
    const remainingDays = lastDay - now.getDate() + 1;
    return remainingDays > 0 ? remainingDays : 1;
  }

  private formatDateTitle(dateStr: string): string {
    const today = new Date();
    const todayStr = `${today.getFullYear()}-${(today.getMonth() + 1).toString().padStart(2, '0')}-${today.getDate()
      .toString()
      .padStart(2, '0')}`;
    if (dateStr === todayStr) {
      return '今天';
    }
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const yesterdayStr =
      `${yesterday.getFullYear()}-${(yesterday.getMonth() + 1).toString().padStart(2, '0')}-${yesterday.getDate()
        .toString()
        .padStart(2, '0')}`;
    if (dateStr === yesterdayStr) {
      return '昨天';
    }
    return dateStr;
  }

  private getDailyBudgetRemaining(): number {
    return this.getBudgetRemaining() / this.getRemainingDaysOfMonth();
  }

  private getBudgetProgressValue(): number {
    const expense: number = this.getMonthlyExpense();
    return expense > DEFAULT_MONTH_BUDGET ? DEFAULT_MONTH_BUDGET : expense;
  }

  private getBudgetUsagePercent(): number {
    if (DEFAULT_MONTH_BUDGET <= 0) {
      return 0;
    }
    return Math.min(100, this.getBudgetProgressValue() / DEFAULT_MONTH_BUDGET * 100);
  }

  private getTotalAssets(): number {
    let totalAssets: number = 0;
    this.assetAccounts.forEach((item: AssetAccountBean) => {
      if (!item.isLiability) {
        totalAssets += item.amount;
      }
    });
    return totalAssets;
  }

  private getTotalLiabilities(): number {
    let totalLiabilities: number = 0;
    this.assetAccounts.forEach((item: AssetAccountBean) => {
      if (item.isLiability) {
        totalLiabilities += item.amount;
      }
    });
    return totalLiabilities;
  }

  private getNetAssets(): number {
    return this.getTotalAssets() - this.getTotalLiabilities();
  }

  private getSortedWeekBills(): BillBean[] {
    const billList: BillBean[] = [];
    this.weekBillGroups.forEach((group: BillGroup) => {
      group.bills.forEach((bill: BillBean) => {
        billList.push(bill);
      });
    });

    if (this.billSortType === BillSortTypeEnum.AMOUNT_DESC) {
      billList.sort((first: BillBean, second: BillBean) => second.amount - first.amount);
      return billList;
    }

    billList.sort((first: BillBean, second: BillBean) => second.date - first.date);
    return billList;
  }

  private getSortedWeekBillGroups(): BillGroup[] {
    const groupList: BillGroup[] = [];
    this.weekBillGroups.forEach((group: BillGroup) => {
      groupList.push(group);
    });

    if (this.billSortType === BillSortTypeEnum.DAY_TOTAL_DESC) {
      groupList.sort((first: BillGroup, second: BillGroup) => this.getGroupTurnover(second) - this.getGroupTurnover(first));
      return groupList;
    }

    groupList.sort((first: BillGroup, second: BillGroup) => second.dateTimestamp - first.dateTimestamp);
    return groupList;
  }

  private getGroupTurnover(group: BillGroup): number {
    return group.totalIncome + group.totalExpense;
  }

  private getAmountText(amount: number, hidden: boolean): string {
    if (hidden) {
      return '****';
    }
    return `¥${this.formatAmount(amount)}`;
  }

  private getSignedAmountText(amount: number, hidden: boolean): string {
    if (hidden) {
      return '****';
    }
    const prefix: string = amount >= 0 ? '+' : '-';
    return `${prefix}¥${this.formatAmount(Math.abs(amount))}`;
  }

  private getAssetSignText(isLiability: boolean): string {
    return isLiability ? '负债' : '资产';
  }

  private getBillSortModeText(): string {
    if (this.billSortType === BillSortTypeEnum.DATE_DESC) {
      return '按时间倒序';
    }
    if (this.billSortType === BillSortTypeEnum.DAY_TOTAL_DESC) {
      return '按日总额从高到低';
    }
    return '按金额从高到低';
  }

  private getAssetAmountColor(isLiability: boolean): ResourceColor {
    if (isLiability) {
      return '#F97316';
    }
    return this.themeState.fontPrimary as ResourceColor;
  }

  private formatAmount(amount: number): string {
    const fixedAmount: string = amount.toFixed(2);
    const amountParts: string[] = fixedAmount.split('.');
    let integerPart: string = amountParts[0];
    const decimalPart: string = amountParts[1];
    const resultParts: string[] = [];

    while (integerPart.length > 3) {
      resultParts.unshift(integerPart.slice(integerPart.length - 3));
      integerPart = integerPart.slice(0, integerPart.length - 3);
    }
    resultParts.unshift(integerPart);
    return `${resultParts.join(',')}.${decimalPart}`;
  }

  aboutToAppear(): void {
    this.loadBillData();
  }

  build() {
    HdsNavigation(this.pageInfos) {
      List({ space: 10 }) {
        ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)

        ListItem() {
          this.SwiperSection()
        }

        ListItem() {
          SectionHeaderComponent({
            title: this.getHeaderTitle(),
            action: this.getHeaderAction(),
            onAction: () => this.handleHeaderAction(),
            themeState: this.themeState
          })
        }

        if (this.swiperIndex === 2) {
          this.AssetListItems()
        } else {
          this.WeeklyBillListItems()
        }
      }
      .width('100%')
      .height('100%')
      .contentEndOffset(this.winUtil.mainWindowInfo.navIndicatorHeight + CommonConstants.TAB_HEIGHT + 8)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .backgroundColor($r('app.color.start_window_background'))
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
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
            backgroundColor: $r('app.color.title_bar_bg'),
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            },
            menuStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            },
          }
        },
        scrollEffectStyle: {
          backgroundStyle: {
            backgroundColor: $r('app.color.title_bar_bg'),
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary'),
            },
            menuStyle: {
              backgroundColor: $r('app.color.action_bg'),
              textColor: $r('app.color.text_secondary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        }
      },
      content: {
        title: {
          mainTitle: '纸鸢账本',
          subTitle: '个人账本'
        },
        menu: {
          value: [{
            content: {
              icon: $r('sys.symbol.house'),
              label: 'logo',
              action: () => {
              },
            }
          }]
        },
      },
      avoidLayoutSafeArea: true
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }

  @Builder
  SwiperSection() {
    Column() {
      Swiper(this.swiperController) {
        this.BudgetCard()
        this.IncomeExpenseCard()
        this.AssetCard()
      }
      .prevMargin(6)
      .nextMargin(6)
      .index(this.swiperIndex)
      .autoPlay(false)
      .indicator(this.indicatorController)
      .itemSpace(16)
      .height(HOME_SWIPER_CARD_HEIGHT)
      .customContentTransition({
        timeout: 1000,
        transition: (proxy: SwiperContentTransitionProxy) => {
          const pageDistance: number = Math.abs(proxy.position);
          if (proxy.index === proxy.selectedIndex) {
            const progress = Math.min(pageDistance, 1);
            this.opacityList[proxy.index] = 1 - 0.5 * progress;
            this.scaleList[proxy.index] = 1 - (1 - MIN_SCALE) * progress;
            this.rotateList[proxy.index] = MAX_ROTATE * progress * (proxy.position < 0 ? -1 : 1);
            this.zIndexList[proxy.index] = 1;
          } else if (pageDistance < 1) {
            const progress = 1 - pageDistance;
            this.opacityList[proxy.index] = 0.5 + 0.5 * progress;
            this.scaleList[proxy.index] = MIN_SCALE + (1 - MIN_SCALE) * progress;
            this.rotateList[proxy.index] = MAX_ROTATE * (1 - progress) * (proxy.position < 0 ? 1 : -1);
            this.zIndexList[proxy.index] = 0;
          } else {
            this.opacityList[proxy.index] = 0;
            this.scaleList[proxy.index] = MIN_SCALE;
            this.rotateList[proxy.index] = 0;
            this.zIndexList[proxy.index] = 0;
          }
        }
      })
      .onChange((index: number) => {
        this.swiperIndex = index;
        this.getUIContext().animateTo({
          duration: 300,
          curve: curves.springMotion(0.6, 0.9)
        }, () => {
          for (let i = 0; i < CARD_COUNT; i++) {
            this.opacityList[i] = 1;
            this.scaleList[i] = 1;
            this.rotateList[i] = 0;
            this.zIndexList[i] = 0;
          }
        });
      })

      IndicatorComponent(this.indicatorController)
        .initialIndex(0)
        .style(new DotIndicator()
          .itemWidth(8)
          .itemHeight(8)
          .selectedItemWidth(16)
          .selectedItemHeight(8)
          .color(this.themeState.compDivider)
          .selectedColor(this.themeState.brand))
        .loop(false)
        .count(CARD_COUNT)
        .margin({ top: 14 })
    }
    .width('100%')
    .height(HOME_SWIPER_SECTION_HEIGHT)
  }

  @Builder
  BudgetCard() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.creditcard'))
            .fontSize(18)
            .fontColor(['#FFFFFF90'])
          Text('本月预算')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFFCC')
        }

        Text(this.getCurrentMonth())
          .fontSize(13)
          .fontColor('#FFFFFF70')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 14 }) {
        Stack({ alignContent: Alignment.Center }) {
          Progress({
            value: this.getBudgetProgressValue(),
            total: DEFAULT_MONTH_BUDGET,
            type: ProgressType.Ring
          })
            .width(96)
            .height(96)
            .color('#FFFFFF')
            .backgroundColor('#FFFFFF20')
            .style({ strokeWidth: 10 })

          Column({ space: 2 }) {
            Text(`${Math.floor(this.getBudgetUsagePercent())}%`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('已使用')
              .fontSize(10)
              .fontColor('#FFFFFF90')
          }
        }

        Column({ space: 10 }) {
          this.SummaryMetric('剩余日均', this.getAmountText(this.getDailyBudgetRemaining(), false))
          this.SummaryMetric('预算剩余', this.getAmountText(this.getBudgetRemaining(), false))
          this.SummaryMetric('总预算', this.getAmountText(DEFAULT_MONTH_BUDGET, false))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ top: 16 })

      Row() {
        Text(`本月已支出 ${this.getAmountText(this.getMonthlyExpense(), false)}`)
          .fontSize(12)
          .fontColor('#FFFFFF95')
        Text(`剩余 ${this.getRemainingDaysOfMonth()} 天`)
          .fontSize(12)
          .fontColor('#FFFFFF70')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 16 })
    }
    .width('100%')
    .height(HOME_SWIPER_CARD_HEIGHT)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ left: 8, right: 8 })
    .borderRadius(20)
    .backgroundColor(this.themeState.brand)
    .opacity(this.opacityList[0])
    .scale({ x: this.scaleList[0], y: this.scaleList[0] })
    .rotate({ z: 1, angle: this.rotateList[0] })
    .zIndex(this.zIndexList[0])
  }

  @Builder
  IncomeExpenseCard() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.arrow_left_arrow_right'))
            .fontSize(18)
            .fontColor(['#FFFFFF90'])
          Text('本月收支')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFFCC')
        }

        Row({ space: 12 }) {
          Text(this.getCurrentMonth())
            .fontSize(13)
            .fontColor('#FFFFFF70')
          this.VisibilityToggle(this.hideIncomeExpenseAmount, () => {
            this.hideIncomeExpenseAmount = !this.hideIncomeExpenseAmount;
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column({ space: 12 }) {
        this.CompactMetric('本月支出', this.getAmountText(this.getMonthlyExpense(), this.hideIncomeExpenseAmount))
        this.CompactMetric('本月收入', this.getAmountText(this.getMonthlyIncome(), this.hideIncomeExpenseAmount))
        this.CompactMetric('月结余', this.getSignedAmountText(this.getMonthlyBalance(), this.hideIncomeExpenseAmount))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 20 })
    }
    .width('100%')
    .height(HOME_SWIPER_CARD_HEIGHT)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ left: 8, right: 8 })
    .borderRadius(20)
    .backgroundColor(this.themeState.brand)
    .opacity(this.opacityList[1])
    .scale({ x: this.scaleList[1], y: this.scaleList[1] })
    .rotate({ z: 1, angle: this.rotateList[1] })
    .zIndex(this.zIndexList[1])
  }

  @Builder
  AssetCard() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.list_bullet'))
            .fontSize(18)
            .fontColor(['#FFFFFF90'])
          Text('资产概览')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFFCC')
        }

        this.VisibilityToggle(this.hideAssetAmount, () => {
          this.hideAssetAmount = !this.hideAssetAmount;
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column({ space: 16 }) {
        this.BigMetric('净资产', this.getAmountText(this.getNetAssets(), this.hideAssetAmount))

        Row() {
          this.AssetOverviewItem('总资产', this.getAmountText(this.getTotalAssets(), this.hideAssetAmount))
          this.AssetOverviewItem('总负债', this.getAmountText(this.getTotalLiabilities(), this.hideAssetAmount))
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 22 })
    }
    .width('100%')
    .height(HOME_SWIPER_CARD_HEIGHT)
    .padding(24)
    .margin({ left: 8, right: 8 })
    .borderRadius(20)
    .backgroundColor(this.themeState.brand)
    .opacity(this.opacityList[2])
    .scale({ x: this.scaleList[2], y: this.scaleList[2] })
    .rotate({ z: 1, angle: this.rotateList[2] })
    .zIndex(this.zIndexList[2])
  }

  @Builder
  SummaryMetric(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#FFFFFF75')
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  BigMetric(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(13)
        .fontColor('#FFFFFF85')
      Text(value)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CompactMetric(label: string, value: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#FFFFFF85')
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  AssetOverviewItem(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#FFFFFF75')
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
    }
    .width('48%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  VisibilityToggle(hidden: boolean, onToggle: () => void) {
    Button() {
      SymbolGlyph(hidden ? $r('sys.symbol.eye_slash') : $r('sys.symbol.eye'))
        .fontSize(16)
        .fontColor(['#FFFFFFCC'])
    }
    .width(32)
    .height(32)
    .padding(0)
    .backgroundColor('#FFFFFF14')
    .borderRadius(16)
    .onClick(() => {
      onToggle();
    })
  }

  @Builder
  WeeklyBillListItems() {
    if (this.weekBillGroups.length === 0) {
      ListItem() {
        EmptyStateComponent({ text: '本周暂无账单记录', themeState: this.themeState })
      }
    } else {
      if (this.billSortType === BillSortTypeEnum.AMOUNT_DESC) {
        ListItemGroup({
          header: this.WeeklyListHeader(),
          style: ListItemGroupStyle.CARD
        }) {
          ForEach(this.getSortedWeekBills(), (bill: BillBean, billIndex: number) => {
            ListItem() {
              BillItemComponent({ bill: bill, themeState: this.themeState })
            }
            .opacity(1)
            .translate({ x: 0 })
            .animation({
              duration: 300,
              delay: billIndex * GRADIENT_DELAY,
              curve: curves.springMotion(0.6, 0.9)
            })
            .swipeAction({
              end: this.DeleteSwipeBuilder(bill.id)
            })
          }, (bill: BillBean) => `${bill.id}`)
        }
        .divider({
          strokeWidth: 0.5,
          color: this.themeState.compDivider,
          startMargin: 52,
          endMargin: 16
        })
      } else {
        ForEach(this.getSortedWeekBillGroups(), (group: BillGroup, groupIndex: number) => {
          ListItemGroup({
            header: this.WeeklyGroupHeader(group),
            style: ListItemGroupStyle.CARD
          }) {
            ForEach(group.bills, (bill: BillBean, billIndex: number) => {
              ListItem() {
                BillItemComponent({ bill: bill, themeState: this.themeState })
              }
              .opacity(1)
              .translate({ x: 0 })
              .animation({
                duration: 300,
                delay: (groupIndex * 3 + billIndex) * GRADIENT_DELAY,
                curve: curves.springMotion(0.6, 0.9)
              })
              .swipeAction({
                end: this.DeleteSwipeBuilder(bill.id)
              })
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
  }

  @Builder
  WeeklyListHeader() {
    Row() {
      Text('最近 7 天')
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Text(this.getBillSortModeText())
        .fontSize(12)
        .fontColor(this.themeState.brand)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
  }

  @Builder
  WeeklyGroupHeader(group: BillGroup) {
    Row() {
      Text(this.formatDateTitle(group.date))
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontSecondary)
      Text(`¥${this.formatAmount(this.getGroupTurnover(group))}`)
        .fontSize(12)
        .fontColor(this.themeState.brand)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
  }

  @Builder
  AssetListItems() {
    if (this.assetAccounts.length === 0) {
      ListItem() {
        EmptyStateComponent({ text: '暂无资产账户数据', themeState: this.themeState })
      }
    } else {
      ListItemGroup({
        header: this.AssetListHeader(),
        style: ListItemGroupStyle.CARD
      }) {
        ForEach(this.assetAccounts, (item: AssetAccountBean, index: number) => {
          ListItem() {
            this.AssetAccountItem(item)
          }
          .opacity(1)
          .translate({ x: 0 })
          .animation({
            duration: 300,
            delay: index * GRADIENT_DELAY,
            curve: curves.springMotion(0.6, 0.9)
          })
        }, (item: AssetAccountBean) => item.name)
      }
      .divider({
        strokeWidth: 0.5,
        color: this.themeState.compDivider,
        startMargin: 52,
        endMargin: 16
      })
    }
  }

  @Builder
  AssetListHeader() {
    Row() {
      Text('账户列表')
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Text(`${this.assetAccounts.length} 个账户`)
        .fontSize(12)
        .fontColor(this.themeState.brand)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
  }

  @Builder
  AssetAccountItem(item: AssetAccountBean) {
    Row() {
      SymbolGlyph(item.icon)
        .fontSize(20)
        .fontColor([item.isLiability ? '#F97316' : this.themeState.brand as ResourceColor])
        .width(36)
        .height(36)
        .borderRadius(8)
        .backgroundColor(item.isLiability ? '#FFF7ED' : '#EEF6FF')
        .padding(8)

      Column() {
        Text(item.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
        Text(`${this.getAssetSignText(item.isLiability)} · ${item.subtitle}`)
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      Text(this.getAmountText(item.amount, this.hideAssetAmount))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getAssetAmountColor(item.isLiability))
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }
}
