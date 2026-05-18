/**
 * Copyright (C), 2025-05-13
 * @author ZestBox
 * @date 2025/05/15
 * @version 1.0
 * @description: 空状态占位组件
 */

import { AppThemeState } from 'base';

@ComponentV2
export struct EmptyStateComponent {
  @Param text: string = '';
  @Param themeState: AppThemeState = new AppThemeState();

  /**
   * 构建首页列表空状态占位视图。
   */
  build() {
    Column() {
      SymbolGlyph($r('sys.symbol.doc_text'))
        .fontSize(48)
        .fontColor([this.themeState.iconSecondary])
      Text(this.text)
        .fontSize(15)
        .fontColor(this.themeState.fontSecondary)
        .margin({ top: 12 })
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }
}
