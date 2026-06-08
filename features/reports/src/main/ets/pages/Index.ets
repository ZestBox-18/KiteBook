/**
 * Copyright (C), 2026-05-23
 * @author ZestBox
 * @date 2026/05/23
 * @version 1.0
 * @description: 报表主页面
 */

import { hdsMaterial, HdsNavigation, ScrollEffectType } from '@kit.UIDesignKit';
import { AppThemeState, CommonConstants, billSyncController } from 'base';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { CapsuleSegmentButtonV2, SegmentButtonV2Items } from '@ohos.arkui.advanced.SegmentButtonV2';
import { ColorMetrics } from '@ohos.arkui.node';
import { WindowUtil } from 'kite_utils';
import { IncomeExpenseReport } from './IncomeExpenseReport';
import { CategoryReport } from './CategoryReport';
import { AssetReport } from './AssetReport';
import { BudgetReport } from './BudgetReport';

interface ReportMeta {
  title: string;
  subtitle: string;
  badge: string;
  accent: ResourceColor;
}

interface FeatureChip {
  title: string;
  subtitle: string;
}

const PAGE_PADDING: number = 16;
const SECTION_GAP: number = 16;
const CARD_RADIUS: number = 24;
const CHIP_RADIUS: number = 16;
const HERO_BADGE_SIZE: number = 56;
const HERO_BADGE_RADIUS: number = 18;
const HERO_BADGE_TEXT: string = '#FFFFFF';
const HERO_CAPTION: string = 'REPORTS';
const REPORT_TITLE: string = '报表中心';
const REPORT_SUBTITLE: string = '一屏查看账本的趋势、结构、资产和预算';
const TAB_LABEL: string = '选择报表';
const FEATURE_CHIPS: FeatureChip[] = [
  { title: '4 个维度', subtitle: '趋势 / 分类 / 资产 / 预算' },
  { title: '统一入口', subtitle: '切换更快，阅读更顺' },
  { title: '主题适配', subtitle: '自动跟随深色浅色模式' }
];
const REPORT_META_LIST: ReportMeta[] = [
  {
    title: '收支趋势',
    subtitle: '按日、周、月、年追踪收入、支出与结余变化。',
    badge: '趋势分析',
    accent: '#4BB3FF'
  },
  {
    title: '分类构成',
    subtitle: '查看各消费类别的占比、排序和金额分布。',
    badge: '结构拆解',
    accent: '#50D3A1'
  },
  {
    title: '资产变化',
    subtitle: '跟踪账户总额、净资产和阶段性增长曲线。',
    badge: '资产看板',
    accent: '#E1C67A'
  },
  {
    title: '预算追踪',
    subtitle: '关注预算使用率、剩余额度和风险提醒。',
    badge: '预算控制',
    accent: '#FF9966'
  }
];

@ComponentV2
export struct Index {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local currentTabIndex: number = 0;
  @Local reportRefreshToken: number = 0;

  private billSyncListenerId: number = -1;

  private readonly tabItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: $r('app.string.reports_income_expense') },
    { text: $r('app.string.reports_category') },
    { text: $r('app.string.reports_asset') },
    { text: $r('app.string.reports_budget') }
  ]);

  private getCurrentMeta(): ReportMeta {
    return REPORT_META_LIST[this.currentTabIndex] || REPORT_META_LIST[0];
  }

  private createColorMetrics(color: ResourceColor): ColorMetrics {
    try {
      return ColorMetrics.resourceColor(color);
    } catch {
      return ColorMetrics.resourceColor(this.themeState.fontPrimary);
    }
  }

  aboutToAppear(): void {
    if (this.billSyncListenerId < 0) {
      this.billSyncListenerId = billSyncController.register(() => {
        this.reportRefreshToken = this.reportRefreshToken + 1;
      });
    }
  }

  aboutToDisappear(): void {
    if (this.billSyncListenerId >= 0) {
      billSyncController.unregister(this.billSyncListenerId);
      this.billSyncListenerId = -1;
    }
  }

  build() {
    HdsNavigation(this.pageInfos) {
      Column() {
        Blank().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)

        Column({ space: SECTION_GAP }) {
          this.HeroSection()
          this.TabSection()
          this.ContentSection()
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ left: PAGE_PADDING, right: PAGE_PADDING, bottom: PAGE_PADDING })
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .backgroundColor(this.themeState.backgroundPrimary)
    .mode(NavigationMode.Stack)
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
            backgroundColor: $r('[shared_assets].color.title_bar_bg')
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('[shared_assets].color.text_primary'),
              subTitleColor: $r('[shared_assets].color.text_secondary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: {
            backgroundColor: $r('[shared_assets].color.title_bar_bg')
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('[shared_assets].color.text_primary'),
              subTitleColor: $r('[shared_assets].color.text_secondary')
            }
          }
        }
      },
      content: {
        title: {
          mainTitle: '报表中心',
          subTitle: '一屏查看账本的趋势、结构、资产和预算'
        }
      },
      avoidLayoutSafeArea: true
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }

  @Builder
  private HeroSection() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 8 }) {
          Text(HERO_CAPTION)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.brand)
            .letterSpacing(1.2)
          Text(this.getCurrentMeta().title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)
          Text(this.getCurrentMeta().subtitle)
            .fontSize(14)
            .lineHeight(20)
            .fontColor(this.themeState.fontSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
        }
        .layoutWeight(1)

        Column() {
          Text(this.getCurrentMeta().badge)
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor(HERO_BADGE_TEXT)
            .textAlign(TextAlign.Center)
        }
        .width(HERO_BADGE_SIZE)
        .height(HERO_BADGE_SIZE)
        .borderRadius(HERO_BADGE_RADIUS)
        .backgroundColor(this.createColorMetrics(this.getCurrentMeta().accent))
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }

      Row({ space: 8 }) {
        this.InfoChip(FEATURE_CHIPS[0])
        this.InfoChip(FEATURE_CHIPS[1])
        this.InfoChip(FEATURE_CHIPS[2])
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(24)
    .shadow({ radius: 2, color: '#14000000', offsetX: 0, offsetY: 1 })
  }

  @Builder
  private InfoChip(item: FeatureChip) {
    Column({ space: 2 }) {
      Text(item.title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)
      Text(item.subtitle)
        .fontSize(11)
        .fontColor(this.themeState.fontSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(this.themeState.compBackgroundNeutral)
    .borderRadius(CHIP_RADIUS)
  }

  @Builder
  private TabSection() {
    Column({ space: 10 }) {
      Row() {
        Text(TAB_LABEL)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
        Blank()
        Text(this.getCurrentMeta().badge)
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
      }
      .width('100%')

      CapsuleSegmentButtonV2({
        items: this.tabItems,
        selectedIndex: this.currentTabIndex,
        itemFontSize: LengthMetrics.vp(14),
        itemSelectedFontSize: LengthMetrics.vp(14),
        itemFontWeight: FontWeight.Medium,
        itemSelectedFontWeight: FontWeight.Bold,
        itemFontColor: this.createColorMetrics(this.themeState.fontSecondary),
        itemSelectedFontColor: this.createColorMetrics(this.themeState.fontOnPrimary),
        itemSelectedBackgroundColor: this.createColorMetrics(this.themeState.brand),
        buttonBackgroundColor: this.createColorMetrics(this.themeState.compBackgroundPrimary),
        buttonBorderRadius: LengthMetrics.vp(24),
        itemBorderRadius: LengthMetrics.vp(20),
        buttonPadding: LengthMetrics.vp(4),
        buttonMinHeight: LengthMetrics.vp(44),
        itemMinHeight: LengthMetrics.vp(36),
        $selectedIndex: (selectedIndex: number) => {
          this.currentTabIndex = selectedIndex;
        }
      })
      .width('100%')
    }
    .width('100%')
    .padding(PAGE_PADDING)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(CARD_RADIUS)
    .shadow({ radius: 2, color: '#12000000', offsetX: 0, offsetY: 1 })
  }

  @Builder
  private ContentSection() {
    Column() {
      if (this.currentTabIndex === 0) {
        IncomeExpenseReport({ refreshToken: this.reportRefreshToken })
      } else if (this.currentTabIndex === 1) {
        CategoryReport({ refreshToken: this.reportRefreshToken })
      } else if (this.currentTabIndex === 2) {
        AssetReport({ refreshToken: this.reportRefreshToken })
      } else {
        BudgetReport({ refreshToken: this.reportRefreshToken })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
