import { hdsMaterial, HdsNavigation, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { CommonConstants, RouterUrlConstants, SystemOptions, mainTabController } from 'base';
import { Assets, Ordinary } from 'record';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { WindowUtil } from 'kite_utils';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';

const TAG: string = '[HomeIndex]';

@Entry
@ComponentV2
export struct Index {
  // 页面路由栈
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  private scrollerForScroll: Scroller = new Scroller();
  // 用户设置项
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!

  /**
   * 页面路由表
   * @param name 路由名
   * @param param 携带方法体
   */
  @Builder
  PagesMap(name: string, param?: object) {
    if (name === RouterUrlConstants.ORDINARY) {
      Ordinary()
    }
    if (name === RouterUrlConstants.ASSETS) {
      Assets()
    }
  }

  /**
   * 导航到子页面（隐藏 Tab 栏）
   */
  private navigateToSubPage(name: string): void {
    mainTabController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
    this.pageInfos.pushPath({ name: name });
  }

  aboutToAppear() {
  }

  build() {
    HdsNavigation(this.pageInfos) {
      Scroll(this.scrollerForScroll) {
        Column() {
          Blank().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)
          // TODO: 首页内容区域
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
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
          mainTitle: '纸鸢账本',
          subTitle: '个人账本'
        },
        menu: {
          value: [{
            content: {
              icon: $r('sys.symbol.house'),
              label: 'logo',
              action: () => {
              },
            }
          }]
        },
      },
      avoidLayoutSafeArea: true
    })
    .bindToScrollable([this.scrollerForScroll])
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }
}
