/**
 * Copyright (C), 2025-09-26
 * @author ZestBox
 * @date 2025/09/26 
 * @version 1.0
 * @description:
 */

import { DebounceManager } from '../utils/DebounceManager';
import { PersistenceV2 } from '@kit.ArkUI';

const TAG: string = '[SystemOptions]';


@ObservedV2
export class SystemOptions {
  // 首次运行
  @Trace firstStart: boolean = true

  /**
   * 从另一个 SystemOptions 对象更新当前实例的所有属性
   * 这种逐一赋值的方式确保触发 @Trace 装饰器的监听器，从而触发持久化存储
   * @param data 源 SystemOptions 对象
   */
  updateFromData(data: SystemOptions): void {
    // 基础设置
    this.firstStart = data.firstStart

  }

  @Monitor('firstStart')
  onDataChange(monitor: IMonitor) {
    DebounceManager.getInstance().execute('SystemOptions', () => {
      PersistenceV2.save('SystemOptions')
    }, 300)
  }
}