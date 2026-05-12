/**
 * Copyright (C), 2026-05-11
 * @author ZestBox
 * @date 2026/05/11
 * @version 1.0
 * @description: 悬浮记账按钮
 */

import { HdsMiniBarButton } from 'kite_utils';
import { hdsMaterial } from '@kit.UIDesignKit';
import { SystemOptions, AppThemeState, fabController } from 'base';

const TAG: string = '[DraggableFab]';
const BUTTON_SIZE: number = 56;

@ComponentV2
export struct DraggableFab {
  @Require @Param optionSystem: SystemOptions;
  @Require @Param themeState: AppThemeState;
  @Event onFabClick: () => void = () => {
  };

  build() {
    HdsMiniBarButton({
      controller: fabController,
      barWidth: BUTTON_SIZE,
      barHeight: BUTTON_SIZE,
      materialType: hdsMaterial.MaterialType.IMMERSIVE,
      materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
      thermoCtrl: true,
      lightColor: this.themeState.brand as ResourceColor,
      onButtonClick: () => {
        this.onFabClick();
      }
    }) {
      // 自定义按钮内容，支持主题色和粗细
      SymbolGlyph($r('sys.symbol.plus'))
        .fontSize(28)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([this.themeState.iconPrimary as ResourceColor])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
    }
  }
}
