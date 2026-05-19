/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 账单同步控制器
 */

const INITIAL_LISTENER_ID: number = 1

export class BillSyncController {
  private listenerId: number = INITIAL_LISTENER_ID
  private listeners: Map<number, () => void> = new Map()

  /**
   * 注册账单变化监听器，并返回监听器编号。
   */
  register(listener: () => void): number {
    const currentId: number = this.listenerId
    this.listenerId = this.listenerId + 1
    this.listeners.set(currentId, listener)
    return currentId
  }

  /**
   * 注销已注册的账单变化监听器。
   */
  unregister(listenerId: number): void {
    this.listeners.delete(listenerId)
  }

  /**
   * 通知所有监听方账单已发生变化。
   */
  notifyBillChanged(): void {
    this.listeners.forEach((listener: () => void) => {
      listener()
    })
  }
}

export const billSyncController: BillSyncController = new BillSyncController()
