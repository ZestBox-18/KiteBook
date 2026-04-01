/**
 * Copyright (C), 2026-03-06
 * @author ZestBox
 * @date 2026-03-06 
 * @version 1.0
 * @description: 适配状态管理 V2 的断点系统
 *               特性：
 *               1. 使用 @ObservedV2 深度监听
 *               2. 使用 @Trace 标记被追踪的属性
 *               3. 单例模式，全应用共享
 */

import { mediaquery } from '@kit.ArkUI';


// 定义常量（保持不变）
export class BreakpointConstants {
  static readonly BREAKPOINT_SM: string = 'sm';
  static readonly BREAKPOINT_MD: string = 'md';
  static readonly BREAKPOINT_LG: string = 'lg';
  static readonly CURRENT_BREAKPOINT: string = 'currentBreakpoint';
  static readonly RANGE_SM: string = '(320vp<=width<600vp)';
  static readonly RANGE_MD: string = '(600vp<=width<840vp)';
  static readonly RANGE_LG: string = '(840vp<=width)';
}

@ObservedV2
export class BreakpointSystem {
  // 2. 被追踪的属性：只要它变了，绑定它的 UI 就会自动刷新
  @Trace public currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  private smListener: mediaquery.MediaQueryListener | undefined = undefined;
  private mdListener: mediaquery.MediaQueryListener | undefined = undefined;
  private lgListener: mediaquery.MediaQueryListener | undefined = undefined;

  private updateCurrentBreakpoint(breakpoint: string): void {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      console.info(`[BreakpointSystem] Switched to: ${breakpoint}`);
    }
  }

  private isBreakpointSM = (mediaQueryResult: mediaquery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(BreakpointConstants.BREAKPOINT_SM);
    }
  };
  private isBreakpointMD = (mediaQueryResult: mediaquery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(BreakpointConstants.BREAKPOINT_MD);
    }
  };
  private isBreakpointLG = (mediaQueryResult: mediaquery.MediaQueryResult): void => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(BreakpointConstants.BREAKPOINT_LG);
    }
  };

  public register(): void {
    // 防止重复注册
    if (this.smListener) {
      return;
    }

    this.smListener = mediaquery.matchMediaSync(BreakpointConstants.RANGE_SM);
    this.smListener.on('change', this.isBreakpointSM);

    this.mdListener = mediaquery.matchMediaSync(BreakpointConstants.RANGE_MD);
    this.mdListener.on('change', this.isBreakpointMD);

    this.lgListener = mediaquery.matchMediaSync(BreakpointConstants.RANGE_LG);
    this.lgListener.on('change', this.isBreakpointLG);
  }

  public unregister(): void {
    this.smListener?.off('change', this.isBreakpointSM);
    this.mdListener?.off('change', this.isBreakpointMD);
    this.lgListener?.off('change', this.isBreakpointLG);

    this.smListener = undefined;
    this.mdListener = undefined;
    this.lgListener = undefined;
  }
}
