/**
 * Copyright (C), 2026-05-08
 * @author ZestBox
 * @date 2026/05/08
 * @version 1.0
 * @description: 外观设置页面
 */

import { SystemOptions, gAppThemes, gAppThemeNames, CommonConstants, mainTabController, AppThemeState, GroupHeader } from 'base';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { AppStorageV2, LengthMetrics, ThemeControl } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { SystemColorModeUtil, WindowUtil } from 'kite_utils';
import { ThemeColorItem } from '../components/ThemeColorItem';

@ComponentV2
export struct AppearanceSettings {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  // 主题颜色
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!

  private isFollowSystem(): boolean {
    return this.optionSystem.darkMode === 'auto'
  }

  private isDarkMode(): boolean {
    return this.optionSystem.darkMode === 'dark'
  }

  @Local colorModeExpanded: boolean = false
  @Local iconScale: number = 1
  @Local iconAnimationVersion: number = 0

  private getAbilityContext(): common.UIAbilityContext | null {
    const hostContext = this.getUIContext().getHostContext()
    if (!hostContext) {
      return null
    }
    return hostContext as common.UIAbilityContext
  }

  aboutToAppear(): void {
    this.colorModeExpanded = !this.isFollowSystem()
  }

  /**
   * 应用主题（实时生效）
   */
  private applyTheme(index: number): void {
    if (index >= 0 && index < gAppThemes.length) {
      ThemeControl.setDefaultTheme(gAppThemes[index]);
    }
  }

  /**
   * 应用深色模式（实时生效）
   */
  private applyDarkMode(mode: string): void {
    const context = this.getAbilityContext()
    if (!context) {
      return
    }
    SystemColorModeUtil.applySystemColorMode(context, mode);
  }

  /**
   * 播放颜色模式图标弹跳动画，重复点击时只保留最后一轮动画。
   */
  private playIconBounceAnimation(): void {
    this.iconAnimationVersion = this.iconAnimationVersion + 1
    const currentVersion: number = this.iconAnimationVersion
    this.getUIContext().animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
      this.iconScale = 0.6
    })
    setTimeout(() => {
      if (currentVersion !== this.iconAnimationVersion) {
        return
      }
      this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
        this.iconScale = 1
      })
    }, 120)
  }

  /**
   * 仅在主题索引真正变化时写入设置并应用主题。
   */
  private updateThemeSelection(index: number): void {
    if (this.optionSystem.themeIndex === index) {
      return
    }
    this.optionSystem.themeIndex = index
    this.applyTheme(index)
  }

  /**
   * 仅在字体粗细真正变化时写入设置。
   */
  private updateFontThickness(value: number): void {
    if (this.optionSystem.fontThickness === value) {
      return
    }
    this.optionSystem.fontThickness = value
  }

  /**
   * 仅在图标粗细真正变化时写入设置。
   */
  private updateIconThickness(value: number): void {
    if (this.optionSystem.iconThickness === value) {
      return
    }
    this.optionSystem.iconThickness = value
  }

  /**
   * 统一更新深色模式，避免重复写入同一状态。
   */
  private updateDarkMode(mode: string): void {
    if (this.optionSystem.darkMode === mode) {
      return
    }
    this.optionSystem.darkMode = mode
    this.applyDarkMode(mode)
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          // 主题选择分组
          ListItemGroup({
            header: GroupHeader('主题选择'),
            space: 5,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Grid() {
                ForEach(gAppThemeNames, (name: string, index: number) => {
                  GridItem() {
                    ThemeColorItem({
                      color: this.getThemeColor(index),
                      name: name,
                      isSelected: this.optionSystem.themeIndex === index,
                      onSelect: () => {
                        this.updateThemeSelection(index)
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
            header: GroupHeader('字体粗细'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row({ space: 10 }) {
                Text('字体粗细')
                  .width(80)
                  .fontColor($r('[shared_assets].color.text_primary'))
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
                      this.optionSystem.fontThickness == 500 ? '正常' : '较粗')
                  .layoutWeight(1)
                  .onChange((value: number) => {
                    this.updateFontThickness(value)
                  })
              }
              .alignItems(VerticalAlign.Center)
              .width('100%')
              .padding(16)
            }
          }

          // 图标粗细分组
          ListItemGroup({
            header: GroupHeader('图标粗细'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row({ space: 10 }) {

                Row() {
                  SymbolGlyph($r('sys.symbol.paintpalette'))
                    .fontColor([$r('[shared_assets].color.text_primary')])
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
                      this.optionSystem.iconThickness == 500 ? '正常' : '较粗')
                  .layoutWeight(1)
                  .onChange((value: number) => {
                    this.updateIconThickness(value)
                  })
              }
              .alignItems(VerticalAlign.Center)
              .width('100%')
              .padding(16)
            }
          }

          // 颜色模式分组
          ListItemGroup({
            header: GroupHeader('颜色模式'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            // 跟随系统
            ListItem() {
              Row() {
                SymbolGlyph(this.isFollowSystem()
                  ? $r('sys.symbol.circle_filled_and_circle')
                  : (this.isDarkMode() ? $r('sys.symbol.moon_1') : $r('sys.symbol.sun_min')))
                  .fontSize(20)
                  .fontColor([$r('[shared_assets].color.text_primary')])
                  .margin({ right: 12 })
                  .scale({ x: this.iconScale, y: this.iconScale })
                  .animation({ duration: 250, curve: Curve.EaseInOut })
                  .fontWeight(this.optionSystem.iconThickness)

                Text('跟随系统')
                  .fontSize(16)
                  .fontColor($r('[shared_assets].color.text_primary'))
                  .fontWeight(this.optionSystem.fontThickness)

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.isFollowSystem() })
                  .selectedColor(this.themeState.brand)
                  .switchPointColor('#FFFFFF')
                  .onChange((isOn: boolean) => {
                    if (isOn === this.isFollowSystem()) {
                      return
                    }
                    this.playIconBounceAnimation()
                    this.getUIContext().animateTo({ duration: 250, curve: Curve.EaseInOut }, () => {
                      this.colorModeExpanded = !isOn
                    })
                    const nextMode: string = isOn ? 'auto' :
                      (this.optionSystem.darkMode === 'dark' ? 'dark' : 'light')
                    this.updateDarkMode(nextMode)
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }

            // 颜色模式
            ListItem() {
              Row() {
                Text('深色模式')
                  .fontSize(16)
                  .fontColor($r('[shared_assets].color.text_primary'))
                  .fontWeight(this.optionSystem.fontThickness)

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode() })
                  .selectedColor(this.themeState.brand)
                  .switchPointColor('#FFFFFF')
                  .onChange((isOn: boolean) => {
                    const nextMode: string = isOn ? 'dark' : 'light'
                    if (nextMode === this.optionSystem.darkMode) {
                      return
                    }
                    this.playIconBounceAnimation()
                    this.updateDarkMode(nextMode)
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }
            .height(this.colorModeExpanded ? 56 : 0)
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
      .backgroundColor($r('[shared_assets].color.title_bar_bg'))
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
          backgroundStyle: { backgroundColor: $r('[shared_assets].color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('[shared_assets].color.text_primary'),
              subTitleColor: $r('[shared_assets].color.text_secondary')
            },
            menuStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              iconColor: $r('[shared_assets].color.text_primary')
            },
            backIconStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              iconColor: $r('[shared_assets].color.text_primary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: { backgroundColor: $r('[shared_assets].color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('[shared_assets].color.text_primary'),
              subTitleColor: $r('[shared_assets].color.text_secondary')
            },
            menuStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              textColor: $r('[shared_assets].color.text_secondary')
            },
            backIconStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              iconColor: $r('[shared_assets].color.text_primary')
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
        .fontColor($r('[shared_assets].color.text_primary'))

      Blank()

      if (isSelected) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(16)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.brand as ResourceColor])
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
