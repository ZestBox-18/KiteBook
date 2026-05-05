/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 数据导出页面
 */

@ComponentV2
export struct DataExport {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local exporting: boolean = false

  build() {
    NavDestination() {
      Column() {
        // 导出说明
        Column() {
          Text('数据导出')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text('将您的记账数据导出为 CSV 文件，可用于备份或导入其他设备。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })
        .alignItems(HorizontalAlign.Start)

        // 导出按钮
        Button(this.exporting ? '导出中...' : '导出数据')
          .width('100%')
          .height(48)
          .backgroundColor($r('app.color.brand'))
          .fontColor(Color.White)
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 24 })
          .enabled(!this.exporting)
          .onClick(() => {
            this.exporting = true
            // TODO: 实现导出逻辑
            setTimeout(() => {
              this.exporting = false
            }, 2000)
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.title_bar_bg'))
    }
    .title('数据导出')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}
