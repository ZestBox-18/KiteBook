/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 个人中心主页面
 */

import { hdsMaterial, HdsNavigation, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { CommonConstants, RouterUrlConstants, SystemOptions, mainTabController, GroupHeader } from 'base';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { WindowUtil, Clog } from 'kite_utils';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { Want, common } from '@kit.AbilityKit';
import { UserProfile } from '../entities/UserProfile';
import { UserEditSheet } from '../components/UserEditSheet';
import { AppearanceSettings } from './AppearanceSettings';
import { NotificationSettings } from './NotificationSettings';
import { DataExport } from './DataExport';
import { BudgetSettings } from './BudgetSettings';
import { About } from './About';
import { Sponsorship } from './Sponsorship';
import { TestPage } from './TestPage';
import { UserCard } from '../components/UserCard';
import { SettingItem } from '../components/SettingItem';

const TAG: string = '[Profile]';

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
  @Local loginFailedTrigger: number = 0
  private context = getContext(this) as common.UIAbilityContext;

  /**
   * 页面路由表
   */
  @Builder
  PagesMap(name: string, param?: object) {
    if (name === RouterUrlConstants.APPEARANCE_SETTINGS) {
      AppearanceSettings()
    } else if (name === RouterUrlConstants.NOTIFICATION_SETTINGS) {
      NotificationSettings()
    } else if (name === RouterUrlConstants.DATA_EXPORT) {
      DataExport()
    } else if (name === RouterUrlConstants.BUDGET_SETTINGS) {
      BudgetSettings()
    } else if (name === RouterUrlConstants.ABOUT) {
      About()
    } else if (name === RouterUrlConstants.SPONSORSHIP) {
      Sponsorship()
    } else if (name === RouterUrlConstants.TEST_PAGE) {
      TestPage()
    }
  }

  /**
   * 导航到子页面（隐藏 Tab 栏）
   */
  private navigateToSubPage(name: string): void {
    mainTabController.applyHideAnimation(HdsAnimationMode.CLICK_ANIMATION);
    this.pageInfos.pushPath({ name: name });
  }

  /**
   * 用户编辑弹窗
   */
  @Builder
  EditSheetBuilder() {
    UserEditSheet({
      profile: this.userProfile,
      uiContext: this.getUIContext(),
      onClose: () => {
        this.showEditSheet = false
      },
      onLoginStart: () => {
        this.loginAnimationTrigger++
      },
      onLoginSuccess: () => {
        // 登录成功，通知 UserCard 切换头像
        this.loginAnimationTrigger++
      },
      onLogout: () => {
        this.logoutAnimationTrigger++
      },
      onLoginFailed: () => {
        this.loginFailedTrigger++
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
              uiContext: this.getUIContext(),
              loginAnimationTrigger: this.loginAnimationTrigger,
              logoutAnimationTrigger: this.logoutAnimationTrigger,
              loginFailedTrigger: this.loginFailedTrigger
            })
          }

          // 设置分组
          ListItemGroup({
            header: GroupHeader('设置'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.paintpalette'),
                title: '外观设置',
                onItemClick: () => {
                  this.navigateToSubPage(RouterUrlConstants.APPEARANCE_SETTINGS)
                }
              })
            }

            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.bell'),
                title: '通知设置',
                onItemClick: () => {
                  this.navigateToSubPage(RouterUrlConstants.NOTIFICATION_SETTINGS)
                }
              })
            }

            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.creditcard'),
                title: '预算管理',
                onItemClick: () => {
                  this.navigateToSubPage(RouterUrlConstants.BUDGET_SETTINGS)
                }
              })
            }

            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.arrow_up_circle'),
                title: '数据导出',
                onItemClick: () => {
                  this.navigateToSubPage(RouterUrlConstants.DATA_EXPORT)
                }
              })
            }
          }

          // 支持分组
          ListItemGroup({
            header: GroupHeader('支持'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.hand_thumbsup'),
                title: '给个好评',
                onItemClick: () => {
                  const link: string = 'https://appgallery.huawei.com/app/detail?id=cn.zestbox.kitebook';
                  const want: Want = {
                    action: 'ohos.want.action.viewData',
                    entities: ['entity.system.browsable'],
                    uri: link
                  };
                  this.context.startAbility(want).catch((error: BusinessError) => {
                    Clog.error(TAG, `Failed to open link: ${error.message}`);
                  });
                }
              })
            }

            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.gift'),
                title: '投喂作者',
                onItemClick: () => {
                  this.navigateToSubPage(RouterUrlConstants.SPONSORSHIP)
                }
              })
            }
          }

          // 关于分组
          ListItemGroup({
            header: GroupHeader('关于'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              SettingItem({
                icon: $r('sys.symbol.info_circle'),
                title: '关于',
                onItemClick: () => {
                  this.navigateToSubPage(RouterUrlConstants.ABOUT)
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
