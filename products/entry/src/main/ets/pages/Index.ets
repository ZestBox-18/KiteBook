/**
 * Copyright (C), 2026-03-22
 * @author ZestBox
 * @date 2026-03-22 
 * @version 1.0
 * @description:
 */
import { hdsMaterial } from '@hms.hds.hdsMaterial';
import { HdsTabs, HdsTabsController } from '@kit.UIDesignKit';
import { RouterUrlConstants } from 'base';
import { Billing } from 'billing';
import { Home } from 'home';
import { WindowUtil } from 'kite_utils';
import { Profile } from 'profile';
import { Reports } from 'reports';
import { AppStorageV2, CustomColors, ThemeControl } from '@kit.ArkUI';

const TAG: string = '[Index]';


@Entry
@ComponentV2
struct Index {
  // 初始化HdsTabs控制器。
  private controller: HdsTabsController = new HdsTabsController();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;

  aboutToAppear(): void {

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
      console.log('123')
    }, 5000)
  }

  build() {
    Column() {
      HdsTabs({ controller: this.controller }) {
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
      // 设置barOverlap为true，vertical为false，barPosition为BarPosition.End
      .barOverlap(true)
      .barPosition(BarPosition.End)
      .vertical(false)
      // 设置页签栏悬浮样式。
      .barFloatingStyle({
        barWidth: { smallWidth: 200, mediumWidth: 300, largeWidth: 400 },
        barBottomMargin: 28,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.EXQUISITE
        },
        thermoCtrl: true,
        lightColor: Color.Red
      })
    }
  }
}