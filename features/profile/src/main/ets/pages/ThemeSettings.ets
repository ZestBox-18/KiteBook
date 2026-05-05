/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 主题设置页面
 */

import { SystemOptions, gAppThemes } from 'base';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';

@ComponentV2
export struct ThemeSettings {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!

  // 主题名称列表
  private themeNames: string[] = [
    '绿色', '红色', '蓝色', '紫色', '橙色', '中性灰',
    '黄色', '棕色', '暗色', '青色', '靛蓝',
    '青色', '粉色', '酸橙色', '深橙色', '琥珀色',
    '浅青色', '深靛蓝', '石板蓝', '珊瑚色', '翡翠绿'
  ]

  // 获取主题颜色
  private getThemeColor(index: number): ResourceColor {
    if (index >= 0 && index < gAppThemes.length) {
      const theme = gAppThemes[index]
      if (theme && theme.colors && theme.colors.brand) {
        return theme.colors.brand
      }
    }
    return '#2FB04A'
  }

  build() {
    NavDestination() {
      Column() {
        // 主题网格
        Grid() {
          ForEach(this.themeNames, (name: string, index: number) => {
            GridItem() {
              Column() {
                // 主题色块
                Column()
                  .width(48)
                  .height(48)
                  .borderRadius(24)
                  .backgroundColor(this.getThemeColor(index))

                // 主题名称
                Text(name)
                  .fontSize(12)
                  .fontColor($r('app.color.text_primary'))
                  .margin({ top: 8 })

                // 选中标记
                if (this.optionSystem.themeIndex === index) {
                  Text('✓')
                    .fontSize(14)
                    .fontColor($r('app.color.brand'))
                    .margin({ top: 4 })
                }
              }
              .width('100%')
              .padding(8)
              .onClick(() => {
                this.optionSystem.themeIndex = index
              })
            }
          }, (name: string) => name)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.title_bar_bg'))
    }
    .title('主题设置')
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}
