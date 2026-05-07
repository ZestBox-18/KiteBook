/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 分类按钮组件
 */

import { CategoryItem } from '../entities/CategoryItem';

@ComponentV2
export struct CategoryButton {
  @Param category: CategoryItem = new CategoryItem();
  @Param onButtonClick: () => void = () => {};
  @Param index: number = 0;

  build() {
    Column() {
      SymbolGlyph($r(this.category.icon))
        .fontSize(24)
        .fontColor([$r('sys.color.font_primary')])

      Text(this.category.name)
        .fontSize(12)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: 4 })
    }
    .width(60)
    .height(70)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius(12)
    .onClick(() => {
      this.onButtonClick();
    })
  }
}
