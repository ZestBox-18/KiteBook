/**
 * Copyright (C), 2026-06-16
 * @author ZestBox
 * @date 2026/06/16
 * @version 1.0
 * @description: 系统颜色模式工具
 */

import { ConfigurationConstant, common } from '@kit.AbilityKit';

export class SystemColorModeUtil {
  /**
   * 将应用内保存的模式值映射为系统颜色模式。
   */
  static getSystemColorMode(mode: string): ConfigurationConstant.ColorMode {
    switch (mode) {
      case 'dark':
        return ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      case 'light':
        return ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      default:
        return ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    }
  }

  /**
   * 立即应用系统颜色模式，mode 支持 dark、light、auto。
   * setColorMode 可能抛出系统异常，启动流程等关键调用方需要自行捕获并记录。
   */
  static applySystemColorMode(context: common.UIAbilityContext, mode: string): void {
    context.getApplicationContext().setColorMode(SystemColorModeUtil.getSystemColorMode(mode));
  }
}
