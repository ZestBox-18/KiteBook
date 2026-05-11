/**
 * Copyright (C), 2026-03-22
 * @author ZestBox
 * @date 2026-03-22 
 * @version 1.0
 * @description: 主入口页面，包含底部 Tab 导航
 */
import { hdsMaterial, HdsTabs, HdsTabsController, HdsAnimationMode } from '@kit.UIDesignKit';
import { RouterUrlConstants, mainTabController, SystemOptions, gAppThemes, AppThemeState } from 'base';
import { Billing } from 'billing';
import { Home } from 'home';
import { WindowUtil, BreakpointSystem, BreakpointConstants } from 'kite_utils';
import { Profile } from 'profile';
import { Reports } from 'reports';
import { AppStorageV2, PersistenceV2, ThemeControl, Theme, SymbolGlyphModifier } from '@kit.ArkUI';

const TAG: string = '[Index]';

@Entry
@ComponentV2
struct Index {
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
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

  build() {
    Column() {
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
      .barFloatingStyle({
        barBottomMargin: 28,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.EXQUISITE
        },
        thermoCtrl: true,
      })
    }
  }
}
