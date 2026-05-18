/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页 Swiper 卡片通用外壳组件
 */

import { AppThemeState } from 'base';

@ComponentV2
export struct HomeSwiperCardShellComponent {
  @Param themeState: AppThemeState = new AppThemeState();
  @Param compactLayout: boolean = false;
  @Param opacityValue: number = 1;
  @Param scaleValue: number = 1;
  @Param rotateValue: number = 0;
  @Param zIndexValue: number = 0;
  @Param heightValue: number = 236;
  @Param leftPadding: number = 20;
  @Param rightPadding: number = 20;
  @Param topPadding: number = 16;
  @Param bottomPadding: number = 16;
  @BuilderParam content: () => void;

  /**
   * 构建带统一圆角、边框和过渡属性的卡片外壳。
   */
  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .height(this.heightValue)
    .padding({
      left: this.leftPadding,
      right: this.rightPadding,
      top: this.topPadding,
      bottom: this.bottomPadding
    })
    .margin({ left: 8, right: 8 })
    .borderRadius(24)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .border({ width: 1, color: '#EEE6DA' })
    .opacity(this.opacityValue)
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .rotate({ z: 1, angle: this.rotateValue })
    .zIndex(this.zIndexValue)
  }
}
