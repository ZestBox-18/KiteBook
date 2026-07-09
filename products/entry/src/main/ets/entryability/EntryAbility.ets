/**
 * Copyright (C), 2026-06-16
 * @author ZestBox
 * @date 2026/06/16
 * @version 1.0
 * @description: 应用入口 Ability，负责数据库、窗口和系统颜色模式初始化
 */

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, PersistenceV2, window } from '@kit.ArkUI';
import { Clog, GlobalContext, ImmersiveType, WindowUtil } from 'kite_utils';
import { SystemOptions } from 'base';
import { dbManagerInit } from 'data_core';
import { AppLogRuntime } from '../runtime/AppLogRuntime';
import { AppStartupOptions } from '../runtime/AppStartupOptions';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  windowUtil?: WindowUtil;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppLogRuntime.init(this.context);
    // 初始化数据库
    dbManagerInit(this.context);
    Clog.info(TAG, 'Ability onCreate');
  }

  onDestroy(): void {
    Clog.info(TAG, 'Ability onDestroy');
    AppLogRuntime.release();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Clog.info(TAG, 'Ability onWindowStageCreate');
    try {
      this.windowUtil = new WindowUtil(windowStage.getMainWindowSync());
    } catch (error) {
      const err = error as BusinessError;
      Clog.error(TAG, `Failed to get main window. Code: ${err.code}, message: ${err.message}`);
    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Clog.error(TAG, 'Failed to load the content', err);
        return;
      }
      try {
        GlobalContext.initContext(windowStage.getMainWindowSync().getUIContext());
      } catch (error) {
        Clog.error(TAG, 'Failed to init global UI context', error);
      }
      Clog.info(TAG, 'Succeeded in loading the content.');

      const winUtil = this.windowUtil;
      if (!winUtil) {
        Clog.error(TAG, 'Skip window setup because windowUtil is not initialized.');
      } else {
        // 初始化沉浸式窗口信息，并把同一个 WindowUtil 实例挂到全局状态。
        winUtil.setUIContext();
        winUtil.setImmersiveType(ImmersiveType.IMMERSIVE);
        winUtil.updateWindowInfo();
        AppStorageV2.connect(WindowUtil, 'winUtil', () => winUtil);
      }

      // loadContent 完成后再读取持久化设置，避免 Ability 创建阶段默认值覆盖已保存配置。
      try {
        const options: SystemOptions =
          PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;
        AppStartupOptions.apply(this.context, options);
      } catch (err) {
        Clog.error(TAG, 'Failed to set colorMode', err);
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Clog.info(TAG, 'Ability onWindowStageDestroy');
    AppLogRuntime.flush();
  }

  onForeground(): void {
    // Ability has brought to foreground
    Clog.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Clog.info(TAG, 'Ability onBackground');
    AppLogRuntime.flush();
  }
}
