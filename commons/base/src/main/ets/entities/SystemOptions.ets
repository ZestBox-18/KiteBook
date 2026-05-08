/**
 * Copyright (C), 2025-09-26
 * @author ZestBox
 * @date 2025/09/26 
 * @version 1.0
 * @description: 系统设置项
 */

import { DebounceManager } from '../utils/DebounceManager';
import { PersistenceV2 } from '@kit.ArkUI';

const TAG: string = '[SystemOptions]';


@ObservedV2
export class SystemOptions {
  // 首次运行
  @Trace firstStart: boolean = true
  // 主题索引
  @Trace themeIndex: number = 0
  // 字体粗细值：100=较细, 400=正常, 900=较粗
  @Trace fontThickness: number = 400
  // 图标粗细值：100=较细, 400=正常, 900=较粗
  @Trace iconThickness: number = 400
  // 通知开关
  @Trace notificationEnabled: boolean = true
  // 深色模式：auto, light, dark
  @Trace darkMode: string = 'auto'

  /**
   * 从另一个 SystemOptions 对象更新当前实例的所有属性
   * 这种逐一赋值的方式确保触发 @Trace 装饰器的监听器，从而触发持久化存储
   * @param data 源 SystemOptions 对象
   */
  updateFromData(data: SystemOptions): void {
    this.firstStart = data.firstStart
    this.themeIndex = data.themeIndex
    this.fontThickness = data.fontThickness
    this.iconThickness = data.iconThickness
    this.notificationEnabled = data.notificationEnabled
    this.darkMode = data.darkMode
  }

  @Monitor('firstStart', 'themeIndex', 'fontThickness', 'iconThickness', 'notificationEnabled', 'darkMode')
  onDataChange(monitor: IMonitor) {
    DebounceManager.getInstance().execute('SystemOptions', () => {
      PersistenceV2.save('SystemOptions')
    }, 300)
  }
}
