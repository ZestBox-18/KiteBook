/**
 * Copyright (C), 2026-05-23
 * @author ZestBox
 * @date 2026/05/23
 * @version 1.0
 * @description: 报表主页面
 */

import { hdsMaterial, HdsNavigation, ScrollEffectType } from '@kit.UIDesignKit';
import { AppThemeState, CommonConstants } from 'base';
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

@ComponentV2
export struct Index {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local currentTabIndex: number = 0;

  private readonly tabItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: $r('app.string.reports_income_expense') },
    { text: $r('app.string.reports_category') },
    { text: $r('app.string.reports_asset') },
    { text: $r('app.string.reports_budget') }
  ]);

  private readonly reportMetaList: ReportMeta[] = [
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

  private getCurrentMeta(): ReportMeta {
    return this.reportMetaList[this.currentTabIndex] || this.reportMetaList[0];
  }

  build() {
    HdsNavigation(this.pageInfos) {
      Column() {
        Blank().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)

        Column({ space: 16 }) {
          this.HeroSection()
          this.TabSection()
          this.ContentSection()
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
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
            backgroundColor: $r('app.color.title_bar_bg')
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: {
            backgroundColor: $r('app.color.title_bar_bg')
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
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
          Text('REPORTS')
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
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
        }
        .width(56)
        .height(56)
        .borderRadius(18)
        .backgroundColor(ColorMetrics.resourceColor(this.getCurrentMeta().accent))
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }

      Row({ space: 8 }) {
        this.InfoChip('4 个维度', '趋势 / 分类 / 资产 / 预算')
        this.InfoChip('统一入口', '切换更快，阅读更顺')
        this.InfoChip('主题适配', '自动跟随深色浅色模式')
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
  private InfoChip(title: string, subtitle: string) {
    Column({ space: 2 }) {
      Text(title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)
      Text(subtitle)
        .fontSize(11)
        .fontColor(this.themeState.fontSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(this.themeState.compBackgroundNeutral)
    .borderRadius(16)
  }

  @Builder
  private TabSection() {
    Column({ space: 10 }) {
      Row() {
        Text('选择报表')
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
        itemFontColor: ColorMetrics.resourceColor(this.themeState.fontSecondary),
        itemSelectedFontColor: ColorMetrics.resourceColor(this.themeState.fontOnPrimary),
        itemSelectedBackgroundColor: ColorMetrics.resourceColor(this.themeState.brand),
        buttonBackgroundColor: ColorMetrics.resourceColor(this.themeState.compBackgroundPrimary),
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
    .padding(16)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(24)
    .shadow({ radius: 2, color: '#12000000', offsetX: 0, offsetY: 1 })
  }

  @Builder
  private ContentSection() {
    Column() {
      if (this.currentTabIndex === 0) {
        IncomeExpenseReport()
      } else if (this.currentTabIndex === 1) {
        CategoryReport()
      } else if (this.currentTabIndex === 2) {
        AssetReport()
      } else {
        BudgetReport()
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
