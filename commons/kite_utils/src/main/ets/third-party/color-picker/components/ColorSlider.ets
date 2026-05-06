/**
 * MIT License
 * 
 * Copyright (c) 2024-present KEKE UI
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software...
 */

export enum SlideDirection {
  Vertical,
  Horizontal,
  Both,
}

@ComponentV2
export struct ColorSlider {
  @Param x: number = 0
  @Param y: number = 0
  @Param slideDirection: SlideDirection = SlideDirection.Horizontal
  @Param radius: number = 0
  @Param trackLinearGradient: LinearGradient | null = null
  @Param trackBackgroundColor: ResourceColor | null = '#dcdae4'
  @Builder trackBuilder() {
    Row()
      .width('100%')
      .height('100%')
      .borderRadius(this.radius)
      .linearGradient(this.trackLinearGradient)
      .backgroundColor(this.trackBackgroundColor)
  }
  @BuilderParam track: () => void = this.trackBuilder
  @Param blockSize: number = 16
  @Param dragStart: (x: number, y: number) => void = (x: number, y: number) => {}
  @Param dragMove: (x: number, y: number) => void = (x: number, y: number) => {}
  @Param dragEnd: (x: number, y: number) => void = (x: number, y: number) => {}
  @Param onChange: (x: number, y: number) => void = (x: number, y: number) => {}

  @Local _width: number = 0
  @Local _height: number = 0
  @Local _dragX: number = 0
  @Local _dragY: number = 0
  @Local _isDown: boolean = false

  @Computed get realBlockSize() {
    return Math.min(this.blockSize, this._width)
  }

  @Computed get realX() {
    if (this.slideDirection === SlideDirection.Horizontal || this.slideDirection === SlideDirection.Both) {
      return Math.max(0, Math.min(this._dragX, this._width - this.realBlockSize))
    } else {
      return (this._width - this.realBlockSize) / 2
    }
  }

  @Computed get realY() {
    if (this.slideDirection === SlideDirection.Vertical || this.slideDirection === SlideDirection.Both) {
      return Math.max(0, Math.min(this._dragY, this._height - this.realBlockSize))
    } else {
      return (this._height - this.realBlockSize) / 2
    }
  }

  build() {
    Column() {
      this.track()

      Row()
        .width(this.realBlockSize)
        .height(this.realBlockSize)
        .border({ width: 4, radius: '50%', color: '#eeffffff' })
        .outline({ width: 2, radius: 100, color: '#11000000' })
        .opacity(this._isDown ? 1 : 0.5)
        .position({ x: this.realX, y: this.realY })
    }
    .monopolizeEvents(true)
    .onAreaChange((_, nv) => {
      this._width = nv.width as number
      this._height = nv.height as number
      this.updateXY()
    })
    .onTouch(e => this.handleTouch(e))
  }

  @Monitor('x', 'y')
  handleXY() {
    if (!this._isDown) {
      this.updateXY()
    }
  }

  private updateXY() {
    this._dragX = this.x * (this._width - this.realBlockSize)
    this._dragY = this.y * (this._height - this.realBlockSize)
  }

  private handleTouch(e: TouchEvent) {
    e.stopPropagation()

    try {
      this._dragX = e.touches[0].x - this.realBlockSize / 2
      this._dragY = e.touches[0].y - this.realBlockSize / 2
    } catch {
      console.warn('no touch point detected')
    }

    setTimeout(() => {
      const x = this.realX / (this._width - this.realBlockSize)
      const y = this.realY / (this._height - this.realBlockSize)
      this.onChange(x, y)

      if (e.type === TouchType.Down) {
        this._isDown = true
        this.dragStart(x, y)
      } else if (e.type === TouchType.Move) {
        this._isDown = true
        this.dragMove(x, y)
      } else {
        setTimeout(() => {
          this._isDown = false
          this.dragEnd(x, y)
        })
      }
    })
  }
}
