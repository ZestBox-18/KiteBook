/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 设置项分组组件
 */

@ComponentV2
export struct SettingsGroup {
  // 分组标题
  @Param title: string = ''
  // 内容
  @BuilderParam content: () => void

  build() {
    Column() {
      // 分组标题
      Text(this.title)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .padding({ left: 20, bottom: 8 })

      // 内容区域
      Column() {
        this.content()
      }
      .width('100%')
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(12)
      .margin({ left: 16, right: 16 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
