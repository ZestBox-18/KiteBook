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
import {
  AssetAccountListSectionComponent,
  AssetOverviewCardComponent,
  BudgetOverviewCardComponent,
  IncomeExpenseCardComponent,
  SectionHeaderComponent,
  WeeklyBillListSectionComponent
} from '../components/index';
import {
  AssetAccountBean,
  BillSortTypeEnum,
  HomeAssetSummary,
  HomeHeaderState,
  HomeMonthlySummary,
  HomeWeeklyDisplayState
} from '../viewmodels/index';
import { HomeIndexCalculator } from '../utils/index';

const TAG: string = '[HomeIndex]';
const CARD_COUNT: number = 3;
const MIN_SCALE: number = 0.85;
const MAX_ROTATE: number = 5;
const DEFAULT_MONTH_BUDGET: number = 4000;
const HOME_SWIPER_CARD_HEIGHT: number = 236;
const HOME_SWIPER_SECTION_HEIGHT: number = 274;

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
  @Local currentMonthText: string = '';
  @Local monthlyExpense: number = 0;
  @Local monthlyIncome: number = 0;
  @Local monthlyBalance: number = 0;
  @Local budgetRemaining: number = DEFAULT_MONTH_BUDGET;
  @Local remainingDaysOfMonth: number = 1;
  @Local dailyBudgetRemaining: number = DEFAULT_MONTH_BUDGET;
  @Local budgetProgressValue: number = 0;
  @Local budgetUsagePercent: number = 0;
  @Local totalAssets: number = 0;
  @Local totalLiabilities: number = 0;
  @Local netAssets: number = 0;
  @Local sortedWeekBills: BillBean[] = [];
  @Local sortedWeekBillGroups: BillGroup[] = [];
  @Local headerTitle: string = '本周账单';
  @Local headerAction: string = '按日总额排序';
  @Local billSortModeText: string = '按时间倒序';

  private indicatorController: IndicatorComponentController = new IndicatorComponentController();
  private swiperController: SwiperController = new SwiperController();

  private readonly assetAccounts: AssetAccountBean[] = [
    new AssetAccountBean('支付宝', '日常消费', 8650.35, $r('sys.symbol.creditcard'), false),
    new AssetAccountBean('微信', '零钱与零钱通', 3268.50, $r('sys.symbol.house'), false),
    new AssetAccountBean('招商银行卡', '储蓄账户', 42180.00, $r('sys.symbol.creditcard'), false),
    new AssetAccountBean('花呗', '本月待还', 2580.00, $r('sys.symbol.arrow_up_circle'), true)
  ];

  @Builder
  /**
   * 根据导航路由名映射到首页可跳转的子页面。
   */
  PagesMap(name: string) {
    if (name === RouterUrlConstants.ORDINARY) {
      Ordinary()
    }
    if (name === RouterUrlConstants.ASSETS) {
      Assets()
    }
  }

  /**
   * 进入首页子页面前先收起底部 Tab，保持过渡一致。
   */
  private navigateToSubPage(name: string): void {
    mainTabController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
    this.pageInfos.pushPath({ name: name });
  }

  /**
   * 根据当前卡片和排序模式刷新列表区标题文案。
   */
  private updateHeaderState(): void {
    const headerState: HomeHeaderState = HomeIndexCalculator.buildHeaderState(this.swiperIndex, this.billSortType);
    this.headerTitle = headerState.title;
    this.headerAction = headerState.action;
  }

  /**
   * 处理列表区右上角操作，资产卡进入资产页，其余卡切换排序方式。
   */
  private handleHeaderAction(): void {
    if (this.swiperIndex === 2) {
      this.navigateToSubPage(RouterUrlConstants.ASSETS);
      return;
    }
    this.billSortType = HomeIndexCalculator.getNextBillSortType(this.billSortType);
  }

  /**
   * 并行加载周账单与月账单数据，减少首页首屏等待。
   */
  private async loadBillData(): Promise<void> {
    try {
      const billResult: [BillGroup[], BillGroup[]] = await Promise.all([
        BillManager.getRecentBills(7),
        BillManager.getRecentBills(31)
      ]);
      this.weekBillGroups = billResult[0];
      this.monthBillGroups = billResult[1];
    } catch (err) {
      Clog.error(TAG, '加载账单数据失败', err);
    }
  }

  /**
   * 删除账单后重新拉取首页账单数据，确保统计区和列表区同步。
   */
  private async deleteBill(billId: number): Promise<void> {
    try {
      await BillManager.deleteBill(billId);
      await this.loadBillData();
    } catch (err) {
      Clog.error(TAG, '删除账单失败', err);
    }
  }

  /**
   * 将日期文案委托给计算器，统一首页日期显示规则。
   */
  private formatDateTitle(dateStr: string): string {
    return HomeIndexCalculator.formatDateTitle(dateStr);
  }

  /**
   * 返回某一天的总流水，供分组头部展示。
   */
  private getGroupTurnover(group: BillGroup): number {
    return HomeIndexCalculator.getGroupTurnover(group);
  }

  /**
   * 按显隐状态格式化普通金额文本。
   */
  private getAmountText(amount: number, hidden: boolean): string {
    if (hidden) {
      return '****';
    }
    return `¥${this.formatAmount(amount)}`;
  }

  /**
   * 按显隐状态格式化带正负号的金额文本。
   */
  private getSignedAmountText(amount: number, hidden: boolean): string {
    if (hidden) {
      return '****';
    }
    const prefix: string = amount >= 0 ? '+' : '-';
    return `${prefix}¥${this.formatAmount(Math.abs(amount))}`;
  }

  /**
   * 将资产条目类型映射为中文标签。
   */
  private getAssetSignText(isLiability: boolean): string {
    return isLiability ? '负债' : '资产';
  }

  /**
   * 为资产列表返回对应的金额颜色。
   */
  private getAssetAmountColor(isLiability: boolean): ResourceColor {
    if (isLiability) {
      return '#F97316';
    }
    return this.themeState.fontPrimary as ResourceColor;
  }

  /**
   * 统一首页金额千分位格式，避免多处实现。
   */
  private formatAmount(amount: number): string {
    return HomeIndexCalculator.formatAmount(amount);
  }

  /**
   * 读取窗口宽度并转换为 vp，用于判断卡片紧凑布局。
   */
  private getSwiperViewportWidth(): number {
    const windowWidthPx: number = this.winUtil.mainWindowInfo.windowSize.width;
    if (windowWidthPx <= 0) {
      return 360;
    }
    return this.getUIContext().px2vp(windowWidthPx);
  }

  /**
   * 当宽度较小时切换到紧凑卡片布局。
   */
  private isCompactSwiperLayout(): boolean {
    return this.getSwiperViewportWidth() < 380;
  }

  /**
   * 刷新预算和月度收支摘要数据。
   */
  private updateMonthlySummary(): void {
    const summary: HomeMonthlySummary =
      HomeIndexCalculator.buildMonthlySummary(this.monthBillGroups, DEFAULT_MONTH_BUDGET);
    this.currentMonthText = summary.currentMonthText;
    this.monthlyExpense = summary.monthlyExpense;
    this.monthlyIncome = summary.monthlyIncome;
    this.monthlyBalance = summary.monthlyBalance;
    this.budgetRemaining = summary.budgetRemaining;
    this.remainingDaysOfMonth = summary.remainingDaysOfMonth;
    this.dailyBudgetRemaining = summary.dailyBudgetRemaining;
    this.budgetProgressValue = summary.budgetProgressValue;
    this.budgetUsagePercent = summary.budgetUsagePercent;
  }

  /**
   * 刷新周账单列表的排序结果和排序描述文案。
   */
  private updateWeeklyDisplayData(): void {
    const displayState: HomeWeeklyDisplayState =
      HomeIndexCalculator.buildWeeklyDisplayState(this.weekBillGroups, this.billSortType);
    this.sortedWeekBills = displayState.sortedWeekBills;
    this.sortedWeekBillGroups = displayState.sortedWeekBillGroups;
    this.billSortModeText = displayState.billSortModeText;
  }

  /**
   * 刷新资产总额、负债和净资产摘要。
   */
  private updateAssetSummary(): void {
    const summary: HomeAssetSummary = HomeIndexCalculator.buildAssetSummary(this.assetAccounts);
    this.totalAssets = summary.totalAssets;
    this.totalLiabilities = summary.totalLiabilities;
    this.netAssets = summary.netAssets;
  }

  /**
   * 首次进入首页时批量初始化所有派生展示数据。
   */
  private refreshStaticDerivedState(): void {
    this.updateAssetSummary();
    this.updateWeeklyDisplayData();
    this.updateMonthlySummary();
    this.updateHeaderState();
  }

  @Monitor('weekBillGroups')
  /**
   * 周账单变化后同步刷新列表展示数据。
   */
  onWeekBillGroupsChanged(): void {
    this.updateWeeklyDisplayData();
  }

  @Monitor('monthBillGroups')
  /**
   * 月账单变化后同步刷新预算和收支摘要。
   */
  onMonthBillGroupsChanged(): void {
    this.updateMonthlySummary();
  }

  @Monitor('billSortType')
  /**
   * 排序方式变化后同步刷新列表和标题动作文案。
   */
  onBillSortTypeChanged(): void {
    this.updateWeeklyDisplayData();
    this.updateHeaderState();
  }

  @Monitor('swiperIndex')
  /**
   * 卡片切换后刷新列表区标题和操作文案。
   */
  onSwiperIndexChanged(): void {
    this.updateHeaderState();
  }

  /**
   * 首页出现时先准备派生数据，再异步拉取最新账单。
   */
  aboutToAppear(): void {
    this.refreshStaticDerivedState();
    this.loadBillData();
  }

  /**
   * 构建首页主容器，负责组合卡片区、标题区和列表区。
   */
  build() {
    HdsNavigation(this.pageInfos) {
      List({ space: 10 }) {
        ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)

        ListItem() {
          this.SwiperSection()
        }

        ListItem() {
          SectionHeaderComponent({
            title: this.headerTitle,
            action: this.headerAction,
            onAction: () => this.handleHeaderAction(),
            themeState: this.themeState
          })
        }

        if (this.swiperIndex === 2) {
          AssetAccountListSectionComponent({
            themeState: this.themeState,
            assetAccounts: this.assetAccounts,
            hideAssetAmount: this.hideAssetAmount,
            getAssetSignText: (isLiability: boolean): string => this.getAssetSignText(isLiability),
            getAmountText: (amount: number, hidden: boolean): string => this.getAmountText(amount, hidden),
            getAssetAmountColor: (isLiability: boolean): ResourceColor => this.getAssetAmountColor(isLiability)
          })
        } else {
          WeeklyBillListSectionComponent({
            themeState: this.themeState,
            isAmountSortMode: this.billSortType === BillSortTypeEnum.AMOUNT_DESC,
            sortedWeekBills: this.sortedWeekBills,
            sortedWeekBillGroups: this.sortedWeekBillGroups,
            billSortModeText: this.billSortModeText,
            onDeleteBill: (billId: number): void => {
              this.deleteBill(billId);
            },
            formatDateTitle: (dateStr: string): string => this.formatDateTitle(dateStr),
            formatGroupTurnover: (group: BillGroup): string => `¥${this.formatAmount(this.getGroupTurnover(group))}`
          })
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
  /**
   * 构建首页顶部统计卡片轮播区与指示器。
   */
  SwiperSection() {
    Column() {
      Swiper(this.swiperController) {
        BudgetOverviewCardComponent({
          themeState: this.themeState,
          compactLayout: this.isCompactSwiperLayout(),
          currentMonthText: this.currentMonthText,
          budgetProgressValue: this.budgetProgressValue,
          budgetUsagePercent: this.budgetUsagePercent,
          dailyBudgetText: this.getAmountText(this.dailyBudgetRemaining, false),
          budgetRemainingText: this.getAmountText(this.budgetRemaining, false),
          totalBudgetText: this.getAmountText(DEFAULT_MONTH_BUDGET, false),
          monthlyExpenseText: this.getAmountText(this.monthlyExpense, false),
          remainingDaysText: `剩余 ${this.remainingDaysOfMonth} 天`,
          opacityValue: this.opacityList[0],
          scaleValue: this.scaleList[0],
          rotateValue: this.rotateList[0],
          zIndexValue: this.zIndexList[0],
          totalBudgetValue: DEFAULT_MONTH_BUDGET
        })
        IncomeExpenseCardComponent({
          themeState: this.themeState,
          compactLayout: this.isCompactSwiperLayout(),
          hiddenAmount: this.hideIncomeExpenseAmount,
          expenseText: this.getAmountText(this.monthlyExpense, this.hideIncomeExpenseAmount),
          incomeText: this.getAmountText(this.monthlyIncome, this.hideIncomeExpenseAmount),
          balanceText: this.getSignedAmountText(this.monthlyBalance, this.hideIncomeExpenseAmount),
          opacityValue: this.opacityList[1],
          scaleValue: this.scaleList[1],
          rotateValue: this.rotateList[1],
          zIndexValue: this.zIndexList[1],
          onToggleHidden: () => {
            this.hideIncomeExpenseAmount = !this.hideIncomeExpenseAmount;
          }
        })
        AssetOverviewCardComponent({
          themeState: this.themeState,
          compactLayout: this.isCompactSwiperLayout(),
          hiddenAmount: this.hideAssetAmount,
          netAssetsText: this.getAmountText(this.netAssets, this.hideAssetAmount),
          totalAssetsText: this.getAmountText(this.totalAssets, this.hideAssetAmount),
          totalLiabilitiesText: this.getAmountText(this.totalLiabilities, this.hideAssetAmount),
          opacityValue: this.opacityList[2],
          scaleValue: this.scaleList[2],
          rotateValue: this.rotateList[2],
          zIndexValue: this.zIndexList[2],
          onToggleHidden: () => {
            this.hideAssetAmount = !this.hideAssetAmount;
          }
        })
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

}
