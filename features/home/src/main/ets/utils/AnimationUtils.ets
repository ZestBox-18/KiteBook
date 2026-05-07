/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 动画工具类
 */

import { curves } from '@kit.ArkUI';

/**
 * 动画工具类
 */
export class AnimationUtils {
  /**
   * 创建弹性动画曲线
   */
  static createSpringCurve(stiffness: number = 0.6, damping: number = 0.9): Object {
    return curves.springMotion(stiffness, damping);
  }

  /**
   * 获取默认弹性动画时长
   */
  static getDefaultDuration(): number {
    return 300;
  }

  /**
   * 获取快速动画时长
   */
  static getFastDuration(): number {
    return 200;
  }
}
