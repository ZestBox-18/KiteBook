/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 设置项组件
 */

@ComponentV2
export struct SettingsItem {
  // 图标
  @Param icon: ResourceStr = ''
  // 标题
  @Param title: string = ''
  // 点击回调
  @Param onItemClick: () => void = () => {}

  build() {
    Row() {
      Row() {
        Text(this.icon)
          .fontSize(18)
        Text(this.title)
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
          .margin({ left: 12 })
      }
      .layoutWeight(1)

      Text('›')
        .fontSize(18)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(() => {
      this.onItemClick()
    })
  }
}
