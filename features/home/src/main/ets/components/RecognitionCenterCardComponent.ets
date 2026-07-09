/**
 * Copyright (C), 2026-07-03
 * @author ZestBox
 * @date 2026/07/03
 * @version 1.0
 * @description: 首页智能识别中心卡片
 */

import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { AppThemeState, SystemOptions } from 'base';

const HOME_INCOME_COLOR: string = '#16A34A';
const HOME_WARNING_COLOR: string = '#F97316';

@ComponentV2
export struct RecognitionCenterCardComponent {
  @Param todayCountText: string = '3';
  @Param pendingCountText: string = '1';
  @Param successRateText: string = '92';
  @Event onScreenshotRecognize: () => void = () => {
  };
  @Event onToggleFloatingRecognize: () => void = () => {
  };
  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;

  build() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.circle_viewfinder'))
          .fontSize(26)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.brand as ResourceColor])
          .width(30)
          .height(44)
          .borderRadius(12)
          .backgroundColor(this.themeState.compBackgroundNeutral)

        Column() {
          Text('智能识别中心')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)
          Row({ space: 6 }) {
            Circle()
              .width(8)
              .height(8)
              .fill(HOME_INCOME_COLOR)
            Text('屏幕识别已开启')
              .fontSize(14)
              .fontWeight(this.optionSystem.fontThickness)
              .fontColor(this.themeState.fontSecondary)
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(12)
              .fontColor([this.themeState.fontSecondary as ResourceColor])
          }
          .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Row() {
        this.RecognitionMetric('今日识别', this.todayCountText, '笔')
        Divider().vertical(true).height(46).color(this.themeState.compDivider)
        this.RecognitionMetric('待确认', this.pendingCountText, '笔')
        Divider().vertical(true).height(46).color(this.themeState.compDivider)
        this.RecognitionMetric('识别成功率', this.successRateText, '%')
      }
      .width('100%')
      .height(68)
      .padding({ left: 8, right: 8 })
      .borderRadius(18)
      .backgroundColor(this.themeState.compBackgroundNeutral)

      Row({ space: 12 }) {
        Button() {
          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.circle_viewfinder'))
              .fontSize(22)
              .fontWeight(this.optionSystem.iconThickness)
              .fontColor([this.themeState.fontOnPrimary as ResourceColor])
            Text('截图识别')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontOnPrimary)
          }
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .height(44)
        .borderRadius(14)
        .backgroundColor(this.themeState.brand)
        .onClick(() => {
          this.onScreenshotRecognize();
        })

        Button() {
          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.circle_viewfinder'))
              .fontSize(22)
              .fontWeight(this.optionSystem.iconThickness)
              .fontColor([this.themeState.brand as ResourceColor])
            Text('开启悬浮识别')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.brand)
          }
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .height(44)
        .borderRadius(14)
        .backgroundColor(this.themeState.compBackgroundNeutral)
        .border({ width: 1.5, color: this.themeState.brand })
        .onClick(() => {
          this.onToggleFloatingRecognize();
        })
      }
      .width('100%')
    }
    .width('100%')
    .height(204)
    .padding(14)
    .borderRadius(22)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .border({ width: 1, color: this.themeState.compDivider })
  }

  @Builder
  private RecognitionMetric(label: string, value: string, unit: string) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Row({ space: 4 }) {
        Text(value)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getRecognitionMetricColor(label))
        Text(unit)
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 8 })
      }
      .margin({ top: 4 })
      .alignItems(VerticalAlign.Bottom)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  private getRecognitionMetricColor(label: string): ResourceColor {
    if (label === '待确认') {
      return HOME_WARNING_COLOR;
    }
    return this.themeState.brand as ResourceColor;
  }
}
