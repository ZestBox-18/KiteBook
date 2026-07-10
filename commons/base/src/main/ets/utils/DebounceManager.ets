/**
 * Copyright (C), 2025-10-20
 * @author ZestBox
 * @date 2025-10-20 
 * @version 1.0
 * @description: 防抖管理器
 */

/**
 * 防抖管理器类型定义
 */
type DebounceCallback = () => void;

interface IDebounceTimer {
  timerId: number;
  callback: DebounceCallback;
}

/**
 * 防抖管理器
 * 提供两种防抖模式：
 * 1. 阻塞防抖：在指定时间内阻止重复执行
 * 2. 延迟防抖：在指定时间内只执行最后一次触发的操作
 */
export class DebounceManager {
  private static instance: DebounceManager;
  private static methodsMap: Map<string, number> = new Map();
  private static debounceTimers: Map<string, IDebounceTimer> = new Map();

  private constructor() {
  }

  /**
   * 获取防抖管理器单例实例
   * @returns DebounceManager实例
   */
  public static getInstance(): DebounceManager {
    if (!DebounceManager.instance) {
      DebounceManager.instance = new DebounceManager();
    }
    return DebounceManager.instance;
  }

  /**
   * 阻塞防抖：检查方法是否应该被阻止执行
   * @param methodName 方法名称
   * @param delayMs 防抖时间（毫秒）
   * @returns true表示应该被阻止，false表示可以执行
   */
  public shouldBlock(methodName: string, delayMs: number): boolean {
    const now = Date.now();
    const lastExecutionTime = DebounceManager.methodsMap.get(methodName);

    if (lastExecutionTime && (now - lastExecutionTime) < delayMs) {
      return true;
    } else {
      DebounceManager.methodsMap.set(methodName, now);
      return false;
    }
  }

  /**
   * 延迟防抖：在指定时间内只执行最后一次触发的操作
   * @param methodName 方法名称
   * @param callback 要执行的回调函数
   * @param delayMs 防抖时间（毫秒）
   */
  public execute(methodName: string, callback: DebounceCallback, delayMs: number): void {
    // 清除之前的定时器
    const existingTimer = DebounceManager.debounceTimers.get(methodName);
    if (existingTimer) {
      clearTimeout(existingTimer.timerId);
    }

    // 创建新的定时器
    const timerId = setTimeout(() => {
      try {
        callback();
      } finally {
        // 执行完成后清除定时器记录
        DebounceManager.debounceTimers.delete(methodName);
      }
    }, delayMs);

    // 保存新的定时器
    DebounceManager.debounceTimers.set(methodName, {
      timerId: timerId,
      callback: callback
    });
  }

  /**
   * 取消指定方法的防抖定时器
   * @param methodName 方法名称
   */
  public cancel(methodName: string): void {
    const existingTimer = DebounceManager.debounceTimers.get(methodName);
    if (existingTimer) {
      clearTimeout(existingTimer.timerId);
      DebounceManager.debounceTimers.delete(methodName);
    }
  }

  /**
   * 清除所有防抖定时器
   */
  public clearAll(): void {
    DebounceManager.debounceTimers.forEach((timer) => {
      clearTimeout(timer.timerId);
    });
    DebounceManager.debounceTimers.clear();
  }

  /**
   * 获取当前活跃的防抖定时器数量
   * @returns 活跃定时器数量
   */
  public getActiveCount(): number {
    return DebounceManager.debounceTimers.size;
  }

  /**
   * 重置防抖管理器状态（用于测试或特殊场景）
   */
  public reset(): void {
    this.clearAll();
    DebounceManager.methodsMap.clear();
  }
}

/**
 * 使用示例：
 *
 * 1. 阻塞防抖（检查是否应该被阻止）：
 * if (DebounceManager.getInstance().shouldBlock('quickListChange', 500)) {
 *   return; // 被阻止，不执行
 * }
 * // 继续执行业务逻辑
 *
 * 2. 延迟防抖（只执行最后一次触发）：
 * DebounceManager.getInstance().execute('quickListChange', () => {
 *   // 这里放置实际要执行的代码
 *   this.performQuickListChange();
 * }, 500);
 *
 * 3. 取消防抖：
 * DebounceManager.getInstance().cancel('quickListChange');
 *
 * 4. 清除所有防抖：
 * DebounceManager.getInstance().clearAll();
 */
