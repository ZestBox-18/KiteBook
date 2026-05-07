/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 快捷按钮组件
 */

import { CategoryItem } from '../entities/CategoryItem';

@ComponentV2
export struct QuickButton {
  @Param category: CategoryItem = new CategoryItem();
  @Param onButtonClick: () => void = () => {};
  
  build() {
    Column() {
      // 图标
      Text(this.category.icon)
        .fontSize(24)
      
      // 名称
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
