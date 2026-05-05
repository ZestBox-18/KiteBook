/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 字体设置页面
 */

import { SystemOptions } from 'base';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';

@ComponentV2
export struct FontSettings {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!

  build() {
    NavDestination() {
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
    }
    .title('字体大小')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}
