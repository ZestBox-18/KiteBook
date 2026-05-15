/**
 * Copyright (C), 2025-05-13
 * @author ZestBox
 * @date 2025/05/15
 * @version 1.0
 * @description: 区域标题栏组件
 */

import { AppThemeState } from 'base';

@ComponentV2
export struct SectionHeaderComponent {
  @Param title: string = '';
  @Param action: string = '';
  @Event onAction: () => void = () => {
  };
  @Param themeState: AppThemeState = new AppThemeState();

  build() {
    Row() {
      Text(this.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)
      Text(this.action)
        .fontSize(14)
        .fontColor(this.themeState.brand)
        .onClick(this.onAction)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      right: 16,
      top: 20,
      bottom: 12
    })
  }
}
