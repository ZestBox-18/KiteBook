/**
 * Copyright (C), 2026-07-09
 * @author ZestBox
 * @date 2026/07/09
 * @version 1.0
 * @description: 应用日志运行时，负责 Clog 初始化、日志开关和异常捕获生命周期
 */

import { common } from '@kit.AbilityKit';
import { SystemOptions } from 'base';
import { Clog } from 'kite_utils';

const TAG: string = '[AppLogRuntime]';

export class AppLogRuntime {
  /**
   * 初始化应用日志运行时。
   *
   * 该方法只依赖 AbilityContext，可在 Ability onCreate 阶段调用；内部只初始化 Clog 保存目录
   * 和全局异常捕获，不读取 PersistenceV2，避免应用设置在页面创建前被默认值覆盖。
   */
  public static init(context: common.UIAbilityContext): void {
    Clog.init(context);
    Clog.enableCrashCapture();
  }

  /**
   * 根据持久化设置应用本地日志落盘策略。
   *
   * 需要在页面 loadContent 完成并正确读取 SystemOptions 后调用。关闭详细日志时仍保留 error
   * 级别日志落盘，开启后记录 info、warn、error，便于用户主动提交排查信息。
   */
  public static applyOptions(options: SystemOptions): void {
    try {
      if (options.logRecording) {
        Clog.enableSave();
      } else {
        Clog.disableSave();
      }
    } catch (error) {
      Clog.disableSave();
      Clog.error(TAG, 'Failed to apply log recording option', error);
    }
  }

  /**
   * 释放日志运行时资源。
   *
   * 通常在 Ability onDestroy 阶段调用，用于注销全局异常捕获，并同步刷新缓冲区日志，
   * 降低退出时丢失最近日志的概率。
   */
  public static release(): void {
    Clog.disableCrashCapture();
    Clog.flush();
  }

  /**
   * 主动刷新日志缓冲区。
   *
   * 适合在应用进入后台、窗口销毁等生命周期节点调用，确保延迟写入的日志尽快落盘。
   */
  public static flush(): void {
    Clog.flush();
  }
}
