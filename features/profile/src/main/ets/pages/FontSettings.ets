/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 字体设置页面
 */

import { SystemOptions, CommonConstants, mainTabController } from 'base';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { WindowUtil } from 'kite_utils';

@ComponentV2
export struct FontSettings {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!

  build() {
    HdsNavDestination() {
      Column() {
        // 当前字体大小预览
        Column() {
          Text('字体大小预览')
            .fontSize(this.optionSystem.fontSize)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')
        .padding(24)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        // 滑块调节
        Column() {
          Row() {
            Text('小')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))

            Text(`${this.optionSystem.fontSize}`)
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Text('大')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          Slider({
            value: this.optionSystem.fontSize,
            min: 12,
            max: 20,
            step: 1
          })
            .width('100%')
            .blockColor($r('app.color.brand'))
            .trackColor($r('app.color.action_bg'))
            .selectedColor($r('app.color.brand'))
            .onChange((value: number) => {
              this.optionSystem.fontSize = Math.round(value)
            })
        }
        .width('100%')
        .padding(16)
        .margin({ top: 24 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.title_bar_bg'))
      .padding({ top: this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI })
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
          backgroundStyle: { backgroundColor: $r('app.color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: { backgroundColor: $r('app.color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        }
      },
      content: { title: { mainTitle: "字体大小" } },
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
