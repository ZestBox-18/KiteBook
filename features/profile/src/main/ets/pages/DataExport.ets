/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 数据导出页面
 */

import { CommonConstants, mainTabController, AppThemeState, SystemOptions } from 'base';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { WindowUtil } from 'kite_utils';
import { itemHead } from '../components/itemHead';

@ComponentV2
export struct DataExport {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  @Local exporting: boolean = false
  @Local exportFormat: string = 'csv'
  @Local exportRange: string = 'all'
  // 主题颜色
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          // 导出说明
          ListItemGroup({
            header: itemHead('导出说明'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Column() {
                Row() {
                  SymbolGlyph($r('sys.symbol.doc_text'))
                    .fontSize(20)
                    .fontWeight(this.optionSystem.iconThickness)
                    .fontColor([this.themeState.brand])
                    .margin({ right: 12 })

                  Text('数据导出')
                    .fontSize(16)
                    .fontWeight(this.optionSystem.fontThickness)
                    .fontColor($r('app.color.text_primary'))
                }
                .width('100%')

                Text('将您的记账数据导出为文件，可用于备份或导入其他设备。导出的数据包含账单记录、分类信息等。')
                  .fontSize(14)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 8 })
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .alignItems(HorizontalAlign.Start)
            }
          }

          // 导出格式
          ListItemGroup({
            header: itemHead('导出格式'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row() {
                Text('CSV 表格')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('app.color.text_primary'))

                Blank()

                Radio({ value: 'csv', group: 'formatGroup' })
                  .checked(this.exportFormat === 'csv')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportFormat = 'csv'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }

            ListItem() {
              Row() {
                Text('JSON 数据')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('app.color.text_primary'))

                Blank()

                Radio({ value: 'json', group: 'formatGroup' })
                  .checked(this.exportFormat === 'json')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportFormat = 'json'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }
          }

          // 导出范围
          ListItemGroup({
            header: itemHead('导出范围'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row() {
                Text('全部数据')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('app.color.text_primary'))

                Blank()

                Radio({ value: 'all', group: 'rangeGroup' })
                  .checked(this.exportRange === 'all')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportRange = 'all'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }

            ListItem() {
              Row() {
                Text('今年数据')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('app.color.text_primary'))

                Blank()

                Radio({ value: 'year', group: 'rangeGroup' })
                  .checked(this.exportRange === 'year')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportRange = 'year'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }

            ListItem() {
              Row() {
                Text('本月数据')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('app.color.text_primary'))

                Blank()

                Radio({ value: 'month', group: 'rangeGroup' })
                  .checked(this.exportRange === 'month')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportRange = 'month'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }
          }

          // 导出按钮
          ListItem() {
            Button(this.exporting ? '导出中...' : '导出数据')
              .width('100%')
              .height(48)
              .backgroundColor(this.themeState.brand)
              .fontWeight(this.optionSystem.fontThickness)
              .fontColor(Color.White)
              .borderRadius(12)
              .enabled(!this.exporting)
              .onClick(() => {
                this.exporting = true
                // TODO: 实现导出逻辑
                setTimeout(() => {
                  this.exporting = false
                }, 2000)
              })
          }
          .padding({ left: 16, right: 16, top: 8 })
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
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        }
      },
      content: { title: { mainTitle: "数据导出" } },
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
