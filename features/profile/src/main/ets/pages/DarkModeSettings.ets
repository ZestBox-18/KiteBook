/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 深色模式页面
 */

import { SystemOptions } from 'base';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';

@ComponentV2
export struct DarkModeSettings {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!

  private modes: string[] = ['auto', 'light', 'dark']
  private modeNames: string[] = ['跟随系统', '浅色模式', '深色模式']

  build() {
    NavDestination() {
      Column() {
        ForEach(this.modes, (mode: string, index: number) => {
          Row() {
            Text(this.modeNames[index])
              .fontSize(15)
              .fontColor($r('app.color.text_primary'))

            Blank()

            if (this.optionSystem.darkMode === mode) {
              Text('✓')
                .fontSize(16)
                .fontColor($r('app.color.brand'))
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ left: 16, right: 16, top: index === 0 ? 16 : 8 })
          .onClick(() => {
            this.optionSystem.darkMode = mode
          })
        }, (mode: string) => mode)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.title_bar_bg'))
    }
    .title('深色模式')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}
