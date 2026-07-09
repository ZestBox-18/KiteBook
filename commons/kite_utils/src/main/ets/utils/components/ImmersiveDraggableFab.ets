/**
 * Copyright (C), 2026-06-17
 * @author ZestBox
 * @date 2026/06/17
 * @version 1.0
 * @description: 沉浸光感可拖拽悬浮按钮
 */

import { AppStorageV2, uiMaterial } from '@kit.ArkUI';
import { WindowUtil } from '../windowInfo/WindowUtil';

const FAB_SIZE: number = 58;
const FAB_EDGE_MARGIN: number = 18;
const FAB_DRAG_THRESHOLD: number = 6;

@ComponentV2
export struct ImmersiveDraggableFab {
  @Param icon: Resource = $r('sys.symbol.plus');
  @Param label: ResourceStr = '';
  @Param iconColor: ResourceColor = '#1677FF';
  @Param labelColor: ResourceColor = '#1677FF';
  @Param lightColor: ResourceColor = '#1677FF';
  @Param shadowColor: ResourceColor = '#22006CFF';
  @Param iconFontWeight: number = 500;
  @Param buttonSize: number = FAB_SIZE;
  @Param edgeMargin: number = FAB_EDGE_MARGIN;
  @Param bottomReserve: number = 0;
  @Event onFabClick: () => void = () => {
  };

  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local left: number = 0;
  @Local top: number = 0;
  @Local hasPosition: boolean = false;
  @Local isDragging: boolean = false;

  private startLeft: number = 0;
  private startTop: number = 0;
  private startX: number = 0;
  private startY: number = 0;

  aboutToAppear(): void {
    this.resetDefaultPosition();
  }

  private getWindowWidth(): number {
    const widthPx: number = this.winUtil.mainWindowInfo.windowSize.width;
    if (widthPx <= 0) {
      return 360;
    }
    return this.getUIContext().px2vp(widthPx);
  }

  private getWindowHeight(): number {
    const heightPx: number = this.winUtil.mainWindowInfo.windowSize.height;
    if (heightPx <= 0) {
      return 780;
    }
    return this.getUIContext().px2vp(heightPx);
  }

  private getMaxLeft(): number {
    return Math.max(this.edgeMargin, this.getWindowWidth() - this.buttonSize - this.edgeMargin);
  }

  private getMaxTop(): number {
    return Math.max(this.edgeMargin, this.getWindowHeight() - this.buttonSize - this.bottomReserve);
  }

  private resetDefaultPosition(): void {
    if (this.hasPosition) {
      this.clampCurrentPosition();
      return;
    }
    this.left = this.getMaxLeft();
    this.top = this.getMaxTop();
    this.hasPosition = true;
  }

  private clampCurrentPosition(): void {
    this.left = Math.min(Math.max(this.edgeMargin, this.left), this.getMaxLeft());
    this.top = Math.min(Math.max(this.winUtil.mainWindowInfo.safeAreaTop + this.edgeMargin, this.top), this.getMaxTop());
  }

  private handleTouch(event: TouchEvent): void {
    if (event.touches.length === 0) {
      return;
    }
    const touch: TouchObject = event.touches[0];
    if (event.type === TouchType.Down) {
      this.isDragging = false;
      this.startX = touch.windowX;
      this.startY = touch.windowY;
      this.startLeft = this.left;
      this.startTop = this.top;
      return;
    }
    if (event.type === TouchType.Move) {
      const offsetX: number = touch.windowX - this.startX;
      const offsetY: number = touch.windowY - this.startY;
      if (Math.abs(offsetX) > FAB_DRAG_THRESHOLD || Math.abs(offsetY) > FAB_DRAG_THRESHOLD) {
        this.isDragging = true;
      }
      this.left = this.startLeft + offsetX;
      this.top = this.startTop + offsetY;
      this.clampCurrentPosition();
      return;
    }
    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      this.clampCurrentPosition();
    }
  }

  build() {
    Button() {
      Column({ space: 1 }) {
        SymbolGlyph(this.icon)
          .fontSize(24)
          .fontWeight(this.iconFontWeight)
          .fontColor([this.iconColor])
          .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        if (this.label !== '') {
          Text(this.label)
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.labelColor)
        }
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width(this.buttonSize)
    .height(this.buttonSize)
    .padding(0)
    .borderRadius(this.buttonSize / 2)
    .backgroundColor('#00000000')
    .systemMaterial(new uiMaterial.ImmersiveMaterial({
      style: uiMaterial.ImmersiveStyle.ULTRA_THIN,
      interactive: true,
      lightEffect: {
        color: this.lightColor
      }
    }))
    .shadow({
      radius: 18,
      color: this.shadowColor,
      offsetY: 6
    })
    .position({ x: this.left, y: this.top })
    .zIndex(99)
    .onTouch((event: TouchEvent) => {
      this.handleTouch(event);
    })
    .onClick(() => {
      if (!this.isDragging) {
        this.onFabClick();
      }
      this.isDragging = false;
    })
  }
}
