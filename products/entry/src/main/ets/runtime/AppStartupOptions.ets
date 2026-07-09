/**
 * Copyright (C), 2026-07-09
 * @author ZestBox
 * @date 2026/07/09
 * @version 1.0
 * @description: 应用启动设置应用器，负责页面加载后应用持久化配置
 */

import { common } from '@kit.AbilityKit';
import { SystemOptions } from 'base';
import { SystemColorModeUtil } from 'kite_utils';
import { AppLogRuntime } from './AppLogRuntime';

export class AppStartupOptions {
  /**
   * 应用启动后的持久化配置。
   *
   * 该方法应在主页面 loadContent 成功后调用，此时 PersistenceV2 已能读取真实设置值。
   * 目前统一应用日志落盘策略和系统颜色模式，后续启动级配置也应在这里收敛。
   */
  public static apply(context: common.UIAbilityContext, options: SystemOptions): void {
    AppLogRuntime.applyOptions(options);
    SystemColorModeUtil.applySystemColorMode(context, options.darkMode);
  }
}
