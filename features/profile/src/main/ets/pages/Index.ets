/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 个人中心主页面
 */

import { hdsMaterial, HdsNavigation, ScrollEffectType } from '@kit.UIDesignKit';
import { CommonConstants, RouterUrlConstants, SystemOptions } from 'base';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { WindowUtil } from 'kite_utils';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { UserProfile } from '../entities/UserProfile';
import { UserEditSheet } from '../components/UserEditSheet';
import { ThemeSettings } from './ThemeSettings';
import { FontSettings } from './FontSettings';
import { NotificationSettings } from './NotificationSettings';
import { DarkModeSettings } from './DarkModeSettings';
import { DataExport } from './DataExport';
import { About } from './About';
import { itemHead } from '../components/itemHead';
import { UserCard } from '../components/UserCard';
import { SettingItem } from '../components/SettingItem';

const TAG: string = '[Profile]';

@Entry
@ComponentV2
export struct Index {
  // 页面路由栈
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  // 用户设置项
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  // 用户信息
  @Local userProfile: UserProfile =
    PersistenceV2.connect(UserProfile, 'UserProfile', () => new UserProfile())!
  // 编辑弹窗控制
  @Local showEditSheet: boolean = false
  // 动画触发器
  @Local loginAnimationTrigger: number = 0
  @Local logoutAnimationTrigger: number = 0

  /**
   * 页面路由表
   */
  @Builder
  PagesMap(name: string, param?: object) {
    if (name === RouterUrlConstants.THEME_SETTINGS) {
      ThemeSettings()
    } else if (name === RouterUrlConstants.FONT_SETTINGS) {
      FontSettings()
    } else if (name === RouterUrlConstants.NOTIFICATION_SETTINGS) {
      NotificationSettings()
    } else if (name === RouterUrlConstants.DARK_MODE_SETTINGS) {
      DarkModeSettings()
    } else if (name === RouterUrlConstants.DATA_EXPORT) {
      DataExport()
    } else if (name === RouterUrlConstants.ABOUT) {
      About()
    }
  }

  /**
   * 用户编辑弹窗
   */
  @Builder
  EditSheetBuilder() {
    UserEditSheet({
      profile: this.userProfile,
      context: this.getUIContext(),
      onClose: () => {
        this.showEditSheet = false
      },
      onLoginSuccess: () => {
        this.loginAnimationTrigger++
      },
      onLogout: () => {
        this.logoutAnimationTrigger++
      }
    })
  }

  build() {
    HdsNavigation(this.pageInfos) {
      Column() {
        List({ space: 10 }) {
          // 用户信息卡片
          ListItemGroup({
            space: 5,
            style: ListItemGroupStyle.CARD
          }) {
            UserCard({
              profile: this.userProfile,
              onEdit: () => {
                this.showEditSheet = true
              },
              loginAnimationTrigger: this.loginAnimationTrigger,
              logoutAnimationTrigger: this.logoutAnimationTrigger
            })
          }

          // 应用设置分组
          ListItemGroup({
            header: itemHead('应用设置'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.paintpalette'),
                title: '主题设置',
                onItemClick: () => {
                  this.pageInfos.pushPath({ name: RouterUrlConstants.THEME_SETTINGS })
                }
              })
            }

            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.textformat'),
                title: '字体大小',
                onItemClick: () => {
                  this.pageInfos.pushPath({ name: RouterUrlConstants.FONT_SETTINGS })
                }
              })
            }

            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.bell'),
                title: '通知设置',
                onItemClick: () => {
                  this.pageInfos.pushPath({ name: RouterUrlConstants.NOTIFICATION_SETTINGS })
                }
              })
            }

            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.moon'),
                title: '深色模式',
                onItemClick: () => {
                  this.pageInfos.pushPath({ name: RouterUrlConstants.DARK_MODE_SETTINGS })
                }
              })
            }
          }

          // 其他分组
          ListItemGroup({
            header: itemHead('其他'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.arrow_up_circle'),
                title: '数据导出',
                onItemClick: () => {
                  this.pageInfos.pushPath({ name: RouterUrlConstants.DATA_EXPORT })
                }
              })
            }

            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.info_circle'),
                title: '关于',
                onItemClick: () => {
                  this.pageInfos.pushPath({ name: RouterUrlConstants.ABOUT })
                }
              })
            }
          }
        }
      }
      .width(CommonConstants.FULL_WIN)
      .height(CommonConstants.FULL_WIN)
      .backgroundColor($r('app.color.start_window_background'))
      .padding({
        top: this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE,
        left: 16,
        right: 16
      })
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
    .titleBar({
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
          backgroundStyle: {
            backgroundColor: $r('app.color.title_bar_bg'),
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            },
            menuStyle: {
              backgroundColor: $r('app.color.action_bg'),
              textColor: $r('app.color.text_secondary'),
              iconColor: $r('app.color.text_primary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            },
          }
        },
        scrollEffectStyle: {
          backgroundStyle: {
            backgroundColor: $r('app.color.title_bar_bg'),
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary'),
            },
            menuStyle: {
              backgroundColor: $r('app.color.action_bg'),
              textColor: $r('app.color.text_secondary'),
              iconColor: $r('app.color.text_primary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        }
      },
      content: {
        title: {
          mainTitle: '个人中心',
        },
      },
      avoidLayoutSafeArea: true
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .bindSheet($$this.showEditSheet, this.EditSheetBuilder, {
      detents: [400],
      blurStyle: BlurStyle.Thick,
      showClose: true,
      showInSubWindow: false,
      title: { title: '我的账号' },
      backgroundColor: $r('app.color.card_background'),
      dragBar: true
    })
  }
}
