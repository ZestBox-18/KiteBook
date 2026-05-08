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
import { ThemeColorItem } from '../components/ThemeColorItem';
import { itemHead } from '../components/itemHead';

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
  private darkModeOptions: string[] = ['auto', 'light', 'dark']
  private darkModeNames: string[] = ['跟随系统', '浅色模式', '深色模式']

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          // 主题选择分组
          ListItemGroup({
            header: itemHead('主题选择'),
            space: 5,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Grid() {
                ForEach(this.themeNames, (name: string, index: number) => {
                  GridItem() {
                    ThemeColorItem({
                      color: this.getThemeColor(index),
                      name: name,
                      isSelected: this.optionSystem.themeIndex === index,
                      onSelect: () => {
                        this.optionSystem.themeIndex = index
                      }
                    })
                  }
                }, (name: string) => name)
              }
              .columnsTemplate('1fr 1fr 1fr')
              .rowsGap(8)
              .columnsGap(8)
              .width('100%')
              .padding({ top: 8, bottom: 8 })
            }
          }

          // 字体粗细分组
          ListItemGroup({
            header: itemHead('字体粗细'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row({ space: 10 }) {
                Text('字体粗细')
                  .width(80)
                  .fontColor($r('app.color.text_primary'))
                  .fontWeight(this.optionSystem.fontThickness)

                Slider({
                  style: SliderStyle.InSet,
                  max: 900,
                  step: 400,
                  min: 100,
                  value: this.optionSystem.fontThickness
                })
                  .showTips(true,
                    this.optionSystem.fontThickness == 100 ? '较细' :
                      this.optionSystem.fontThickness < 900 ? '正常' : '较粗')
                  .layoutWeight(1)
                  .onChange((value: number) => {
                    this.optionSystem.fontThickness = value
                  })
              }
              .alignItems(VerticalAlign.Center)
              .width('100%')
              .padding(16)
            }
          }

          // 图标粗细分组
          ListItemGroup({
            header: itemHead('图标粗细'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row({ space: 10 }) {

                Row() {
                  SymbolGlyph($r('sys.symbol.paintpalette'))
                    .fontColor([$r('app.color.text_primary')])
                    .fontSize(28)
                    .fontWeight(this.optionSystem.iconThickness)
                }.width(80)
                .justifyContent(FlexAlign.Center)

                Slider({
                  style: SliderStyle.InSet,
                  max: 900,
                  step: 400,
                  min: 100,
                  value: this.optionSystem.iconThickness
                })
                  .showTips(true,
                    this.optionSystem.iconThickness == 100 ? '较细' :
                      this.optionSystem.iconThickness < 900 ? '正常' : '较粗')
                  .layoutWeight(1)
                  .onChange((value: number) => {
                    this.optionSystem.iconThickness = value
                  })
              }
              .alignItems(VerticalAlign.Center)
              .width('100%')
              .padding(16)
            }
          }

          // 深色模式分组
          ListItemGroup({
            header: itemHead('深色模式'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ForEach(this.darkModeOptions, (mode: string, index: number) => {
              ListItem() {
                this.OptionItem(this.darkModeNames[index], this.optionSystem.darkMode === mode, () => {
                  this.optionSystem.darkMode = mode
                })
              }
            }, (mode: string) => mode)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.title_bar_bg'))
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

  // 选项项
  @Builder
  OptionItem(label: string, isSelected: boolean, onSelect: () => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))

      Blank()

      if (isSelected) {
        Text('✓')
          .fontSize(16)
          .fontColor($r('app.color.brand'))
      }
    }
    .width('100%')
    .padding(16)
    .onClick(() => {
      onSelect()
    })
  }

  private getThemeColor(index: number): ResourceColor {
    if (index >= 0 && index < gAppThemes.length) {
      const theme = gAppThemes[index]
      if (theme && theme.colors && theme.colors.brand) {
        return theme.colors.brand
      }
    }
    return '#5A7A8A'
  }
}
