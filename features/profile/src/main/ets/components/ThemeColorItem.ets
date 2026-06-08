/**
 * Copyright (C), 2026-05-08
 * @author ZestBox
 * @date 2026/05/08
 * @version 1.0
 * @description: 主题颜色选择项组件
 */

import { curves, PersistenceV2 } from '@kit.ArkUI';
import { SystemOptions } from 'base';

@ComponentV2
export struct ThemeColorItem {
  // 主题颜色
  @Param @Require color: ResourceColor = '#5A7A8A';
  // 主题名称
  @Param @Require name: string = '';
  // 是否选中
  @Param isSelected: boolean = false;
  // 点击回调
  @Event onSelect: () => void = () => {
  };
  // 动画状态
  @Local circleWidth: number = 24;
  @Local circleHeight: number = 24;
  @Local circleX: number = 12;
  @Local circleY: number = 12;
  @Local circleBorderRadius: number = 12;
  @Local textColor: ResourceColor = $r('[shared_assets].color.text_primary');
  @Local textX: number = 44;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!

  // 监听选中状态变化
  @Monitor('isSelected')
  onSelectedChange(monitor: IMonitor): void {
    this.updateAnimationState();
  }

  // 更新动画状态
  private updateAnimationState(): void {
    if (this.isSelected) {
      // 选中状态：从中心扩展填充整个按钮
      this.circleWidth = 100;
      this.circleHeight = 48;
      this.circleX = 0;
      this.circleY = 0;
      this.circleBorderRadius = 8;
      this.textColor = Color.White;
      this.textX = 10;
    } else {
      // 未选中状态：小圆圈在左侧
      this.circleWidth = 24;
      this.circleHeight = 24;
      this.circleX = 12;
      this.circleY = 12;
      this.circleBorderRadius = 12;
      this.textColor = $r('[shared_assets].color.text_primary');
      this.textX = 44;
    }
  }

  // 组件初始化
  aboutToAppear(): void {
    this.updateAnimationState();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景色块
      Column()
        .width(this.circleWidth)
        .height(this.circleHeight)
        .borderRadius(this.circleBorderRadius)
        .backgroundColor(this.color)
        .position({ x: this.circleX, y: this.circleY })
        .animation({
          duration: 300,
          curve: curves.springMotion(0.6, 0.8)
        })

      // 文字
      Text(this.name)
        .fontSize(14)
        .fontColor(this.textColor)
        .fontWeight(this.optionSystem.fontThickness)
        .position({ x: this.textX, y: 17 })
        .animation({
          duration: 300,
          curve: curves.springMotion(0.6, 0.8)
        })
    }
    .width(100)
    .height(48)
    .borderRadius(12)
    .backgroundColor($r('[shared_assets].color.card_background'))
    .clip(true)
    .onClick(() => {
      this.onSelect();
    })
  }
}
