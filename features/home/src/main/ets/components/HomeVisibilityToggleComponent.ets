/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页金额显隐切换按钮
 */

import { AppThemeState } from 'base';

@ComponentV2
export struct HomeVisibilityToggleComponent {
  @Param hidden: boolean = false;
  @Param themeState: AppThemeState = new AppThemeState();
  @Event onToggle: () => void = () => {
  };

  /**
   * 构建金额显隐切换按钮。
   */
  build() {
    Button() {
      SymbolGlyph(this.hidden ? $r('sys.symbol.eye_slash') : $r('sys.symbol.eye'))
        .fontSize(16)
        .fontColor([this.themeState.fontPrimary as ResourceColor])
    }
    .width(34)
    .height(34)
    .padding(0)
    .backgroundColor('#FCFAF6')
    .border({ width: 1, color: '#EEE4D8' })
    .borderRadius(17)
    .onClick(() => {
      this.onToggle();
    })
  }
}
