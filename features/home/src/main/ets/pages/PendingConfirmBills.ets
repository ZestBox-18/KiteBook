/**
 * Copyright (C), 2026-06-17
 * @author ZestBox
 * @date 2026/06/17
 * @version 1.0
 * @description: 待确认识别账单页面
 */

import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { AppThemeState, billSyncController, CommonConstants, SystemOptions, mainTabController } from 'base';
import { AddBillSheetComponent } from 'record';
import { AppStorageV2, LengthMetrics, PersistenceV2, uiMaterial } from '@kit.ArkUI';
import { CapsuleSegmentButtonV2, SegmentButtonV2Items } from '@ohos.arkui.advanced.SegmentButtonV2';
import { ColorMetrics } from '@ohos.arkui.node';
import { WindowUtil } from 'kite_utils';

class PendingConfirmBillDisplay {
  title: string;
  timeText: string;
  category: string;
  source: string;
  confidence: string;
  amountText: string;
  iconText: string;
  iconColor: ResourceColor;
  amountColor: ResourceColor;
  confidenceColor: ResourceColor;
  confidenceBackground: ResourceColor;

  constructor(
    title: string,
    timeText: string,
    category: string,
    source: string,
    confidence: string,
    amountText: string,
    iconText: string,
    iconColor: ResourceColor,
    amountColor: ResourceColor,
    confidenceColor: ResourceColor,
    confidenceBackground: ResourceColor
  ) {
    this.title = title;
    this.timeText = timeText;
    this.category = category;
    this.source = source;
    this.confidence = confidence;
    this.amountText = amountText;
    this.iconText = iconText;
    this.iconColor = iconColor;
    this.amountColor = amountColor;
    this.confidenceColor = confidenceColor;
    this.confidenceBackground = confidenceBackground;
  }
}

@ComponentV2
export struct PendingConfirmBills {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local selectedFilterIndex: number = 0;
  @Local isEditSheetShown: boolean = false;
  private readonly filterSegmentItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '全部' },
    { text: '高可信' },
    { text: '需修改' }
  ]);
  @Local records: PendingConfirmBillDisplay[] = [
    new PendingConfirmBillDisplay('喜茶（国贸店）', '今天 11:29', '餐饮', '屏幕识别', '高', '¥12.00', '支', '#1677FF', '#111827', '#16A34A', '#DCFCE7'),
    new PendingConfirmBillDisplay('京东-自营商品', '今天 10:15', '购物', '截图识别', '高', '-¥89.90', '微', '#22C55E', '#111827', '#16A34A', '#DCFCE7'),
    new PendingConfirmBillDisplay('北京地铁-乘车码支付', '今天 08:17', '交通', '屏幕识别', '中', '-¥6.00', '交', '#3B82F6', '#111827', '#F97316', '#FFEDD5'),
    new PendingConfirmBillDisplay('北京自来水集团', '昨天 19:35', '水电', '截图识别', '中', '-¥48.80', '水', '#F59E0B', '#111827', '#F97316', '#FFEDD5'),
    new PendingConfirmBillDisplay('转账-来自 张小明', '昨天 17:42', '转账', '屏幕识别', '高', '+¥300.00', '转', '#22C55E', '#16A34A', '#16A34A', '#DCFCE7')
  ];

  private createColorMetrics(color: ResourceColor): ColorMetrics {
    try {
      return ColorMetrics.resourceColor(color);
    } catch {
      return ColorMetrics.resourceColor(this.themeState.fontPrimary);
    }
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 12 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          ListItem() {
            Column() {
              this.SummaryCard()
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }

          ListItem() {
            Column() {
              this.FilterSegment()
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }

          ForEach(this.records, (record: PendingConfirmBillDisplay) => {
            ListItem() {
              Column() {
                this.PendingRecordCard(record)
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
            }
          }, (record: PendingConfirmBillDisplay) => record.title)

          ListItem() {
            Row({ space: 6 }) {
              SymbolGlyph($r('sys.symbol.info_circle'))
                .fontSize(14)
                .fontColor([this.themeState.fontSecondary as ResourceColor])
              Text('确认入账后将自动归类到对应账户，可在账单中查看')
                .fontSize(13)
                .fontColor(this.themeState.fontSecondary)
            }
            .width('100%')
            .padding({ left: 32, right: 32, bottom: 6 })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ bottom: this.winUtil.mainWindowInfo.navIndicatorHeight + 12 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor($r('[shared_assets].color.start_window_background'))
        .bindSheet($$this.isEditSheetShown, this.EditBillSheetBuilder(), {
          detents: [SheetSize.LARGE],
          showClose: false,
          enableFloatingDragBar: true,
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('[shared_assets].color.start_window_background'))
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
      content: {
        title: {
          mainTitle: '全部待确认',
          subTitle: '待确认识别记录'
        },
        menu: {
          value: [{
            content: {
              icon: $r('sys.symbol.ellipsis_circle'),
              label: '筛选',
              action: () => {
              }
            }
          }]
        }
      },
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
  private EditBillSheetBuilder() {
    AddBillSheetComponent({
      themeState: this.themeState,
      optionSystem: this.optionSystem,
      onClose: () => {
        this.isEditSheetShown = false;
      },
      onSaved: () => {
        this.isEditSheetShown = false;
        billSyncController.notifyBillChanged();
      }
    })
  }

  @Builder
  private SummaryCard() {
    Row() {
      this.SummaryMetric('待确认', '6', '笔', this.themeState.brand as ResourceColor)
      Divider().vertical(true).height(62).color('#E1E7EF')
      this.SummaryMetric('高可信', '4', '笔', '#16A34A')
      Divider().vertical(true).height(62).color('#E1E7EF')
      this.SummaryMetric('需修改', '2', '笔', '#F97316')
    }
    .width('100%')
    .height(104)
    .padding({ left: 8, right: 8 })
    .borderRadius(18)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .border({ width: 1, color: '#C8DCFF' })
  }

  @Builder
  private SummaryMetric(label: string, value: string, unit: string, color: ResourceColor) {
    Column() {
      Text(label)
        .fontSize(15)
        .fontColor(this.themeState.fontSecondary)
      Row({ space: 6 }) {
        Text(value)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
        Text(unit)
          .fontSize(14)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 10 })
      }
      .margin({ top: 8 })
      .alignItems(VerticalAlign.Bottom)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private FilterSegment() {
    CapsuleSegmentButtonV2({
      items: this.filterSegmentItems,
      selectedIndex: this.selectedFilterIndex,
      itemFontSize: LengthMetrics.vp(16),
      itemSelectedFontSize: LengthMetrics.vp(16),
      itemFontWeight: FontWeight.Medium,
      itemSelectedFontWeight: FontWeight.Bold,
      itemFontColor: this.createColorMetrics(this.themeState.fontPrimary as ResourceColor),
      itemSelectedFontColor: this.createColorMetrics(this.themeState.fontOnPrimary as ResourceColor),
      itemSelectedBackgroundColor: this.createColorMetrics(this.themeState.brand as ResourceColor),
      buttonBackgroundColor: this.createColorMetrics(this.themeState.compBackgroundPrimary as ResourceColor),
      buttonBorderRadius: LengthMetrics.vp(16),
      itemBorderRadius: LengthMetrics.vp(13),
      buttonPadding: LengthMetrics.vp(3),
      buttonMinHeight: LengthMetrics.vp(52),
      itemMinHeight: LengthMetrics.vp(46),
      $selectedIndex: (selectedIndex: number) => {
        this.selectedFilterIndex = selectedIndex;
      }
    })
      .width('100%')
      .border({ width: 1, color: '#D8E7FF' })
      .borderRadius(16)
  }

  @Builder
  private PendingRecordCard(record: PendingConfirmBillDisplay) {
    Row({ space: 12 }) {
      Text(record.iconText)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .width(54)
        .height(54)
        .borderRadius(27)
        .backgroundColor(record.iconColor)

      Column() {
        Text(record.title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(record.timeText)
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 6 })
        Row({ space: 8 }) {
          this.RecordTag(record.category, '#EAF2FF', this.themeState.brand as ResourceColor)
          this.RecordTag(record.source, '#EAF2FF', this.themeState.brand as ResourceColor)
          this.RecordTag(record.confidence, record.confidenceBackground, record.confidenceColor)
        }
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Text(record.amountText)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(record.amountColor)
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(18)
            .fontColor([this.themeState.fontSecondary as ResourceColor])
        }
        Button('确认入账')
          .width(94)
          .height(38)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .systemMaterial(new uiMaterial.ImmersiveMaterial({
            style: uiMaterial.ImmersiveStyle.ULTRA_THIN,
            interactive: true,
            lightEffect: {
              color: this.themeState.brand as ResourceColor
            }
          }))
          .backgroundColor(this.themeState.brand)
          .borderRadius(11)
        Button('修改')
          .width(94)
          .height(36)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontSecondary)
          .backgroundColor('#00000000')
          .systemMaterial(new uiMaterial.ImmersiveMaterial({
            style: uiMaterial.ImmersiveStyle.ULTRA_THIN,
            interactive: true,
            lightEffect: {
              color: this.themeState.brand as ResourceColor
            }
          }))
          .border({ width: 1, color: '#AFCBFF' })
          .borderRadius(11)
          .onClick(() => {
            this.isEditSheetShown = true;
          })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(14)
    .borderRadius(18)
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private RecordTag(label: string, backgroundColor: ResourceColor, textColor: ResourceColor) {
    Text(label)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor(textColor)
      .padding({ left: 9, right: 9, top: 4, bottom: 4 })
      .borderRadius(9)
      .backgroundColor(backgroundColor)
  }
}
