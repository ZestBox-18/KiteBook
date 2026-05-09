/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 关于页面
 */

import { CommonConstants, RouterUrlConstants, mainTabController, AppThemeState, SystemOptions } from 'base';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { WindowUtil, Clog } from 'kite_utils';
import { Want, common } from '@kit.AbilityKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { itemHead } from '../components/itemHead';

const TAG: string = '[About]';

@ComponentV2
export struct About {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  private context = getContext(this) as common.UIAbilityContext;
  // 主题颜色
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!
  // QQ 群号
  private qqGroupId: string = '123456789'

  private copyToClipboard(text: string): void {
    try {
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setData(pasteData).then(() => {
        promptAction.showToast({ message: '已复制' });
      }).catch(() => {
        promptAction.showToast({ message: '复制失败' });
      });
    } catch (e) {
      promptAction.showToast({ message: '复制出错' });
    }
  }

  private joinQQGroup(): void {
    const uri =
      `mqqapi://card/show_pslcard?src_type=internal&version=1&uin=${this.qqGroupId}&card_type=group&source=qrcode`;
    try {
      this.context.startAbility({ uri }).catch(() => {
        this.copyToClipboard(this.qqGroupId);
        promptAction.showToast({ message: '未能打开 QQ，已复制群号' });
      });
    } catch (e) {
      this.copyToClipboard(this.qqGroupId);
      promptAction.showToast({ message: '未能打开 QQ，已复制群号' });
    }
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          // 应用信息
          ListItemGroup({
            header: itemHead('应用信息'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Column() {
                Image($r('app.media.startIcon'))
                  .width(80)
                  .height(80)
                  .borderRadius(16)

                Text('纸鸢账本')
                  .fontSize(18)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('app.color.text_primary'))
                  .margin({ top: 12 })

                Text('v1.0.0')
                  .fontSize(14)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .width('100%')
              .padding(24)
              .alignItems(HorizontalAlign.Center)
            }
          }

          // 关于
          ListItemGroup({
            header: itemHead('关于'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            this.AboutItem('联系邮箱', 'zestbox@163.com', $r('sys.symbol.envelope'), () => {
              this.copyToClipboard('zestbox@163.com');
            })

            this.AboutItem('QQ 群聊', this.qqGroupId, $r('sys.symbol.person_3'), () => {
              this.joinQQGroup();
            })

            this.AboutItem('开发者', 'ZestBox', $r('sys.symbol.person'))
          }

          // 备案号
          ListItem() {
            Text('粤ICP备2024282649号-2A')
              .fontSize(12)
              .fontWeight(this.optionSystem.fontThickness)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .textAlign(TextAlign.Center)
              .onClick(() => {
                const want: Want = {
                  action: 'ohos.want.action.viewData',
                  entities: ['entity.system.browsable'],
                  uri: 'http://beian.miit.gov.cn/'
                };
                this.context.startAbility(want);
              })
          }
          .padding({ top: 16, bottom: 24 })
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
      content: { title: { mainTitle: "关于" } },
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
  LinkItem(text: string, icon: Resource, onClick: () => void) {
    Row() {
      SymbolGlyph(icon)
        .fontSize(20)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([this.themeState.brand])
        .margin({ right: 12 })

      Text(text)
        .fontSize(16)
        .fontWeight(this.optionSystem.fontThickness)
        .fontColor($r('app.color.text_primary'))

      Blank()

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(14)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([$r('app.color.text_secondary')])
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      onClick()
    })
  }

  @Builder
  AboutItem(label: string, value: string, icon: Resource, onClick?: () => void) {
    Row() {
      SymbolGlyph(icon)
        .fontSize(20)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([this.themeState.brand])
        .margin({ right: 12 })

      Text(label)
        .fontSize(16)
        .fontWeight(this.optionSystem.fontThickness)
        .fontColor($r('app.color.text_primary'))

      Blank()

      Text(value)
        .fontSize(14)
        .fontWeight(this.optionSystem.fontThickness)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)
        .gesture(
          LongPressGesture()
            .onAction(() => {
              this.copyToClipboard(value);
            })
        )
        .onClick(() => {
          if (onClick) {
            onClick();
          }
        })
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
  }
}
