/**
 * Copyright (C), 2026-05-25
 * @author ZestBox
 * @date 2026/05/25
 * @version 1.0
 * @description: 预算管理页面
 */

import {
  AppThemeState,
  BillTypeEnum,
  BudgetBean,
  CategoryBean,
  CommonConstants,
  GroupHeader,
  SystemOptions,
  billSyncController,
  mainTabController
} from 'base';
import { BudgetManager, CategoryManager } from 'data_core';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { WindowUtil } from 'kite_utils';

@ObservedV2
class BudgetDraftItem {
  categoryName: string = '';
  categoryIcon: Resource = $r('sys.symbol.ellipsis_circle');
  @Trace amountText: string = '';

  constructor(categoryName: string, categoryIcon: Resource, amountText: string) {
    this.categoryName = categoryName;
    this.categoryIcon = categoryIcon;
    this.amountText = amountText;
  }
}

@ComponentV2
export struct BudgetSettings {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local budgetDrafts: BudgetDraftItem[] = [];
  @Local currentMonthText: string = '';
  @Local loading: boolean = false;
  @Local saving: boolean = false;

  private readonly monthAnchor: number = new Date(new Date().getFullYear(), new Date().getMonth(), 1).getTime();

  aboutToAppear(): void {
    this.currentMonthText = this.buildMonthText();
    this.loadBudgetDrafts();
  }

  private buildMonthText(): string {
    const date: Date = new Date(this.monthAnchor);
    return `${date.getFullYear()}年${(date.getMonth() + 1).toString().padStart(2, '0')}月`;
  }

  private async loadBudgetDrafts(): Promise<void> {
    this.loading = true;
    try {
      const categories: CategoryBean[] = await CategoryManager.getCategoriesByType(BillTypeEnum.EXPENSE);
      const budgets: BudgetBean[] = await BudgetManager.getBudgetsByMonth(BudgetManager.buildMonthKey(this.monthAnchor));
      const drafts: BudgetDraftItem[] = [];
      categories.forEach((category: CategoryBean) => {
        let amountText: string = '';
        budgets.forEach((budget: BudgetBean) => {
          if (budget.category === category.name) {
            amountText = budget.amount.toFixed(2);
          }
        });
        drafts.push(new BudgetDraftItem(category.name, category.getIconResource(), amountText));
      });
      this.budgetDrafts = drafts;
    } finally {
      this.loading = false;
    }
  }

  private normalizeBudgetAmount(value: string): number {
    const trimmedValue: string = value.trim();
    if (trimmedValue.length === 0) {
      return 0;
    }
    const amount: number = Number(trimmedValue);
    if (!Number.isFinite(amount) || amount < 0) {
      return -1;
    }
    return amount;
  }

  private async saveBudgets(): Promise<void> {
    if (this.saving) {
      return;
    }
    this.saving = true;
    try {
      for (let index = 0; index < this.budgetDrafts.length; index++) {
        const item: BudgetDraftItem = this.budgetDrafts[index];
        const amount: number = this.normalizeBudgetAmount(item.amountText);
        if (amount < 0) {
          this.showToast(`请输入正确的预算金额：${item.categoryName}`);
          this.saving = false;
          return;
        }
        await BudgetManager.saveBudget(
          item.categoryName,
          amount,
          BudgetManager.buildMonthKey(this.monthAnchor)
        );
      }
      billSyncController.notifyBillChanged();
      this.showToast('预算已保存');
      await this.loadBudgetDrafts();
    } finally {
      this.saving = false;
    }
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 1800
      });
    } catch {
    }
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          ListItemGroup({
            header: GroupHeader('预算说明', this.currentMonthText),
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Column({ space: 8 }) {
                Text('为支出分类设置本月预算，输入 0 或留空会清空该分类预算。')
                  .fontSize(14)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor(this.themeState.fontSecondary)
                  .lineHeight(20)
                  .width('100%')

                Text('保存后首页预算卡和报表页会同步刷新。')
                  .fontSize(12)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor(this.themeState.fontSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .alignItems(HorizontalAlign.Start)
            }
          }

          if (this.budgetDrafts.length > 0) {
            ListItemGroup({
              header: GroupHeader('分类预算', `${this.budgetDrafts.length} 个分类`),
              style: ListItemGroupStyle.CARD
            }) {
              ForEach(this.budgetDrafts, (item: BudgetDraftItem) => {
                ListItem() {
                  Row({ space: 12 }) {
                    SymbolGlyph(item.categoryIcon)
                      .fontSize(20)
                      .fontWeight(this.optionSystem.iconThickness)
                      .fontColor([this.themeState.brand as ResourceColor])

                    Text(item.categoryName)
                      .fontSize(16)
                      .fontWeight(this.optionSystem.fontThickness)
                      .fontColor(this.themeState.fontPrimary)
                      .layoutWeight(1)

                    TextInput({ text: item.amountText, placeholder: '0.00' })
                      .width(120)
                      .height(40)
                      .fontSize(14)
                      .type(InputType.Number)
                      .textAlign(TextAlign.End)
                      .fontColor(this.themeState.fontPrimary)
                      .backgroundColor(this.themeState.backgroundPrimary)
                      .borderRadius(12)
                      .padding({ left: 12, right: 12 })
                      .onChange((value: string) => {
                        item.amountText = value;
                      })
                  }
                  .width('100%')
                  .height(56)
                  .padding({ left: 16, right: 16 })
                }
              }, (item: BudgetDraftItem) => item.categoryName)
            }
          } else {
            ListItemGroup({
              header: GroupHeader('分类预算'),
              style: ListItemGroupStyle.CARD
            }) {
              ListItem() {
                Text(this.loading ? '正在读取分类预算...' : '当前还没有可设置预算的支出分类')
                  .fontSize(14)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor(this.themeState.fontSecondary)
                  .width('100%')
                  .padding(16)
              }
            }
          }

          ListItem() {
            Button(this.saving ? '保存中...' : '保存预算')
              .width('100%')
              .height(48)
              .backgroundColor(this.themeState.brand as ResourceColor)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontOnPrimary)
              .borderRadius(12)
              .enabled(!this.saving && !this.loading)
              .onClick(() => {
                this.saveBudgets();
              })
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('[shared_assets].color.title_bar_bg'))
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
            }
          }
        }
      },
      content: { title: { mainTitle: '预算管理' } },
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
}
