/**
 * Copyright (C), 2026-06-16
 * @author ZestBox
 * @date 2026/06/16
 * @version 1.0
 * @description: 应用入口 Ability，负责数据库、窗口和系统颜色模式初始化
 */

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, PersistenceV2, window } from '@kit.ArkUI';
import { GlobalContext, ImmersiveType, SystemColorModeUtil, WindowUtil } from 'kite_utils';
import { SystemOptions } from 'base';
import { dbManagerInit } from 'data_core';


const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  windowUtil?: WindowUtil;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化数据库
    dbManagerInit(this.context);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    try {
      this.windowUtil = new WindowUtil(windowStage.getMainWindowSync());
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to get main window. Code: ${err.code}, message: ${err.message}`);
    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      try {
        GlobalContext.initContext(windowStage.getMainWindowSync().getUIContext());
      } catch (error) {
        hilog.error(DOMAIN, 'testTag', 'Failed to init global UI context. Cause: %{public}s', JSON.stringify(error));
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

      const winUtil = this.windowUtil;
      if (!winUtil) {
        hilog.error(DOMAIN, 'testTag', 'Skip window setup because windowUtil is not initialized.');
      } else {
        // 初始化沉浸式窗口信息，并把同一个 WindowUtil 实例挂到全局状态。
        winUtil.setUIContext();
        winUtil.setImmersiveType(ImmersiveType.IMMERSIVE);
        winUtil.updateWindowInfo();
        AppStorageV2.connect(WindowUtil, 'winUtil', () => winUtil);
      }

      // loadContent 完成后应用持久化系统颜色模式，此时 PersistenceV2 已可正常读取。
      try {
        const options: SystemOptions =
          PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;
        SystemColorModeUtil.applySystemColorMode(this.context, options.darkMode);
      } catch (err) {
        hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
