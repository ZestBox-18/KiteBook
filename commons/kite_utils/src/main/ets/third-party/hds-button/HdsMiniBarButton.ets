/**
 * Copyright 2024 hds_button Contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Original source: https://gitcode.com/SummerKaze/HdsButton_Component
 */

import { hdsMaterial, HdsTabs, HdsTabsController } from '@kit.UIDesignKit';

/**
 * HdsMiniBarButton 浮动迷你栏按钮组件
 * 基于 HdsTabs 的沉浸光感浮动按钮，支持全方位自定义配置
 */
@ComponentV2
export struct HdsMiniBarButton {
  // ==================== 控制器参数 ====================

  /**
   * 外部控制器，用于控制显示/隐藏动画
   * @default undefined - 使用内部默认控制器
   */
  @Param controller: HdsTabsController | undefined = undefined;
  // ==================== 尺寸参数 ====================

  /**
   * 按钮栏宽度
   * @default 50
   */
  @Param barWidth: number = 50;
  /**
   * 按钮栏高度
   * @default 50
   */
  @Param barHeight: number = 50;
  /**
   * 容器内边距（防止光效被裁切）
   * @default 8
   */
  @Param contentPadding: number = 8;
  /**
   * 容器尺寸，优先使用此值，未设置时自动计算
   * @default undefined
   */
  @Param containerSize: SizeOptions | undefined = undefined;
  // ==================== 图标参数 ====================

  /**
   * 图标资源（SymbolGlyph 资源类型）
   * @default $r('sys.symbol.plus')
   */
  @Param iconResource: Resource = $r('sys.symbol.plus');
  /**
   * 图标大小
   * @default 27
   */
  @Param iconSize: number = 27;
  /**
   * 图标颜色数组（支持渐变效果）
   * @default [Color.Gray]
   */
  @Param iconColor: ResourceColor[] = [Color.Gray];
  // ==================== 浮动样式参数 ====================

  /**
   * 遮罩颜色
   * @default Color.Transparent
   */
  @Param maskColor: ResourceColor = Color.Transparent;
  /**
   * 按钮栏底部边距
   * @default 8
   */
  @Param barBottomMargin: number = 8;
  /**
   * 材质类型（沉浸式效果）
   * @default hdsMaterial.MaterialType.IMMERSIVE
   */
  @Param materialType: hdsMaterial.MaterialType = hdsMaterial.MaterialType.IMMERSIVE;
  /**
   * 材质级别
   * @default hdsMaterial.MaterialLevel.ADAPTIVE
   */
  @Param materialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.ADAPTIVE;
  /**
   * 是否启用热力控制效果
   * @default false
   */
  @Param thermoCtrl: boolean = false;
  /**
   * 主题光效颜色
   * @default undefined
   */
  @Param lightColor: ResourceColor | undefined = undefined;
  // ==================== 布局参数 ====================

  /**
   * 按钮栏位置
   * @default BarPosition.End
   */
  @Param barPosition: BarPosition = BarPosition.End;
  /**
   * 按钮栏是否与内容重叠
   * @default true
   */
  @Param barOverlap: boolean = true;
  // ==================== 事件回调 ====================

  /**
   * 按钮点击事件回调
   * @default undefined
   */
  @Param onButtonClick: (() => void) | undefined = undefined;

  // ==================== 构建函数 ====================

  /**
   * 默认按钮图标构建函数
   * 使用 SymbolGlyph 渲染默认图标
   */
  @Builder
  defaultButtonBuilder() {
    SymbolGlyph(this.iconResource)
      .fontSize(this.iconSize)
      .fontColor(this.iconColor)
  }

  /**
   * 自定义内容槽位
   * 默认使用图标构建函数，可通过尾随闭包自定义内容
   */
  @BuilderParam buttonContent: () => void = this.defaultButtonBuilder;
  // ==================== 私有属性 ====================

  // 内部默认控制器（当外部未传入时使用）
  private defaultController: HdsTabsController = new HdsTabsController();

  // ==================== 私有方法 ====================

  /**
   * 获取实际使用的控制器
   * 优先使用外部传入的控制器，否则使用内部默认控制器
   */
  private getController(): HdsTabsController {
    return this.controller !== undefined ? this.controller : this.defaultController;
  }

  /**
   * 计算容器尺寸
   * 如果已设置 containerSize 则直接使用，否则根据 barWidth、barHeight 和 padding 计算
   * @returns 容器尺寸配置
   */
  private getComputedContainerSize(): SizeOptions {
    if (this.containerSize !== undefined) {
      return this.containerSize;
    }
    return {
      width: this.barWidth + this.contentPadding * 4,
      height: this.barHeight + this.contentPadding * 4
    };
  }

  // ==================== UI 构建 ====================

  /**
   * 构建组件 UI
   * 使用 Row 包裹 HdsTabs 实现浮动按钮效果
   */
  build() {
    Row() {
      HdsTabs({ controller: this.getController() }) {
        TabContent()
          .tabBar(this.buttonContent())
      }
      .clip(false)
      .barWidth(this.barWidth)
      .barHeight(this.barHeight)
      .barOverlap(this.barOverlap)
      .barPosition(this.barPosition)
      .barFloatingStyle({
        gradientMask: {
          maskColor: this.maskColor
        },
        barBottomMargin: this.barBottomMargin,
        systemMaterialEffect: {
          materialType: this.materialType,
          materialLevel: this.materialLevel
        },
        thermoCtrl: this.thermoCtrl,
        lightColor: this.lightColor
      })
      .onTabBarClick(() => {
        if (this.onButtonClick) {
          this.onButtonClick();
        }
      })
    }
    .size(this.getComputedContainerSize())
    .padding(this.contentPadding)
  }
}
