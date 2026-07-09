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
  billSyncController,
  CommonConstants,
  RouterUrlConstants,
  SystemOptions,
  mainTabController
} from 'base';
import { BillManager, BudgetManager } from 'data_core';
import { AddBillSheetComponent, Assets, Ordinary } from 'record';
import { AppStorageV2, LengthMetrics, PersistenceV2 } from '@kit.ArkUI';
import { Clog, WindowUtil } from 'kite_utils';
import {
  HomeAssetBudgetCardsComponent,
  NetAssetOverviewCardComponent,
  PendingBillPreviewCardComponent,
  RecentAutoBillsCardComponent,
  RecognitionCenterCardComponent,
  WeeklyOverviewCardComponent
} from '../components/index';
import { AssetDetail } from './AssetDetail';
import { BudgetDetail } from './BudgetDetail';
import { LedgerSwitch } from './LedgerSwitch';
import { PendingConfirmBills } from './PendingConfirmBills';
import {
  BillSortTypeEnum,
  HomeMonthlySummary,
  HomeWeeklyDisplayState
} from '../viewmodels/index';
import { HomeAmountFormatter, HomeIndexCalculator } from '../utils/index';

const TAG: string = '[HomeIndex]';

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
  @Local billSortType: BillSortTypeEnum = BillSortTypeEnum.DATE_DESC;
  @Local currentMonthText: string = '';
  @Local monthlyExpense: number = 0;
  @Local monthlyIncome: number = 0;
  @Local monthlyBalance: number = 0;
  @Local totalBudget: number = 0;
  @Local budgetRemaining: number = 0;
  @Local remainingDaysOfMonth: number = 1;
  @Local dailyBudgetRemaining: number = 0;
  @Local budgetProgressValue: number = 0;
  @Local budgetUsagePercent: number = 0;
  @Local sortedWeekBills: BillBean[] = [];
  @Local selectedAssetRouteAccountId: number = 0;
  @Local isBillEditorVisible: boolean = false;
  @Local editingBillId: number = 0;

  private overviewIndicatorController: IndicatorComponentController = new IndicatorComponentController();
  private billSyncListenerId: number = -1;

  /**
   * 根据导航路由名映射到首页可跳转的子页面。
   */
  @Builder
  PagesMap(name: string, param?: object) {
    if (name === RouterUrlConstants.ORDINARY) {
      Ordinary()
    } else if (name === RouterUrlConstants.ASSETS) {
      Assets()
    } else if (name === RouterUrlConstants.ASSET_DETAIL) {
      AssetDetail({ accountId: this.selectedAssetRouteAccountId })
    } else if (name === RouterUrlConstants.BUDGET_DETAIL) {
      BudgetDetail()
    } else if (name === RouterUrlConstants.LEDGER_SWITCH) {
      LedgerSwitch()
    } else if (name === RouterUrlConstants.PENDING_CONFIRM_BILLS) {
      PendingConfirmBills()
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
   * 待确认列表属于主流程同级页面，进入时收起底部 Tab。
   */
  private navigateToPendingConfirmBills(): void {
    this.navigateToSubPage(RouterUrlConstants.PENDING_CONFIRM_BILLS);
  }

  /**
   * 进入资产详情页；未指定账户时展示总资产视角。
   */
  private navigateToAssetDetail(accountId: number = 0): void {
    this.selectedAssetRouteAccountId = accountId;
    this.navigateToSubPage(RouterUrlConstants.ASSET_DETAIL);
  }

  /**
   * 进入本月预算详情页。
   */
  private navigateToBudgetDetail(): void {
    this.navigateToSubPage(RouterUrlConstants.BUDGET_DETAIL);
  }

  /**
   * 打开首页账单编辑半模态，复用全局记账组件。
   */
  private openBillEditor(billId: number): void {
    this.editingBillId = billId;
    this.isBillEditorVisible = true;
  }

  /**
   * 关闭首页账单编辑半模态，并清空当前编辑态。
   */
  private closeBillEditor(): void {
    this.isBillEditorVisible = false;
    this.editingBillId = 0;
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
   * 加载当前月份总预算，供首页预算卡和摘要计算复用。
   */
  private async loadBudgetData(): Promise<void> {
    try {
      this.totalBudget = await BudgetManager.getMonthBudgetTotal(Date.now());
    } catch (err) {
      Clog.error(TAG, '加载预算数据失败', err);
      this.totalBudget = 0;
    }
  }

  /**
   * 删除账单后重新拉取首页账单数据，确保统计区和列表区同步。
   */
  private async deleteBill(billId: number): Promise<void> {
    try {
      await BillManager.deleteBill(billId);
      await this.loadBillData();
      billSyncController.notifyBillChanged();
    } catch (err) {
      Clog.error(TAG, '删除账单失败', err);
    }
  }

  /**
   * 编辑账单后刷新首页数据，并同步关闭编辑半模态。
   */
  private async handleBillEdited(): Promise<void> {
    await this.loadBillData();
    this.closeBillEditor();
    billSyncController.notifyBillChanged();
  }

  /**
   * 按显隐状态格式化普通金额文本。
   */
  private getAmountText(amount: number, hidden: boolean): string {
    return HomeAmountFormatter.getAmountText(amount, hidden);
  }

  /**
   * 按显隐状态格式化带正负号的金额文本。
   */
  private getSignedAmountText(amount: number, hidden: boolean): string {
    return HomeAmountFormatter.getSignedAmountText(amount, hidden);
  }

  /**
   * 统一首页金额千分位格式，避免多处实现。
   */
  private formatAmount(amount: number): string {
    return HomeAmountFormatter.formatAmount(amount);
  }

  /**
   * 刷新预算和月度收支摘要数据。
   */
  private updateMonthlySummary(): void {
    const summary: HomeMonthlySummary =
      HomeIndexCalculator.buildMonthlySummary(this.monthBillGroups, this.totalBudget);
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
  }

  /**
   * 首次进入首页时批量初始化所有派生展示数据。
   */
  private refreshStaticDerivedState(): void {
    this.updateWeeklyDisplayData();
    this.updateMonthlySummary();
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

  @Monitor('totalBudget')
  /**
   * 预算变化后同步刷新预算卡摘要。
   */
  onTotalBudgetChanged(): void {
    this.updateMonthlySummary();
  }

  @Monitor('billSortType')
  /**
   * 排序方式变化后同步刷新列表和标题动作文案。
   */
  onBillSortTypeChanged(): void {
    this.updateWeeklyDisplayData();
  }

  /**
   * 首页出现时先准备派生数据，再异步拉取最新账单。
   */
  aboutToAppear(): void {
    if (this.billSyncListenerId < 0) {
      this.billSyncListenerId = billSyncController.register(async () => {
        await this.loadBillData();
        await this.loadBudgetData();
      })
    }
    this.refreshStaticDerivedState();
    this.loadBillData();
    this.loadBudgetData();
  }

  /**
   * 首页离开时注销账单刷新监听，避免重复注册。
   */
  aboutToDisappear(): void {
    if (this.billSyncListenerId >= 0) {
      billSyncController.unregister(this.billSyncListenerId)
      this.billSyncListenerId = -1
    }
  }

  /**
   * 构建首页主容器，按照识别中心和财务概览仪表盘组织首屏信息。
   */
  build() {
    HdsNavigation(this.pageInfos) {
      List({ space: 10 }) {
        ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)

        ListItem() {
          Stack({ alignContent: Alignment.Top }) {
            Swiper() {
              Column() {
                RecognitionCenterCardComponent()
              }
              .width('100%')
              .height(204)
              .padding({ left: 16, right: 16 })

              Column() {
                NetAssetOverviewCardComponent({
                  onAssetClick: () => {
                    this.navigateToAssetDetail();
                  }
                })
              }
              .width('100%')
              .height(204)
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .height(204)
            .autoPlay(false)
            .indicator(this.overviewIndicatorController)

            Row() {
              IndicatorComponent(this.overviewIndicatorController)
                .initialIndex(0)
                .style(new DotIndicator()
                  .itemWidth(5)
                  .itemHeight(5)
                  .selectedItemWidth(16)
                  .selectedItemHeight(5)
                  .color(this.themeState.compDivider)
                  .selectedColor(this.themeState.brand))
                .loop(false)
                .count(2)
            }
            .width('100%')
            .height(8)
            .justifyContent(FlexAlign.Center)
            .position({ x: 0, y: 207 })
          }
          .width('100%')
          .height(216)
        }

        ListItem() {
          Column() {
            PendingBillPreviewCardComponent({
              pendingCountText: '1',
              onViewAll: () => {
                this.navigateToPendingConfirmBills();
              }
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }

        ListItem() {
          Column() {
            WeeklyOverviewCardComponent({
              incomeText: this.getAmountText(this.monthlyIncome, false),
              expenseText: this.getAmountText(this.monthlyExpense, false),
              balanceText: this.getSignedAmountText(this.monthlyBalance, false),
              balancePositive: this.monthlyBalance >= 0
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }

        ListItem() {
          HomeAssetBudgetCardsComponent({
            currentMonthText: this.currentMonthText,
            budgetRemainingText: this.getAmountText(this.budgetRemaining, false),
            usedBudgetText: this.getAmountText(this.monthlyExpense, false),
            totalBudgetText: this.getAmountText(this.totalBudget, false),
            dailyAvailableText: this.getAmountText(this.dailyBudgetRemaining, false),
            budgetUsagePercent: this.budgetUsagePercent,
            remainingDaysText: `剩余 ${this.remainingDaysOfMonth} 天`,
            onBudgetClick: () => {
              this.navigateToBudgetDetail();
            }
          })
            .width('100%')
            .padding({ left: 16, right: 16 })
        }

        ListItem() {
          Column() {
            RecentAutoBillsCardComponent({
              recentBills: this.sortedWeekBills,
              onEditBill: (billId: number): void => {
                this.openBillEditor(billId);
              },
              onDeleteBill: (billId: number): void => {
                this.deleteBill(billId);
              }
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 8 })
        }
      }
      .width('100%')
      .height('100%')
      .contentEndOffset(this.winUtil.mainWindowInfo.navIndicatorHeight + CommonConstants.TAB_HEIGHT + 16)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor($r('[shared_assets].color.start_window_background'))
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .backgroundColor($r('[shared_assets].color.start_window_background'))
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
            backgroundColor: this.themeState.backgroundPrimary,
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: this.themeState.fontPrimary,
              subTitleColor: this.themeState.fontSecondary
            },
            menuStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              iconColor: $r('[shared_assets].color.text_primary')
            },
            backIconStyle: {
              backgroundColor: this.themeState.compBackgroundNeutral,
              iconColor: this.themeState.fontPrimary
            },
          }
        },
        scrollEffectStyle: {
          backgroundStyle: {
            backgroundColor: this.themeState.backgroundPrimary,
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: this.themeState.fontPrimary,
              subTitleColor: this.themeState.fontSecondary,
            },
            menuStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              textColor: $r('[shared_assets].color.text_secondary'),
              iconColor: $r('[shared_assets].color.text_primary')
            },
            backIconStyle: {
              backgroundColor: this.themeState.compBackgroundNeutral,
              iconColor: this.themeState.fontPrimary
            }
          }
        }
      },
      content: {
        title: {
          mainTitle: '纸鸢账本',
          subTitle: '智能识别记账'
        },
        menu: {
          value: [{
            content: {
              icon: $r('sys.symbol.book'),
              label: '账本',
              action: () => {
                this.navigateToSubPage(RouterUrlConstants.LEDGER_SWITCH);
              },
            }
          }]
        },
      },
      avoidLayoutSafeArea: true
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .bindSheet($$this.isBillEditorVisible, this.BillEditorSheetBuilder(), {
      detents: [SheetSize.LARGE],
      preferType: SheetType.BOTTOM,
      title: {
        title: '编辑账单'
      }
    })
  }

  @Builder
  private BillEditorSheetBuilder() {
    AddBillSheetComponent({
      themeState: this.themeState,
      optionSystem: this.optionSystem,
      editingBillId: this.editingBillId,
      onClose: () => {
        this.closeBillEditor();
      },
      onSaved: () => {
        this.handleBillEdited();
      }
    })
  }
}
