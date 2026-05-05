/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 关于页面
 */

@ComponentV2
export struct About {
  @Local pageInfos: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        // 应用图标和名称
        Column() {
          Column()
            .width(72)
            .height(72)
            .borderRadius(16)
            .linearGradient({
              angle: 135,
              colors: [['#2FB04A', 0], ['#1a7a2d', 1]]
            })

          Text('纸鸢账本')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 16 })

          Text('版本 1.0.0')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .margin({ top: 32 })

        // 信息列表
        Column() {
          this.InfoItem('应用名称', '纸鸢账本')
          Divider().margin({ left: 16 })
          this.InfoItem('版本号', '1.0.0')
          Divider().margin({ left: 16 })
          this.InfoItem('开发者', 'ZestBox')
        }
        .width('100%')
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 32 })

        // 版权信息
        Text('© 2026 ZestBox. All rights reserved.')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 32 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.title_bar_bg'))
    }
    .title('关于')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }

  @Builder
  InfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))

      Blank()

      Text(value)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
    }
    .width('100%')
    .padding(16)
  }
}
