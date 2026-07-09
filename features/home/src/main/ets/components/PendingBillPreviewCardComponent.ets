/**
 * Copyright (C), 2026-07-03
 * @author ZestBox
 * @date 2026/07/03
 * @version 1.0
 * @description: 首页待确认账单预览卡片
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { AppThemeState } from 'base';

const HOME_INCOME_COLOR: string = '#16A34A';
const HOME_WARNING_COLOR: string = '#F97316';

@ComponentV2
export struct PendingBillPreviewCardComponent {
  @Param pendingCountText: string = '1';
  @Event onViewAll: () => void = () => {
  };
  @Event onConfirm: () => void = () => {
  };
  @Event onEdit: () => void = () => {
  };

  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;

  build() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 8 }) {
          Text('待确认账单')
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)
          Text(this.pendingCountText)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontOnPrimary)
            .width(24)
            .height(24)
            .textAlign(TextAlign.Center)
            .borderRadius(12)
            .backgroundColor(HOME_WARNING_COLOR)
        }
        .layoutWeight(1)

        Row({ space: 4 }) {
          Text('全部待确认')
            .fontSize(14)
            .fontColor(this.themeState.fontSecondary)
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(13)
            .fontColor([this.themeState.fontSecondary as ResourceColor])
        }
        .onClick(() => {
          this.onViewAll();
        })
      }
      .width('100%')

      Column({ space: 12 }) {
        Row({ space: 12 }) {
          Text('支')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontOnPrimary)
            .textAlign(TextAlign.Center)
            .width(50)
            .height(50)
            .borderRadius(14)
            .backgroundColor(this.themeState.brand)

          Column() {
            Text('支付宝付款')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontPrimary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text('今天 11:29')
              .fontSize(13)
              .fontColor(this.themeState.fontSecondary)
              .margin({ top: 3 })
            Text('来源  屏幕识别')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.brand)
              .padding({ left: 10, right: 10, top: 3, bottom: 3 })
              .borderRadius(10)
              .backgroundColor(this.themeState.compBackgroundNeutral)
              .margin({ top: 6 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column({ space: 6 }) {
            Text('¥12.00')
              .fontSize(19)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontPrimary)
            Text('餐饮')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.brand)
            Text('高')
              .fontSize(12)
              .fontColor(HOME_INCOME_COLOR)
              .padding({ left: 10, right: 10, top: 3, bottom: 3 })
              .borderRadius(10)
              .backgroundColor(this.themeState.compBackgroundNeutral)
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row({ space: 10 }) {
          Button('确认入账')
            .layoutWeight(1)
            .height(38)
            .fontSize(14)
            .fontColor(this.themeState.fontOnPrimary)
            .fontWeight(FontWeight.Bold)
            .backgroundColor(this.themeState.brand)
            .borderRadius(10)
            .onClick(() => {
              this.onConfirm();
            })
          Button('修改')
            .layoutWeight(1)
            .height(38)
            .fontSize(14)
            .fontColor(this.themeState.fontSecondary)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.themeState.compBackgroundNeutral)
            .border({ width: 1, color: this.themeState.compDivider })
            .borderRadius(10)
            .onClick(() => {
              this.onEdit();
            })
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .borderRadius(22)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }
}
