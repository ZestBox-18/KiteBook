/**
 * Copyright (C), 2026-05-08
 * @author ZestBox
 * @date 2026/05/08
 * @version 1.0
 * @description: 外观设置页面
 */

import { SystemOptions, gAppThemes, CommonConstants, mainTabController } from 'base';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { WindowUtil } from 'kite_utils';

@ComponentV2
export struct AppearanceSettings {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!

  private themeNames: string[] = [
    '松墨', '深海', '玄青', '砂金', '赤陶',
    '云雾灰', '月白', '岩石', '暮紫'
  ]

  private fontWeightOptions: string[] = ['细体', '常规', '中等', '粗体']
  private iconWeightOptions: string[] = ['细线', '常规', '粗线']
  private darkModeOptions: string[] = ['auto', 'light', 'dark']
  private darkModeNames: string[] = ['跟随系统', '浅色模式', '深色模式']

  private getThemeColor(index: number): ResourceColor {
    if (index >= 0 && index < gAppThemes.length) {
      const theme = gAppThemes[index]
      if (theme && theme.colors && theme.colors.brand) {
        return theme.colors.brand
      }
    }
    return '#5A7A8A'
  }

  build() {
    HdsNavDestination() {
      Column() {
        Column() {
          Text('主题选择')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 12 })

          Grid() {
            ForEach(this.themeNames, (name: string, index: number) => {
              GridItem() {
                Column() {
                  Column()
                    .width(48)
                    .height(48)
                    .borderRadius(24)
                    .backgroundColor(this.getThemeColor(index))

                  Text(name)
                    .fontSize(12)
                    .fontColor($r('app.color.text_primary'))
                    .margin({ top: 8 })

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
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        Column() {
          Text('字体粗细')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 12 })

          ForEach(this.fontWeightOptions, (option: string, index: number) => {
            Row() {
              Text(option)
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))

              Blank()

              if (this.optionSystem.fontWeight === index) {
                Text('✓')
                  .fontSize(16)
                  .fontColor($r('app.color.brand'))
              }
            }
            .width('100%')
            .padding(12)
            .backgroundColor($r('app.color.title_bar_bg'))
            .borderRadius(8)
            .margin({ top: index === 0 ? 0 : 8 })
            .onClick(() => {
              this.optionSystem.fontWeight = index
            })
          }, (option: string) => option)
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        Column() {
          Text('图标粗细')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 12 })

          ForEach(this.iconWeightOptions, (option: string, index: number) => {
            Row() {
              Text(option)
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))

              Blank()

              if (this.optionSystem.iconWeight === index) {
                Text('✓')
                  .fontSize(16)
                  .fontColor($r('app.color.brand'))
              }
            }
            .width('100%')
            .padding(12)
            .backgroundColor($r('app.color.title_bar_bg'))
            .borderRadius(8)
            .margin({ top: index === 0 ? 0 : 8 })
            .onClick(() => {
              this.optionSystem.iconWeight = index
            })
          }, (option: string) => option)
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        Column() {
          Text('深色模式')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 12 })

          ForEach(this.darkModeOptions, (mode: string, index: number) => {
            Row() {
              Text(this.darkModeNames[index])
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))

              Blank()

              if (this.optionSystem.darkMode === mode) {
                Text('✓')
                  .fontSize(16)
                  .fontColor($r('app.color.brand'))
              }
            }
            .width('100%')
            .padding(12)
            .backgroundColor($r('app.color.title_bar_bg'))
            .borderRadius(8)
            .margin({ top: index === 0 ? 0 : 8 })
            .onClick(() => {
              this.optionSystem.darkMode = mode
            })
          }, (mode: string) => mode)
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.title_bar_bg'))
      .padding({ top: this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI })
    }
    .titleBar({
      padding: {
        start: LengthMetrics.vp(20),
        end: LengthMetrics.vp(2)
      },
      style: {
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR,
          blurEffectiveStartOffset: LengthMetrics.vp(0),
          blurEffectiveEndOffset: LengthMetrics.vp(20)
        },
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        },
        originalStyle: {
          backgroundStyle: { backgroundColor: $r('app.color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            },
            menuStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: { backgroundColor: $r('app.color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            },
            menuStyle: {
              backgroundColor: $r('app.color.action_bg'),
              textColor: $r('app.color.text_secondary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        }
      },
      content: { title: { mainTitle: "外观设置" } },
      avoidLayoutSafeArea: true
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .onBackPressed(() => {
      mainTabController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
      return false;
    })
  }
}
