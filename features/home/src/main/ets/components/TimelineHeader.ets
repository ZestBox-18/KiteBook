/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 时间轴头部组件
 */

@ComponentV2
export struct TimelineHeader {
  @Param date: string = '';
  @Param billCount: number = 0;

  build() {
    Row() {
      Text(this.date)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))

      Blank()

      Text(this.billCount + '笔')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
    }
    .width('100%')
    .padding({ top: 16, bottom: 12 })
  }
}
