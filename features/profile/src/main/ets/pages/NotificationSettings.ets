/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 通知设置页面
 */

import { SystemOptions } from 'base';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';

@ComponentV2
export struct NotificationSettings {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!

  build() {
    NavDestination() {
      Column() {
        // 通知开关
        Row() {
          Text('消息通知')
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))

          Blank()

          Toggle({ type: ToggleType.Switch, isOn: this.optionSystem.notificationEnabled })
            .selectedColor($r('app.color.brand'))
            .onChange((isOn: boolean) => {
              this.optionSystem.notificationEnabled = isOn
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        // 说明文字
        Text('开启后，将接收账单提醒、系统通知等消息')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .padding({ left: 20, right: 20, top: 12 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.title_bar_bg'))
    }
    .title('通知设置')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}
