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

import { SlideDirection, ColorSlider } from './ColorSlider'
import { hex2hexa, hex2hsva, hsva2hex } from '../utils/color'

export enum HSBColorPickerLayout {
  DEFAULT,
  COLUMN,
}

@ComponentV2
export struct HSBColorPicker {
  @Param color: string | null = null
  @Param radius: number = 0
  @Param gutter: number = 8
  @Param showAlpha: boolean = false
  @Param layout: HSBColorPickerLayout = HSBColorPickerLayout.DEFAULT
  @Param predefine: string[] = []
  // @Param h: [number, number] = [0, 360]
  @Param s: [number, number] = [0, 100]
  @Param b: [number, number] = [0, 100]
  @Param onChange: (value: string) => void = (value: string) => {}

  @Local hueHex: string = '#ffffff'
  @Local hex: string = '#ffffff'
  @Local hue: number = 100
  @Local saturation: number = 100
  @Local bright: number = 100
  @Local alpha: number = 1
  @Local alphaBgList: number[] = []
  @Local predefineSelect: number = -1
  @Local isDragging: boolean = false

  aboutToAppear(): void {
    if (this.color) {
      this.initColor(this.color)
    }
  }

  @Monitor('color')
  handleColorUpdate() {
    if (!this.isDragging && this.color) {
      this.initColor(this.color)
    }
  }

  build() {
    Column() {
      Row() {
        ColorSlider({
          x: this.saturation / 100,
          y: (100 - this.bright) / 100,
          slideDirection: SlideDirection.Both,
          track: () => {
            this.trackBuilder()
          },
          dragStart: () => this.isDragging = true,
          dragEnd: () => this.isDragging = false,
          onChange: (x: number, y: number) => {
            this.saturation = Math.round(x * (this.s[1] - this.s[0])) + this.s[0]
            this.bright = Math.round((1 - y) * (this.b[1] - this.b[0])) + this.b[0]
            this.hex = hsva2hex(this.hue, this.saturation, this.bright)
            this.onChange(hex2hexa(this.hex, this.alpha))
            this.predefineSelect = -1
          }
        })
          .layoutWeight(1)

        if (this.layout === HSBColorPickerLayout.DEFAULT) {
          ColorSlider({
            y: this.hue / 360,
            slideDirection: SlideDirection.Vertical,
            radius: this.radius,
            trackLinearGradient: {
              direction: GradientDirection.Bottom,
              colors: [['red', 0], ['#ff0', .17], ['#0f0', .33], ['#0ff', .5], ['#00f', .67], ['#f0f', .83], ['red', 1]],
            },
            dragStart: () => this.isDragging = true,
            dragEnd: () => this.isDragging = false,
            onChange: (_: number, y: number) => {
              this.hue = Math.round(360 * y)
              this.hueHex = hsva2hex(this.hue, 100, 100)
              this.hex = hsva2hex(this.hue, this.saturation, this.bright)
              this.onChange(hex2hexa(this.hex, this.alpha))
              this.predefineSelect = -1
            }
          })
            .width(20)
            .height('100%')
            .margin({ left: this.gutter })
        }
      }
      .layoutWeight(1)

      if (this.layout === HSBColorPickerLayout.COLUMN) {
        ColorSlider({
          x: this.hue / 360,
          radius: this.radius,
          trackLinearGradient: {
            direction: GradientDirection.Right,
            colors: [['red', 0], ['#ff0', .17], ['#0f0', .33], ['#0ff', .5], ['#00f', .67], ['#f0f', .83], ['red', 1]],
          },
          dragStart: () => this.isDragging = true,
          dragEnd: () => this.isDragging = false,
          onChange: (x: number, _: number) => {
            this.hue = Math.round(360 * x)
            this.hueHex = hsva2hex(this.hue, 100, 100)
            this.hex = hsva2hex(this.hue, this.saturation, this.bright)
            this.onChange(hex2hexa(this.hex, this.alpha))
            this.predefineSelect = -1
          }
        })
          .height(20)
          .margin({ top: this.gutter })
      }

      if (this.showAlpha) {
        Row() {
          ColorSlider({
            x: this.alpha,
            radius: this.radius,
            track: () => {
              this.alphaTrackBuilder()
            },
            dragStart: () => this.isDragging = true,
            dragEnd: () => this.isDragging = false,
            onChange: (x: number, _: number) => {
              this.alpha = x
              this.onChange(hex2hexa(this.hex, this.alpha))
              this.predefineSelect = -1
            }
          })
            .width('100%')
            .height('100%')
        }
        .height(20)
        .margin({ top: this.gutter, right: this.layout === HSBColorPickerLayout.COLUMN ? 0 : (20 + this.gutter) })
        .onAreaChange((_, nv) => {
          let w = nv.width as number
          let arr: number[] = []
          for (let i = 0, n = Math.ceil(w / 10); i < n; i++) {
            arr.push(i % 2)
          }
          this.alphaBgList = arr
        })
      }

      if (this.predefine.length) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.predefine, (item: string, index: number) => {
            Stack() {
              Row() {
                Column() {
                  Rect()
                    .fill('#fff')
                    .width(10)
                    .height(10)
                  Rect()
                    .fill('#ccc')
                    .width(10)
                    .height(10)
                  Rect()
                    .fill('#fff')
                    .width(10)
                    .height(10)
                }
                Column() {
                  Rect()
                    .fill('#ccc')
                    .width(10)
                    .height(10)
                  Rect()
                    .fill('#fff')
                    .width(10)
                    .height(10)
                  Rect()
                    .fill('#ccc')
                    .width(10)
                    .height(10)
                }
                Column() {
                  Rect()
                    .fill('#fff')
                    .width(10)
                    .height(10)
                  Rect()
                    .fill('#ccc')
                    .width(10)
                    .height(10)
                  Rect()
                    .fill('#fff')
                    .width(10)
                    .height(10)
                }
              }
              .width('100%')
              .height('100%')
              Row()
                .width('100%')
                .height('100%')
                .backgroundColor(item)
            }
            .width(30)
            .height(30)
            .clip(true)
            .borderRadius(4)
            .margin({ top: 10, right: 10 })
            .shadow({ radius: this.predefineSelect === index ? 25 : 0, color: '#900f' })
            .onClick(() => {
              this.initColor(item)
              this.predefineSelect = index
              this.onChange(hex2hexa(this.hex, this.alpha))
            })
          })
        }
      }
    }
  }

  private initColor(color: string) {
    let hsv: [number, number, number, number] = hex2hsva(color)
    this.hue = hsv[0]
    this.saturation = hsv[1]
    this.bright = hsv[2]
    this.alpha = hsv[3]
    this.hueHex = hsva2hex(this.hue, 100, 100)
    this.hex = hsva2hex(this.hue, this.saturation, this.bright)
  }

  @Builder
  trackBuilder() {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .borderRadius(this.radius)
        .backgroundColor(this.hueHex)
      Row()
        .width('100%')
        .height('100%')
        .borderRadius(this.radius)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [[hex2hexa('#ffffff', (1 - this.s[0] / 100)), 0], [hex2hexa('#ffffff', (1 - this.s[1] / 100)), 1]]
        })
      Row()
        .width('100%')
        .height('100%')
        .borderRadius(this.radius)
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [[hex2hexa('#000000', (1 - this.b[0] / 100)), 0], [hex2hexa('#000000', (1 - this.b[1] / 100)), 1]]
        })
    }
  }

  @Builder
  alphaTrackBuilder() {
    Stack() {
      Row() {
        ForEach(this.alphaBgList, (item: number) => {
          Column() {
            if (item === 0) {
              Rect()
                .fill('#fff')
                .width(10)
                .height(10)
            }
            Rect()
              .fill('#ccc')
              .width(10)
              .height(10)
            if (item === 1) {
              Rect()
                .fill('#fff')
                .width(10)
                .height(10)
            }
          }
        })
      }
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [[hex2hexa(this.hex, 0), 0], [hex2hexa(this.hex, 1), 1]],
        })
    }
    .borderRadius(this.radius)
    .clip(true)
  }
}
