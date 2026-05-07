/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 浮动按钮默认状态组件
 */

@ComponentV2
export struct FABDefault {
  @Param onFABClick: () => void = () => {};

  build() {
    Button() {
      SymbolGlyph($r('sys.symbol.plus'))
        .fontSize(24)
        .fontColor([$r('sys.color.font_on_primary')])
    }
    .width(56)
    .height(56)
    .backgroundColor($r('app.color.brand'))
    .borderRadius(28)
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      this.onFABClick();
    })
  }
}
