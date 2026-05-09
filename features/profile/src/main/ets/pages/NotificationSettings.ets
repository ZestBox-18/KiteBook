/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 通知设置页面
 */

import { SystemOptions, CommonConstants, mainTabController, AppThemeState } from 'base';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { WindowUtil } from 'kite_utils';
import { itemHead } from '../components/itemHead';

@ComponentV2
export struct NotificationSettings {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!
  // 主题颜色
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!

  @Local billReminder: boolean = true
  @Local budgetAlert: boolean = true
  @Local dailyReminder: boolean = false
  @Local weeklyReport: boolean = true
  @Local notifyListExpanded: boolean = false

  aboutToAppear(): void {
    this.notifyListExpanded = this.optionSystem.notificationEnabled
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          // 通知总开关
          ListItemGroup({
            header: itemHead('通知开关'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row() {
                SymbolGlyph($r('sys.symbol.bell_fill'))
                  .fontSize(20)
                  .fontColor([$r('app.color.text_primary')])
                  .margin({ right: 12 })

                Text('消息通知')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.optionSystem.notificationEnabled })
                  .selectedColor(this.themeState.brand)
                  .switchPointColor('#FFFFFF')
                  .onChange((isOn: boolean) => {
                    this.getUIContext().animateTo({ duration: 250, curve: Curve.EaseInOut }, () => {
                      this.notifyListExpanded = isOn
                    })
                    this.optionSystem.notificationEnabled = isOn
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }
          }

          // 通知类型
          ListItemGroup({
            header: itemHead('通知类型'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Column() {
                this.NotificationItem(
                  '账单提醒',
                  '账单到期、还款日提醒',
                  $r('sys.symbol.creditcard'),
                  this.billReminder,
                  (isOn: boolean) => {
                    this.billReminder = isOn
                  }
                )

                Divider()
                  .color($r('app.color.text_secondary'))
                  .strokeWidth(0.5)
                  .opacity(0.2)
                  .padding({ left: 48 })

                this.NotificationItem(
                  '预算预警',
                  '预算超支时发送提醒',
                  $r('sys.symbol.exclamationmark_triangle'),
                  this.budgetAlert,
                  (isOn: boolean) => {
                    this.budgetAlert = isOn
                  }
                )

                Divider()
                  .color($r('app.color.text_secondary'))
                  .strokeWidth(0.5)
                  .opacity(0.2)
                  .padding({ left: 48 })

                this.NotificationItem(
                  '每日记账',
                  '每天提醒记账',
                  $r('sys.symbol.calendar'),
                  this.dailyReminder,
                  (isOn: boolean) => {
                    this.dailyReminder = isOn
                  }
                )

                Divider()
                  .color($r('app.color.text_secondary'))
                  .strokeWidth(0.5)
                  .opacity(0.2)
                  .padding({ left: 48 })

                this.NotificationItem(
                  '周报月报',
                  '定期发送收支统计',
                  $r('sys.symbol.list_bullet'),
                  this.weeklyReport,
                  (isOn: boolean) => {
                    this.weeklyReport = isOn
                  }
                )
              }
              .width('100%')
            }
            .height(this.notifyListExpanded ? 256 : 0)
            .clip(true)
            .animation({ duration: 250, curve: Curve.EaseInOut })
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
      content: { title: { mainTitle: "通知设置" } },
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

  @Builder
  NotificationItem(
    title: string,
    subtitle: string,
    icon: Resource,
    isOn: boolean,
    onChange: (isOn: boolean) => void
  ) {
    ListItem() {
      Row() {
        SymbolGlyph(icon)
          .fontSize(20)
          .fontColor([$r('app.color.text_primary')])
          .margin({ right: 12 })

        Column() {
          Text(title)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))

          Text(subtitle)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Toggle({ type: ToggleType.Switch, isOn: isOn })
          .selectedColor(this.themeState.brand)
          .switchPointColor('#FFFFFF')
          .onChange((isOn: boolean) => {
            onChange(isOn)
          })
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })
    }
  }
}
