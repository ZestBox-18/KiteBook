/**
 * Copyright (C), 2026-03-22
 * @author ZestBox
 * @date 2026-03-22 
 * @version 1.0
 * @description: 主入口页面，包含底部 Tab 导航
 */
import { hdsMaterial, HdsTabs, HdsTabsController, HdsAnimationMode } from '@kit.UIDesignKit';
import { RouterUrlConstants, mainTabController, SystemOptions, gAppThemes } from 'base';
import { Billing } from 'billing';
import { Home } from 'home';
import { WindowUtil, BreakpointSystem, BreakpointConstants } from 'kite_utils';
import { Profile } from 'profile';
import { Reports } from 'reports';
import { AppStorageV2, PersistenceV2, ThemeControl } from '@kit.ArkUI';

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

  build() {
    Column() {
      HdsTabs({ controller: mainTabController }) {
        TabContent() {
          Home()
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.ohos_ic_public_clock'), '首页'))

        TabContent() {
          Billing()
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.wifi_router_fill'), '账单'))

        TabContent() {
          Reports()
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.ohos_ic_public_clock'), '报表'))

        TabContent() {
          Profile()
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.ohos_ic_public_clock'), '我的'))
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