/**
 * Copyright (C), 2025-05-13
 * @author ZestBox
 * @date 2025/05/15
 * @version 1.0
 * @description: 滑动删除按钮组件
 */

@ComponentV2
export struct DeleteSwipeButtonComponent {
  @Event onDelete: () => void = () => {
  };

  build() {
    Button() {
      SymbolGlyph($r('sys.symbol.trash'))
        .fontSize(20)
        .fontColor(['#FFFFFF'])
    }
    .width(64)
    .height(60)
    .backgroundColor('#EF4444')
    .borderRadius(0)
    .onClick(this.onDelete)
  }
}
