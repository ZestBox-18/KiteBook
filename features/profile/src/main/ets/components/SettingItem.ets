/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 设置列表项组件
 */

// 样式扩展
@Extend(Text)
function SettingItemTitleStyles() {
  .fontSize(16)
  .fontColor($r('app.color.text_primary'))
}

@Extend(Row)
function SettingItemRowStyles() {
  .justifyContent(FlexAlign.SpaceBetween)
  .width('100%')
  .height(48)
  .padding({ left: 16, right: 16 })
  .borderRadius(8)
}

// 设置列表项组件
@ComponentV2
export struct SettingItem {
  // 图标
  @Param icon: Resource = $r('sys.symbol.gearshape')
  // 标题（必填）
  @Param @Require title: ResourceStr | string = ''
  // 点击回调
  @Event onItemClick: () => void = () => {}
  // 按压状态
  @Local isPressed: boolean = false

  build() {
    Row() {
      // 左侧：图标 + 标题
      Row({ space: 12 }) {
        SymbolGlyph(this.icon)
          .fontSize(20)
          .fontColor([$r('app.color.text_primary')])

        Text(this.title)
          .SettingItemTitleStyles()
      }

      // 右侧箭头
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(20)
        .fontColor([$r('app.color.text_primary')])
    }
    .SettingItemRowStyles()
    .backgroundColor(this.isPressed ? $r('app.color.item_pressed') : $r('app.color.card_background'))
    .animation({
      duration: 150,
      curve: Curve.EaseOut
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
    .onClick(() => {
      this.onItemClick()
    })
  }
}
