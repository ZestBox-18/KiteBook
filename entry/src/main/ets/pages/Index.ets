/**
 * Copyright (C), 2026-03-22
 * @author ZestBox
 * @date 2026-03-22 
 * @version 1.0
 * @description: 
 */
import { hdsMaterial } from '@hms.hds.hdsMaterial'
import { HdsTabs, HdsTabsController } from '@kit.UIDesignKit';
import { Clog } from 'kite_utils';

const TAG: string = '[Index]';




@Entry
@ComponentV2
struct Index {
  // 初始化HdsTabs控制器。
  private controller: HdsTabsController = new HdsTabsController();

  @Builder
  tabContentBuilder(color: Color) {
    List() {
      ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], (item: number) => {
        ListItem() {
          Column() {
            Row() {
            }.height(200)
            .width('100%')
            .onClick(()=>{
              Clog.log(TAG,123)
            })

            Row() {
            }.width('100%')
            .height(50)
            .background(color)
          }
        }
      })
    }
  }



  build() {
    Column() {
      HdsTabs({ controller: this.controller }) {
        TabContent() {
          this.tabContentBuilder(Color.Green)
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.ohos_ic_public_clock'), 'Green'))

        TabContent() {
          this.tabContentBuilder(Color.Blue)
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.wifi_router_fill'), 'Blue'))

        TabContent() {
          this.tabContentBuilder(Color.Yellow)
        }
        .tabBar(new BottomTabBarStyle($r('sys.media.ohos_ic_public_clock'), 'Yellow'))
      }
      // 设置barOverlap为true，vertical为false，barPosition为BarPosition.End
      .barOverlap(true)
      .barPosition(BarPosition.End)
      .vertical(false)
      // 设置页签栏悬浮样式。
      .barFloatingStyle({
        barWidth: { smallWidth: 200, mediumWidth: 300, largeWidth: 400 },
        barBottomMargin: 28,
        gradientMask: { maskColor: '#66F1F3F5', maskHeight: 92 },
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.EXQUISITE
        },
        thermoCtrl:true,
      })
    }
  }
}