/**
 * Copyright (C), 2026-03-22
 * @author ZestBox
 * @date 2026-03-22 
 * @version 1.0
 * @description: 主入口页面，包含底部 Tab 导航
 */
import { hdsMaterial, HdsAnimationMode, HdsTabs } from '@kit.UIDesignKit';
import {
  billSyncController,
  CommonConstants,
  mainTabController,
  RouterUrlConstants,
  SystemOptions,
  gAppThemes,
  AppThemeState
} from 'base';
import { Billing } from 'billing';
import { Home } from 'home';
import { AddBillSheetComponent, CategoryManage } from 'record';
import { WindowUtil, BreakpointSystem, ImmersiveDraggableFab } from 'kite_utils';
import { Profile } from 'profile';
import { Reports } from 'reports';
import { AppStorageV2, PersistenceV2, ThemeControl, Theme, SymbolGlyphModifier } from '@kit.ArkUI';

const TAB_SWITCH_ANIMATION_DURATION: number = 280;

@Entry
@ComponentV2
struct Index {
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  @Local isBillingSheetShown: boolean = false
  @Local currentTabIndex: number = 0
  @Local pageInfos: NavPathStack = new NavPathStack()
  // 断点系统
  @Local breakpointSystem: BreakpointSystem =
    AppStorageV2.connect(BreakpointSystem, 'breakpointSystem', () => new BreakpointSystem())!;
  // 主题颜色
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;

  aboutToAppear(): void {
    // 注册断点监听
    this.breakpointSystem.register();


    if (this.optionSystem.themeIndex >= 0 && this.optionSystem.themeIndex < gAppThemes.length) {
      ThemeControl.setDefaultTheme(gAppThemes[this.optionSystem.themeIndex]);
    } else {
      ThemeControl.setDefaultTheme(gAppThemes[0]);
    }
  }

  aboutToDisappear(): void {
    this.breakpointSystem.unregister();
  }

  onWillApplyTheme(theme: Theme): void {
    this.themeState.brand = theme.colors.brand as ResourceStr;
    this.themeState.fontPrimary = theme.colors.fontPrimary as ResourceStr;
    this.themeState.fontSecondary = theme.colors.fontSecondary as ResourceStr;
    this.themeState.fontOnPrimary = theme.colors.fontOnPrimary as ResourceStr;
    this.themeState.iconPrimary = theme.colors.iconPrimary as ResourceStr;
    this.themeState.iconSecondary = theme.colors.iconSecondary as ResourceStr;
    this.themeState.iconEmphasize = theme.colors.iconEmphasize as ResourceStr;
    this.themeState.iconOnPrimary = theme.colors.iconOnPrimary as ResourceStr;
    this.themeState.backgroundPrimary = theme.colors.backgroundPrimary as ResourceStr;
    this.themeState.compBackgroundPrimary = theme.colors.compBackgroundPrimary as ResourceStr;
    this.themeState.compBackgroundNeutral = theme.colors.compBackgroundNeutral as ResourceStr;
    this.themeState.compDivider = theme.colors.compDivider as ResourceStr;
  }

  // 创建带主题色的 TabBarSymbol
  private createTabBarSymbol(icon: Resource): TabBarSymbol {
    return {
      normal: new SymbolGlyphModifier(icon)
        .fontColor([this.themeState.iconSecondary])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .fontSize(24)
        .fontWeight(this.optionSystem.iconThickness),
      selected: new SymbolGlyphModifier(icon)
        .fontColor([this.themeState.brand])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .fontSize(24)
        .fontWeight(this.optionSystem.iconThickness)
    };
  }

  /**
   * 打开全局新增账单半模态。
   */
  private openBillingModal(): void {
    this.isBillingSheetShown = true;
  }

  /**
   * 关闭新增账单半模态。
   */
  private closeBillingModal(): void {
    this.isBillingSheetShown = false;
  }

  /**
   * 全局页面路由映射。
   */
  @Builder
  PagesMap(name: string) {
    if (name === RouterUrlConstants.CATEGORY_MANAGE) {
      CategoryManage()
    }
  }

  /**
   * 从记账半模态进入分类管理页。
   */
  private navigateToCategoryManage(): void {
    this.closeBillingModal();
    mainTabController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
    setTimeout(() => {
      this.pageInfos.pushPath({ name: RouterUrlConstants.CATEGORY_MANAGE });
    }, 120);
  }

  /**
   * 在新增账单成功后通知首页刷新数据。
   */
  private handleBillSaved(): void {
    billSyncController.notifyBillChanged();
  }

  /**
   * 构建新增账单半模态内容。
   */
  @Builder
  AddBillSheetBuilder() {
    AddBillSheetComponent({
      themeState: this.themeState,
      optionSystem: this.optionSystem,
      onClose: () => {
        this.closeBillingModal();
      },
      onSaved: () => {
        this.handleBillSaved();
      },
      onManageCategory: () => {
        this.navigateToCategoryManage();
      }
    })
  }

  @Builder
  private AddBillFabBuilder() {
    ImmersiveDraggableFab({
      icon: $r('sys.symbol.plus'),
      label: '记',
      iconColor: this.themeState.brand as ResourceColor,
      labelColor: this.themeState.brand as ResourceColor,
      lightColor: this.themeState.brand as ResourceColor,
      iconFontWeight: this.optionSystem.iconThickness,
      bottomReserve: this.winUtil.mainWindowInfo.navIndicatorHeight + CommonConstants.TAB_HEIGHT + 22,
      onFabClick: () => {
        this.openBillingModal();
      }
    })
    .bindSheet($$this.isBillingSheetShown, this.AddBillSheetBuilder(), {
      detents: [SheetSize.LARGE],
      preferType: SheetType.BOTTOM,
      showClose: false,
      enableFloatingDragBar: true,
    })
  }

  build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.TopStart }) {
        HdsTabs({ controller: mainTabController }) {
          TabContent() {
            Home()
          }
          .tabBar(new BottomTabBarStyle(this.createTabBarSymbol($r('sys.symbol.house')), '首页')
            .labelStyle({
              selectedColor: this.themeState.brand,
              unselectedColor: this.themeState.fontSecondary
            }))

          TabContent() {
            Billing()
          }
          .tabBar(new BottomTabBarStyle(this.createTabBarSymbol($r('sys.symbol.creditcard')), '账单')
            .labelStyle({
              selectedColor: this.themeState.brand,
              unselectedColor: this.themeState.fontSecondary
            }))

          TabContent() {
            Reports()
          }
          .tabBar(new BottomTabBarStyle(this.createTabBarSymbol($r('sys.symbol.list_bullet')), '报表')
            .labelStyle({
              selectedColor: this.themeState.brand,
              unselectedColor: this.themeState.fontSecondary
            }))

          TabContent() {
            Profile()
          }
          .tabBar(new BottomTabBarStyle(this.createTabBarSymbol($r('sys.symbol.person')), '我的')
            .labelStyle({
              selectedColor: this.themeState.brand,
              unselectedColor: this.themeState.fontSecondary
            }))
        }
        .barOverlap(true)
        .barPosition(BarPosition.End)
        .vertical(false)
        .animationDuration(TAB_SWITCH_ANIMATION_DURATION)
        .barFloatingStyle({
          barBottomMargin: this.winUtil.mainWindowInfo.navIndicatorHeight,
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.IMMERSIVE,
            materialLevel: hdsMaterial.MaterialLevel.EXQUISITE
          },
          thermoCtrl: true,
          lightColor: this.themeState.brand as ResourceColor
        })
        .onSelected((index: number) => {
          this.currentTabIndex = index;
        })
        .onChange((index: number) => {
          this.currentTabIndex = index;
        })
        .width('100%')
        .height('100%')

        if (this.currentTabIndex !== 3) {
          this.AddBillFabBuilder()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.PagesMap)
  }
}
