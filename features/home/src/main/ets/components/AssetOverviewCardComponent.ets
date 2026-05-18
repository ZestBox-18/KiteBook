/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页资产概览卡片
 */

import { AppThemeState } from 'base';
import { HomeSwiperCardShellComponent } from './HomeSwiperCardShellComponent';
import { HomeVisibilityToggleComponent } from './HomeVisibilityToggleComponent';

@ComponentV2
export struct AssetOverviewCardComponent {
  @Param themeState: AppThemeState = new AppThemeState();
  @Param compactLayout: boolean = false;
  @Param hiddenAmount: boolean = false;
  @Param netAssetsText: string = '';
  @Param totalAssetsText: string = '';
  @Param totalLiabilitiesText: string = '';
  @Param opacityValue: number = 1;
  @Param scaleValue: number = 1;
  @Param rotateValue: number = 0;
  @Param zIndexValue: number = 0;
  @Event onToggleHidden: () => void = () => {
  };

  /**
   * 构建资产概览卡片外壳并注入具体内容。
   */
  build() {
    HomeSwiperCardShellComponent({
      themeState: this.themeState,
      compactLayout: this.compactLayout,
      opacityValue: this.opacityValue,
      scaleValue: this.scaleValue,
      rotateValue: this.rotateValue,
      zIndexValue: this.zIndexValue,
      heightValue: 236,
      leftPadding: this.compactLayout ? 14 : 20,
      rightPadding: this.compactLayout ? 14 : 18,
      topPadding: this.compactLayout ? 16 : 18,
      bottomPadding: this.compactLayout ? 16 : 18,
      content: () => {
        this.CardContent();
      }
    })
  }

  @Builder
  /**
   * 构建资产概览卡片主体内容。
   */
  private CardContent() {
    Column() {
      Row() {
        Row() {
          this.CardHeader($r('sys.symbol.list_bullet'), '资产概览')
        }
        .layoutWeight(1)
        HomeVisibilityToggleComponent({
          hidden: this.hiddenAmount,
          themeState: this.themeState,
          onToggle: () => {
            this.onToggleHidden();
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row({ space: this.compactLayout ? 8 : 14 }) {
        Column() {
          Column({ space: 10 }) {
            Text('净资产')
              .fontSize(this.compactLayout ? 12 : 13)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.brand)
            Text(this.netAssetsText)
              .fontSize(this.compactLayout ? 24 : 29)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontPrimary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column()
            .width('86%')
            .height(1)
            .backgroundColor('#E8DCCA')
            .margin({ top: 16, bottom: 14 })

          Row() {
            this.AssetStatMetric('总资产', this.totalAssetsText)
            this.VerticalDivider()
            this.AssetStatMetric('总负债', this.totalLiabilitiesText)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ top: this.compactLayout ? 14 : 18 })

        Image($r('app.media.Assets01'))
          .width(this.compactLayout ? 118 : 150)
          .height(this.compactLayout ? 118 : 150)
          .objectFit(ImageFit.Contain)
          .margin({ top: this.compactLayout ? 30 : 18 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
  }

  @Builder
  /**
   * 构建卡片顶部标题行。
   */
  private CardHeader(icon: Resource, title: string) {
    Row({ space: 10 }) {
      SymbolGlyph(icon)
        .fontSize(18)
        .fontColor([this.themeState.brand as ResourceColor])
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.fontPrimary)
    }
  }

  @Builder
  /**
   * 构建资产统计指标块。
   */
  private AssetStatMetric(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(this.compactLayout ? 12 : 13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontSecondary)
      Text(value)
        .fontSize(this.compactLayout ? 14 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.fontPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  /**
   * 构建资产统计区域中间的竖向分隔线。
   */
  private VerticalDivider() {
    Column()
      .width(1)
      .height(this.compactLayout ? 46 : 54)
      .backgroundColor('#ECE2D3')
      .margin({ left: 12, right: 12 })
  }
}
