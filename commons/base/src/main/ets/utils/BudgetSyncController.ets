/**
 * Copyright (C), 2026-07-10
 * @author ZestBox
 * @date 2026/07/10
 * @version 1.0
 * @description: 预算变化通知控制器
 */

const INITIAL_LISTENER_ID: number = 1;

export class BudgetSyncController {
  private listenerId: number = INITIAL_LISTENER_ID;
  private listeners: Map<number, () => void> = new Map();

  register(listener: () => void): number {
    const currentId: number = this.listenerId;
    this.listenerId += 1;
    this.listeners.set(currentId, listener);
    return currentId;
  }

  unregister(listenerId: number): void {
    this.listeners.delete(listenerId);
  }

  notifyBudgetChanged(): void {
    this.listeners.forEach((listener: () => void) => {
      listener();
    });
  }
}

export const budgetSyncController: BudgetSyncController = new BudgetSyncController();
