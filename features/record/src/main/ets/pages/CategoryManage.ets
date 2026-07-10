/**
 * Copyright (C), 2026-06-17
 * @author ZestBox
 * @date 2026/06/17
 * @version 1.0
 * @description: 分类管理页面
 */

import { hdsMaterial, HdsAnimationMode, HdsNavDestination, ScrollEffectType } from '@kit.UIDesignKit';
import { AppStorageV2, LengthMetrics, PersistenceV2 } from '@kit.ArkUI';
import { AppThemeState, BillTypeEnum, CategoryBean, CommonConstants, SystemOptions, mainTabController } from 'base';
import { CategoryManager, CategoryUpdatePatch } from 'data_core';
import { Clog, WindowUtil } from 'kite_utils';

const TAG: string = '[CategoryManage]';
const CATEGORY_CARD_SIZE: number = 44;
const CATEGORY_ICON_CELL_HEIGHT: number = 62;

class CategoryOption {
  id: number = 0;
  label: string = '';
  iconKey: string = 'ellipsis_circle';
  icon: Resource = $r('sys.symbol.ellipsis_circle');
  isSystem: boolean = false;

  constructor(id: number, label: string, iconKey: string, icon: Resource, isSystem: boolean) {
    this.id = id;
    this.label = label;
    this.iconKey = iconKey;
    this.icon = icon;
    this.isSystem = isSystem;
  }
}

class CategoryIconOption {
  key: string = 'ellipsis_circle';
  icon: Resource = $r('sys.symbol.ellipsis_circle');

  constructor(key: string, icon: Resource) {
    this.key = key;
    this.icon = icon;
  }
}

@ComponentV2
export struct CategoryManage {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;
  @Local manageType: string = BillTypeEnum.EXPENSE;
  @Local expenseCategories: CategoryOption[] = [];
  @Local incomeCategories: CategoryOption[] = [];
  @Local isEditorVisible: boolean = false;
  @Local isEditingCategory: boolean = false;
  @Local editingCategoryId: number = 0;
  @Local categoryDraftLabel: string = '';
  @Local categoryDraftIconKey: string = 'ellipsis_circle';
  private readonly iconOptions: CategoryIconOption[] = [
    new CategoryIconOption('fork_knife', $r('sys.symbol.fork_knife')),
    new CategoryIconOption('car', $r('sys.symbol.car')),
    new CategoryIconOption('cart', $r('sys.symbol.cart')),
    new CategoryIconOption('gamecontroller', $r('sys.symbol.gamecontroller')),
    new CategoryIconOption('house', $r('sys.symbol.house')),
    new CategoryIconOption('cross_case', $r('sys.symbol.cross_case')),
    new CategoryIconOption('book', $r('sys.symbol.book')),
    new CategoryIconOption('creditcard', $r('sys.symbol.creditcard')),
    new CategoryIconOption('gift', $r('sys.symbol.gift')),
    new CategoryIconOption('arrow_up_circle', $r('sys.symbol.arrow_up_circle')),
    new CategoryIconOption('arrow_left_arrow_right', $r('sys.symbol.arrow_left_arrow_right')),
    new CategoryIconOption('ellipsis_circle', $r('sys.symbol.ellipsis_circle'))
  ];

  aboutToAppear(): void {
    this.loadCategories();
  }

  private buildCategoryOption(category: CategoryBean): CategoryOption {
    return new CategoryOption(category.id, category.name, category.icon, category.getIconResource(), category.isSystem);
  }

  private async loadCategories(): Promise<void> {
    try {
      const expenseCategories: CategoryBean[] = await CategoryManager.getCategoriesByType(BillTypeEnum.EXPENSE);
      const incomeCategories: CategoryBean[] = await CategoryManager.getCategoriesByType(BillTypeEnum.INCOME);
      this.expenseCategories = expenseCategories.map((item: CategoryBean) => this.buildCategoryOption(item));
      this.incomeCategories = incomeCategories.map((item: CategoryBean) => this.buildCategoryOption(item));
    } catch (err) {
      Clog.error(TAG, '加载分类失败', err);
      this.showToast('分类加载失败');
    }
  }

  private getManagedCategories(): CategoryOption[] {
    if (this.manageType === BillTypeEnum.INCOME) {
      return this.incomeCategories;
    }
    return this.expenseCategories;
  }

  private applyManagedCategories(categories: CategoryOption[]): void {
    if (this.manageType === BillTypeEnum.INCOME) {
      this.incomeCategories = categories;
      return;
    }
    this.expenseCategories = categories;
  }

  private openAddCategory(): void {
    this.isEditingCategory = false;
    this.editingCategoryId = 0;
    this.categoryDraftLabel = '';
    this.categoryDraftIconKey = 'ellipsis_circle';
    this.isEditorVisible = true;
  }

  private openEditCategory(item: CategoryOption): void {
    if (item.isSystem) {
      this.showToast('系统分类暂不支持编辑');
      return;
    }
    this.isEditingCategory = true;
    this.editingCategoryId = item.id;
    this.categoryDraftLabel = item.label;
    this.categoryDraftIconKey = item.iconKey;
    this.isEditorVisible = true;
  }

  private closeEditor(): void {
    this.categoryDraftLabel = '';
    this.editingCategoryId = 0;
    this.categoryDraftIconKey = 'ellipsis_circle';
    this.isEditorVisible = false;
  }

  private hasDuplicatedCategoryName(name: string): boolean {
    let duplicated: boolean = false;
    this.getManagedCategories().forEach((item: CategoryOption) => {
      if (item.label === name && item.id !== this.editingCategoryId) {
        duplicated = true;
      }
    });
    return duplicated;
  }

  private async saveCategoryDraft(): Promise<void> {
    const draftLabel: string = this.categoryDraftLabel.trim();
    if (draftLabel.length === 0) {
      this.showToast('请输入分类名称');
      return;
    }
    if (this.hasDuplicatedCategoryName(draftLabel)) {
      this.showToast('分类名称已存在');
      return;
    }

    try {
      if (this.isEditingCategory) {
        if (this.editingCategoryId <= 0) {
          this.showToast('当前分类不可编辑');
          return;
        }
        const patch: CategoryUpdatePatch = new CategoryUpdatePatch();
        patch.name = draftLabel;
        patch.icon = this.categoryDraftIconKey;
        await CategoryManager.updateCategory(this.editingCategoryId, patch);
      } else {
        await CategoryManager.addCategory(draftLabel, this.manageType, this.categoryDraftIconKey);
      }
      this.closeEditor();
      await this.loadCategories();
    } catch (err) {
      Clog.error(TAG, this.isEditingCategory ? '修改分类失败' : '新增分类失败', err);
      this.showToast(this.isEditingCategory ? '分类修改失败' : '分类添加失败');
    }
  }

  private async reorderCategories(fromIndex: number, toIndex: number): Promise<void> {
    const categories: CategoryOption[] = this.getManagedCategories().slice();
    if (fromIndex < 0 || fromIndex >= categories.length || toIndex < 0 || toIndex >= categories.length) {
      return;
    }
    const moved: CategoryOption = categories[fromIndex];
    categories.splice(fromIndex, 1);
    categories.splice(toIndex, 0, moved);
    this.applyManagedCategories(categories);

    try {
      const categoryIds: number[] = categories.map((item: CategoryOption) => item.id);
      await CategoryManager.updateCategorySortOrders(categoryIds);
    } catch (err) {
      Clog.error(TAG, '保存分类排序失败', err);
      this.showToast('分类排序保存失败');
      await this.loadCategories();
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

  private getDraftIconResource(): Resource {
    let selectedIcon: Resource = $r('sys.symbol.ellipsis_circle');
    this.iconOptions.forEach((item: CategoryIconOption) => {
      if (item.key === this.categoryDraftIconKey) {
        selectedIcon = item.icon;
      }
    });
    return selectedIcon;
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 12 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          ListItem() {
            this.TipsCard()
          }

          ListItem() {
            this.TypeSegment()
          }

          ListItem() {
            this.CategoryGridCard()
          }
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
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
      content: {
        title: {
          mainTitle: '分类管理',
          subTitle: '新增、编辑和拖拽排序'
        }
      },
      avoidLayoutSafeArea: true
    })
    .bindSheet($$this.isEditorVisible, this.CategoryEditorSheet(), {
      height: 440,
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
  private TipsCard() {
    Text('长按拖动分类可排序，轻触用户自定义分类可编辑；系统分类仅支持排序。')
      .width('100%')
      .padding(14)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeState.fontSecondary)
      .backgroundColor(this.themeState.compBackgroundPrimary)
      .borderRadius(16)
      .border({ width: 1, color: this.themeState.compDivider })
  }

  @Builder
  private TypeSegment() {
    Row({ space: 10 }) {
      this.TypeButton('支出', BillTypeEnum.EXPENSE)
      this.TypeButton('收入', BillTypeEnum.INCOME)
    }
    .width('100%')
  }

  @Builder
  private TypeButton(label: string, type: string) {
    Button(label)
      .layoutWeight(1)
      .height(44)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.manageType === type ? this.themeState.fontOnPrimary : this.themeState.fontPrimary)
      .backgroundColor(this.manageType === type ? this.themeState.brand as ResourceColor :
        this.themeState.compBackgroundPrimary)
      .borderRadius(16)
      .border({
        width: 1,
        color: this.manageType === type ? this.themeState.brand as ResourceColor : this.themeState.compDivider
      })
      .onClick(() => {
        this.closeEditor();
        this.manageType = type;
      })
  }

  @Builder
  private CategoryEditorSheet() {
    Column({ space: 12 }) {
      Text(this.isEditingCategory ? '编辑分类' : '添加分类')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.fontPrimary)
        .margin({ bottom: 6 })

      Row({ space: 12 }) {
        Row() {
          SymbolGlyph(this.getDraftIconResource())
            .fontSize(25)
            .fontWeight(this.optionSystem.iconThickness)
            .fontColor([this.themeState.brand as ResourceColor])
        }
        .width(50)
        .height(50)
        .justifyContent(FlexAlign.Center)
        .borderRadius(25)
        .backgroundColor(this.themeState.compBackgroundPrimary)
        .border({ width: 1, color: this.themeState.compDivider })

        TextInput({
          text: this.categoryDraftLabel,
          placeholder: '不能与已有分类名称重复'
        })
          .maxLength(6)
          .showCounter(true)
          .height(50)
          .fontSize(16)
          .fontColor(this.themeState.fontPrimary)
          .placeholderColor(this.themeState.fontSecondary)
          .backgroundColor(this.themeState.compBackgroundPrimary)
          .borderRadius(16)
          .padding({ left: 14, right: 14 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.categoryDraftLabel = value;
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Grid() {
        ForEach(this.iconOptions, (item: CategoryIconOption) => {
          GridItem() {
            this.CategoryIconCell(item)
          }
        }, (item: CategoryIconOption) => item.key)
      }
      .width('100%')
      .height(134)
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(10)
      .columnsGap(10)
      .margin({ top: 4, bottom: 4 })

      Row({ space: 10 }) {
        Button('取消')
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .backgroundColor(this.themeState.backgroundPrimary)
          .borderRadius(14)
          .border({ width: 1, color: this.themeState.compDivider })
          .onClick(() => {
            this.closeEditor();
          })
        Button(this.isEditingCategory ? '保存修改' : '添加分类')
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontOnPrimary)
          .backgroundColor(this.themeState.brand as ResourceColor)
          .borderRadius(14)
          .onClick(() => {
            this.saveCategoryDraft();
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 24, bottom: this.winUtil.mainWindowInfo.navIndicatorHeight + 16 })
    .backgroundColor($r('[shared_assets].color.title_bar_bg'))
  }

  @Builder
  private CategoryIconCell(item: CategoryIconOption) {
    Row() {
      SymbolGlyph(item.icon)
        .fontSize(22)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([this.categoryDraftIconKey === item.key ? this.themeState.fontOnPrimary as ResourceColor :
          this.themeState.brand as ResourceColor])
    }
    .width('100%')
    .height(CATEGORY_ICON_CELL_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .borderRadius(16)
    .backgroundColor(this.categoryDraftIconKey === item.key ? this.themeState.brand as ResourceColor :
      this.themeState.compBackgroundPrimary)
    .border({
      width: 1,
      color: this.categoryDraftIconKey === item.key ? this.themeState.brand as ResourceColor : this.themeState.compDivider
    })
    .onClick(() => {
      this.categoryDraftIconKey = item.key;
    })
  }

  @Builder
  private CategoryGridCard() {
    Grid() {
      ForEach(this.getManagedCategories(), (item: CategoryOption) => {
        GridItem() {
          this.CategoryItem(item)
        }
        .onClick(() => {
          this.openEditCategory(item);
        })
      }, (item: CategoryOption) => `${item.id}_${item.label}`)

      GridItem() {
        this.AddCategoryItem()
      }
      .onClick(() => {
        this.openAddCategory();
      })
    }
    .width('100%')
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(28)
    .columnsGap(8)
    .padding(14)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(18)
    .border({ width: 1, color: this.themeState.compDivider })
    .editMode(true)
    .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
      const categories: CategoryOption[] = this.getManagedCategories();
      if (itemIndex >= categories.length) {
        return undefined;
      }
      return this.DragPreview(categories[itemIndex]);
    })
    .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
      if (!isSuccess) {
        return;
      }
      this.reorderCategories(itemIndex, insertIndex);
    })
  }

  @Builder
  private CategoryItem(item: CategoryOption) {
    Column({ space: 8 }) {
      Row() {
        SymbolGlyph(item.icon)
          .fontSize(26)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.brand as ResourceColor])
      }
      .width(CATEGORY_CARD_SIZE)
      .height(CATEGORY_CARD_SIZE)
      .justifyContent(FlexAlign.Center)
      .borderRadius(22)
      .backgroundColor(this.themeState.backgroundPrimary)
      .border({ width: 1, color: this.themeState.compDivider })

      Text(item.label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(item.isSystem ? '系统' : '轻触编辑')
        .fontSize(10)
        .fontColor(this.themeState.fontSecondary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private AddCategoryItem() {
    Column({ space: 8 }) {
      Row() {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize(26)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.brand as ResourceColor])
      }
      .width(CATEGORY_CARD_SIZE)
      .height(CATEGORY_CARD_SIZE)
      .justifyContent(FlexAlign.Center)
      .borderRadius(22)
      .backgroundColor(this.themeState.backgroundPrimary)
      .border({ width: 1, color: this.themeState.compDivider })

      Text('添加')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)

      Text('自定义')
        .fontSize(10)
        .fontColor(this.themeState.fontSecondary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private DragPreview(item: CategoryOption) {
    Row() {
      SymbolGlyph(item.icon)
        .fontSize(34)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([this.themeState.fontOnPrimary as ResourceColor])
    }
    .width(72)
    .height(72)
    .justifyContent(FlexAlign.Center)
    .borderRadius(24)
    .backgroundColor(this.themeState.brand as ResourceColor)
  }
}
