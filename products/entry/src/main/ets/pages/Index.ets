/**
 * Copyright (C), 2026-03-22
 * @author ZestBox
 * @date 2026-03-22 
 * @version 1.0
 * @description: 主入口页面，包含底部 Tab 导航
 */
import { hdsMaterial, HdsTabs, HdsTabsController, HdsAnimationMode } from '@kit.UIDesignKit';
import { RouterUrlConstants, mainTabController } from 'base';
import { Billing } from 'billing';
import { Home } from 'home';
import { WindowUtil, BreakpointSystem, BreakpointConstants } from 'kite_utils';
import { Profile } from 'profile';
import { Reports } from 'reports';
import { AppStorageV2, CustomColors, ThemeControl } from '@kit.ArkUI';

const TAG: string = '[Index]';


@Entry
@ComponentV2
struct Index {
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  // 断点系统
  @Local breakpointSystem: BreakpointSystem =
    AppStorageV2.connect(BreakpointSystem, 'breakpointSystem', () => new BreakpointSystem())!;

  aboutToAppear(): void {
    // 注册断点监听
    this.breakpointSystem.register();

    setTimeout(() => {
      class DefaultAppColors implements CustomColors {
        brand: string = '#a980ff00'; // 高亮图标
      }

      class DefaultAppColors1 implements CustomColors {
        brand: string = '#e8d20565'; // 高亮图标
      }

      class DefaultAppTheme implements CustomTheme {
        public colors: DefaultAppColors = new DefaultAppColors()
        public darkColors: DefaultAppColors1 = new DefaultAppColors1()
      }

      let defaultAppTheme: CustomTheme = new DefaultAppTheme();
      ThemeControl.setDefaultTheme(defaultAppTheme)
    }, 5000)
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
        .tabBar(new BottomTabBarStyle($r('sys.media.ohos_ic_public_clock'), RouterUrlConstants.HOME))

        TabContent() {
          Billing()
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.wifi_router_fill'), RouterUrlConstants.BILLING))

        TabContent() {
          Reports()
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.ohos_ic_public_clock'), RouterUrlConstants.REPORTS))

        TabContent() {
          Profile()
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.ohos_ic_public_clock'), RouterUrlConstants.PROFILE))
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