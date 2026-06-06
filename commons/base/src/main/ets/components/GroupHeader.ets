/**
 * Copyright (C), 2025-05-14
 * @author ZestBox
 * @date 2025/05/14
 * @version 1.0
 * @description: ListItemGroup 通用头部组件
 */

/**
 * GroupHeader Builder 函数
 * @param title 主标题
 * @param subtitle 副标题（可选）
 */
@Builder
export function GroupHeader(title: string, subtitle: string = '') {
  Row() {
    Text(title)
      .fontSize(12)
      .fontColor($r('[shared_assets].color.text_secondary'))

    if (subtitle.length > 0) {
      Text(subtitle)
        .fontSize(12)
        .fontColor($r('[shared_assets].color.text_secondary'))
    }
  }
  .width('100%')
  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  .justifyContent(FlexAlign.SpaceBetween)
}
