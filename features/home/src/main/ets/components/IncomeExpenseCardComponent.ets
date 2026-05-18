/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页收支概览卡片
 */

import { AppThemeState } from 'base';
import { HomeSwiperCardShellComponent } from './HomeSwiperCardShellComponent';
import { HomeVisibilityToggleComponent } from './HomeVisibilityToggleComponent';

@ComponentV2
export struct IncomeExpenseCardComponent {
  @Param themeState: AppThemeState = new AppThemeState();
  @Param compactLayout: boolean = false;
  @Param hiddenAmount: boolean = false;
  @Param expenseText: string = '';
  @Param incomeText: string = '';
  @Param balanceText: string = '';
  @Param opacityValue: number = 1;
  @Param scaleValue: number = 1;
  @Param rotateValue: number = 0;
  @Param zIndexValue: number = 0;
  @Event onToggleHidden: () => void = () => {
  };

  /**
   * 构建收支概览卡片外壳并注入具体内容。
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
      rightPadding: this.compactLayout ? 14 : 20,
      topPadding: this.compactLayout ? 16 : 18,
      bottomPadding: this.compactLayout ? 14 : 18,
      content: () => {
        this.CardContent();
      }
    })
  }

  @Builder
  /**
   * 构建收支概览卡片主体内容。
   */
  private CardContent() {
    Column() {
      Row() {
        Row() {
          this.CardHeader($r('sys.symbol.arrow_left_arrow_right'), '本月收支')
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

      Row() {
        this.IncomeExpenseBlock($r('sys.symbol.arrow_down'), '#F15B4E', '本月支出', this.expenseText, false)
        this.VerticalDivider()
        this.IncomeExpenseBlock($r('sys.symbol.arrow_up'), '#45B36B', '本月收入', this.incomeText, false)
        this.VerticalDivider()
        this.IncomeExpenseBlock($r('sys.symbol.clock'), this.themeState.brand as string, '月结余', this.balanceText, true)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.compactLayout ? 14 : 18, bottom: this.compactLayout ? 2 : 6 })
    }
  }

  @Builder
  /**
   * 构建收支卡片顶部标题行。
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
   * 构建单个收支指标块。
   */
  private IncomeExpenseBlock(icon: Resource, tone: string, label: string, value: string, accent: boolean) {
    Column({ space: 10 }) {
      Row() {
        SymbolGlyph(icon)
          .fontSize(this.compactLayout ? 20 : 22)
          .fontColor([tone])
      }
      .width(this.compactLayout ? 40 : 44)
      .height(this.compactLayout ? 40 : 44)
      .justifyContent(FlexAlign.Center)
      .borderRadius(this.compactLayout ? 20 : 22)
      .border({ width: 1.8, color: tone })

      Text(label)
        .fontSize(this.compactLayout ? 12 : 13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontSecondary)
      Text(value)
        .fontSize(this.compactLayout ? (accent ? 16 : 15) : (accent ? 19 : 18))
        .fontWeight(FontWeight.Bold)
        .fontColor(accent ? this.themeState.brand : this.themeState.fontPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  /**
   * 构建收支指标之间的竖向分隔线。
   */
  private VerticalDivider() {
    Column()
      .width(1)
      .height(this.compactLayout ? 72 : 84)
      .backgroundColor('#ECE2D3')
  }
}
