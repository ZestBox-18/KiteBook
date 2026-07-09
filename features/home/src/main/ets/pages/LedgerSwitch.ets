/**
 * Copyright (C), 2026-07-04
 * @author ZestBox
 * @date 2026/07/04
 * @version 1.0
 * @description: 首页切换账本静态页面
 */

import { hdsMaterial, HdsAnimationMode, HdsNavDestination, ScrollEffectType } from '@kit.UIDesignKit';
import { AppThemeState, CommonConstants, mainTabController } from 'base';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { WindowUtil } from 'kite_utils';

class LedgerBookDisplayItem {
  title: string = '';
  subtitle: string = '';
  tag: string = '';
  tagColor: ResourceColor = '#16A34A';
  tagBackground: ResourceColor = '#EAF8EF';
  icon: Resource = $r('sys.symbol.person');
  iconBackground: ResourceColor = '#16A34A';
  metricLabel: string = '';
  metricValue: string = '';
  memberText: string = '';
  selected: boolean = false;

  constructor(
    title: string,
    subtitle: string,
    tag: string,
    tagColor: ResourceColor,
    tagBackground: ResourceColor,
    icon: Resource,
    iconBackground: ResourceColor,
    metricLabel: string,
    metricValue: string,
    memberText: string,
    selected: boolean
  ) {
    this.title = title;
    this.subtitle = subtitle;
    this.tag = tag;
    this.tagColor = tagColor;
    this.tagBackground = tagBackground;
    this.icon = icon;
    this.iconBackground = iconBackground;
    this.metricLabel = metricLabel;
    this.metricValue = metricValue;
    this.memberText = memberText;
    this.selected = selected;
  }
}

class LedgerIconOption {
  label: string = '';
  icon: Resource = $r('sys.symbol.book');
  backgroundColor: ResourceColor = '#16A34A';

  constructor(label: string, icon: Resource, backgroundColor: ResourceColor) {
    this.label = label;
    this.icon = icon;
    this.backgroundColor = backgroundColor;
  }
}

const LEDGER_DANGER_COLOR: ResourceColor = '#E55454';
const LEDGER_DISABLED_COLOR: ResourceColor = '#CBD5E1';
const LEDGER_INCOME_COLOR: ResourceColor = '#16A34A';
const LEDGER_WARNING_COLOR: ResourceColor = '#F97316';
const LEDGER_TRAVEL_COLOR: ResourceColor = '#26C6C2';
const LEDGER_WORK_COLOR: ResourceColor = '#7C5CF6';

@ComponentV2
export struct LedgerSwitch {
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local isLedgerEditorVisible: boolean = false;
  @Local ledgerEditorMode: string = 'create';
  @Local editingLedgerOriginalTitle: string = '';
  @Local editingLedgerTitle: string = '';
  @Local editingLedgerDescription: string = '';
  @Local editingIconIndex: number = 0;
  @Local editingSetCurrent: boolean = false;

  @Local books: LedgerBookDisplayItem[] = [
    new LedgerBookDisplayItem('默认账本', '个人日常收支记录', '个人', '#16A34A', '#EAF8EF',
      $r('sys.symbol.person'), '#16A34A', '本月支出', '¥2,186.50', '', true),
    new LedgerBookDisplayItem('旅行账本', '记录旅行中的收支与花费', '个人', '#16A34A', '#EAF8EF',
      $r('sys.symbol.car'), LEDGER_TRAVEL_COLOR, '最近记账', '今天 11:29', '', false),
    new LedgerBookDisplayItem('工作账本', '项目费用与报销记录', '个人', '#16A34A', '#EAF8EF',
      $r('sys.symbol.creditcard'), LEDGER_WORK_COLOR, '本月支出', '¥5,620.00', '', false),
    new LedgerBookDisplayItem('学习账本', '学习资料与课程费用记录', '个人', '#16A34A', '#EAF8EF',
      $r('sys.symbol.book'), LEDGER_WARNING_COLOR, '账单数', '28 笔', '', false),
    new LedgerBookDisplayItem('家庭账本', '和家人共同记录生活开支', '协作', '#16A34A', '#EAF8EF',
      $r('sys.symbol.house'), '#FF7043', '本月支出', '¥3,458.90', '3人协作', false),
    new LedgerBookDisplayItem('毕业设计小组', '项目支出与采购记录', '协作', '#16A34A', '#EAF8EF',
      $r('sys.symbol.book'), LEDGER_TRAVEL_COLOR, '本月支出', '¥1,265.00', '4人协作', false)
  ];

  private readonly iconOptions: LedgerIconOption[] = [
    new LedgerIconOption('默认', $r('sys.symbol.book'), '#16A34A'),
    new LedgerIconOption('旅行', $r('sys.symbol.car'), LEDGER_TRAVEL_COLOR),
    new LedgerIconOption('家庭', $r('sys.symbol.house'), '#FF7043'),
    new LedgerIconOption('工作', $r('sys.symbol.creditcard'), LEDGER_WORK_COLOR),
    new LedgerIconOption('学习', $r('sys.symbol.book'), LEDGER_WARNING_COLOR)
  ];

  private openCreateLedgerSheet(): void {
    this.ledgerEditorMode = 'create';
    this.editingLedgerOriginalTitle = '';
    this.editingLedgerTitle = '';
    this.editingLedgerDescription = '';
    this.editingIconIndex = 0;
    this.editingSetCurrent = false;
    this.isLedgerEditorVisible = true;
  }

  private openEditLedgerSheet(item: LedgerBookDisplayItem): void {
    this.ledgerEditorMode = 'edit';
    this.editingLedgerOriginalTitle = item.title;
    this.editingLedgerTitle = item.title;
    this.editingLedgerDescription = item.subtitle;
    this.editingIconIndex = this.getIconOptionIndex(item.iconBackground);
    this.editingSetCurrent = item.selected;
    this.isLedgerEditorVisible = true;
  }

  private closeLedgerEditorSheet(): void {
    this.isLedgerEditorVisible = false;
  }

  private deleteLedger(item: LedgerBookDisplayItem): void {
    if (item.selected) {
      return;
    }
    this.books = this.books.filter((book: LedgerBookDisplayItem) => book.title !== item.title);
  }

  private saveLedgerEditor(): void {
    const title: string = this.editingLedgerTitle.trim().length > 0 ? this.editingLedgerTitle.trim() : '新账本';
    const description: string = this.editingLedgerDescription.trim().length > 0 ? this.editingLedgerDescription.trim() :
      '记录新的收支账本';
    const iconOption: LedgerIconOption = this.iconOptions[this.editingIconIndex];

    if (this.ledgerEditorMode === 'create') {
      const createdItem: LedgerBookDisplayItem =
        new LedgerBookDisplayItem(title, description, '个人', '#16A34A', '#EAF8EF', iconOption.icon,
          iconOption.backgroundColor, '账单数', '0 笔', '', false);
      if (this.editingSetCurrent) {
        this.books.forEach((item: LedgerBookDisplayItem) => {
          item.selected = false;
        });
        createdItem.selected = true;
      }
      this.books = this.books.concat([createdItem]);
    } else {
      this.books.forEach((item: LedgerBookDisplayItem) => {
        if (item.title === this.editingLedgerOriginalTitle) {
          item.title = title;
          item.subtitle = description;
          item.icon = iconOption.icon;
          item.iconBackground = iconOption.backgroundColor;
          item.selected = this.editingSetCurrent;
        } else if (this.editingSetCurrent) {
          item.selected = false;
        }
      });
      this.books = this.books.slice();
    }

    this.closeLedgerEditorSheet();
  }

  private getIconOptionIndex(backgroundColor: ResourceColor): number {
    for (let index = 0; index < this.iconOptions.length; index++) {
      if (this.iconOptions[index].backgroundColor === backgroundColor) {
        return index;
      }
    }
    return 0;
  }

  private getLedgerTagColor(item: LedgerBookDisplayItem): ResourceColor {
    if (item.tag === '协作') {
      return LEDGER_INCOME_COLOR;
    }
    return this.themeState.brand;
  }

  private getLedgerTagBackground(item: LedgerBookDisplayItem): ResourceColor {
    if (item.tag === '协作') {
      return '#EAF8EF';
    }
    return this.themeState.compBackgroundNeutral;
  }

  private getBookIconBackground(item: LedgerBookDisplayItem): ResourceColor {
    if (item.iconBackground === LEDGER_INCOME_COLOR) {
      return this.themeState.brand;
    }
    return item.iconBackground;
  }

  private getIconOptionBackground(option: LedgerIconOption): ResourceColor {
    if (option.backgroundColor === LEDGER_INCOME_COLOR) {
      return this.themeState.brand;
    }
    return option.backgroundColor;
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          ListItem() {
            this.CurrentLedgerCard()
          }

          ListItem() {
            Text('全部账本')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontPrimary)
              .width('100%')
              .padding({ top: 2, bottom: 6 })
          }

          ListItemGroup({
            style: ListItemGroupStyle.CARD
          }) {
            ForEach(this.books, (item: LedgerBookDisplayItem, index: number) => {
              ListItem() {
                this.LedgerListRow(item)
              }
              .swipeAction({
                end: this.LedgerSwipeAction(item)
              })
            }, (item: LedgerBookDisplayItem) => item.title)
          }
          .divider({
            strokeWidth: 0.5,
            color: this.themeState.compDivider,
            startMargin: 74,
            endMargin: 16
          })
          .borderRadius(18)
          .clip(true)
          .backgroundColor(this.themeState.compBackgroundPrimary)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .contentEndOffset(this.winUtil.mainWindowInfo.navIndicatorHeight + 16)
        .backgroundColor($r('[shared_assets].color.title_bar_bg'))
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('[shared_assets].color.title_bar_bg'))
    }
    .titleBar({
      padding: {
        start: LengthMetrics.vp(20),
        end: LengthMetrics.vp(20)
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
              textColor: $r('[shared_assets].color.text_secondary'),
              iconColor: $r('[shared_assets].color.text_primary')
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
          mainTitle: '切换账本',
          subTitle: '选择你要查看和记账的账本'
        },
        menu: {
          value: [{
            content: {
              icon: $r('sys.symbol.plus'),
              label: '新增',
              action: () => {
                this.openCreateLedgerSheet();
              }
            }
          }]
        },
      },
      avoidLayoutSafeArea: true
    })
    .bindSheet($$this.isLedgerEditorVisible, this.LedgerEditorSheetBuilder(), {
      detents: [SheetSize.LARGE],
      preferType: SheetType.BOTTOM,
      showClose: false,
      enableFloatingDragBar: true
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
  private CurrentLedgerCard() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        this.BookIcon($r('sys.symbol.book'), this.themeState.brand, 52)

        Column({ space: 6 }) {
          Row({ space: 8 }) {
            Text('默认账本')
              .fontSize(21)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.fontPrimary)
            Text('当前使用中')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.brand)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(7)
              .backgroundColor(this.themeState.compBackgroundNeutral)
          }

          Text('个人日常收支记录')
            .fontSize(14)
            .fontColor(this.themeState.fontSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Row() {
        this.CurrentMetric('本月支出', '¥2,186.50', this.themeState.brand)
        this.VerticalDivider(44)
        this.CurrentMetric('本月收入', '¥1,280.00', LEDGER_INCOME_COLOR)
        this.VerticalDivider(44)
        this.CurrentMetric('成员', '1 人', this.themeState.fontPrimary)
      }
      .width('100%')
      .padding({ top: 10, bottom: 10 })
      .borderRadius(14)
      .backgroundColor(this.themeState.compBackgroundPrimary)
    }
    .width('100%')
    .padding(14)
    .borderRadius(18)
    .border({ width: 1, color: this.themeState.brand })
    .linearGradient({
      angle: 135,
      colors: [[this.themeState.compBackgroundNeutral as ResourceColor, 0.0],
        [this.themeState.compBackgroundPrimary as ResourceColor, 1.0]]
    })
  }

  @Builder
  private LedgerListRow(item: LedgerBookDisplayItem) {
    Row({ space: 12 }) {
      this.BookIcon(item.icon, this.getBookIconBackground(item), 48)

      Column({ space: 5 }) {
        Row({ space: 7 }) {
          Text(item.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(item.tag)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getLedgerTagColor(item))
            .padding({ left: 7, right: 7, top: 2, bottom: 2 })
            .borderRadius(6)
            .backgroundColor(this.getLedgerTagBackground(item))
        }

        Text(item.subtitle)
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (item.memberText.length > 0) {
          Text(item.memberText)
            .fontSize(12)
            .fontColor(this.themeState.fontSecondary)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 6 }) {
        Text(item.metricLabel)
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
        Text(item.metricValue)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(item.selected ? this.themeState.brand : this.themeState.fontPrimary)
      }
      .width(82)
      .alignItems(HorizontalAlign.Start)

      this.SelectMark(item.selected)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 13, bottom: 13 })
  }

  @Builder
  private LedgerSwipeAction(item: LedgerBookDisplayItem) {
    Row({ space: 8 }) {
      Button('编辑')
        .width(68)
        .height(38)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.brand)
        .backgroundColor(this.themeState.compBackgroundNeutral)
        .borderRadius(12)
        .onClick(() => {
          this.openEditLedgerSheet(item);
        })

      Button('删除')
        .width(68)
        .height(38)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontOnPrimary)
        .backgroundColor(item.selected ? LEDGER_DISABLED_COLOR : LEDGER_DANGER_COLOR)
        .borderRadius(12)
        .onClick(() => {
          this.deleteLedger(item);
        })
    }
    .padding({ right: 4 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private LedgerEditorSheetBuilder() {
    Column() {
      Row() {
        Column({ space: 6 }) {
          Text(this.ledgerEditorMode === 'create' ? '新建账本' : '编辑账本')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)
          Text(this.ledgerEditorMode === 'create' ? '填写账本信息，创建后可随时邀请成员协作' : '修改名称、图标与账本说明')
            .fontSize(14)
            .fontColor(this.themeState.fontSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(22)
          .fontColor([this.themeState.fontSecondary as ResourceColor])
          .width(40)
          .height(40)
          .onClick(() => {
            this.closeLedgerEditorSheet();
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        Text('账本名称')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .width(94)
        Divider()
          .vertical(true)
          .height(22)
          .color(this.themeState.compDivider)
        TextInput({ text: this.editingLedgerTitle, placeholder: '例如：旅行账本' })
          .fontSize(16)
          .fontColor(this.themeState.fontPrimary)
          .placeholderColor(this.themeState.fontSecondary)
          .backgroundColor('#00000000')
          .layoutWeight(1)
          .onChange((value: string) => {
            this.editingLedgerTitle = value;
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 14, right: 14 })
      .borderRadius(14)
      .border({ width: 1, color: this.themeState.compDivider })
      .margin({ top: 24 })

      Text('账本图标')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)
        .width('100%')
        .margin({ top: 22, bottom: 12 })

      Row({ space: 12 }) {
        ForEach(this.iconOptions, (option: LedgerIconOption, index: number) => {
          this.IconOptionCard(option, index)
        }, (option: LedgerIconOption) => option.label)
      }
      .width('100%')

      Text('账本说明（选填）')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)
        .width('100%')
        .margin({ top: 22, bottom: 12 })

      Stack({ alignContent: Alignment.BottomEnd }) {
        TextArea({ text: this.editingLedgerDescription, placeholder: '例如：记录大阪旅行的收支' })
          .fontSize(16)
          .fontColor(this.themeState.fontPrimary)
          .placeholderColor(this.themeState.fontSecondary)
          .backgroundColor('#00000000')
          .width('100%')
          .height(116)
          .padding({ left: 14, right: 14, top: 12, bottom: 24 })
          .onChange((value: string) => {
            if (value.length <= 100) {
              this.editingLedgerDescription = value;
            }
          })

        Text(`${this.editingLedgerDescription.length}/100`)
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
          .margin({ right: 14, bottom: 10 })
      }
      .width('100%')
      .borderRadius(14)
      .border({ width: 1, color: this.themeState.compDivider })

      Row() {
        Text('账本币种')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .width(94)
        Divider()
          .vertical(true)
          .height(22)
          .color(this.themeState.compDivider)
        Text('人民币  CNY')
          .fontSize(16)
          .fontColor(this.themeState.fontPrimary)
          .layoutWeight(1)
          .margin({ left: 18 })
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(18)
          .fontColor([this.themeState.fontSecondary as ResourceColor])
      }
      .width('100%')
      .height(56)
      .padding({ left: 14, right: 14 })
      .borderRadius(14)
      .border({ width: 1, color: this.themeState.compDivider })
      .margin({ top: 22 })

      Row() {
        Text('设为当前账本')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.editingSetCurrent })
          .selectedColor(this.themeState.brand)
          .switchPointColor(this.themeState.fontOnPrimary)
          .onChange((isOn: boolean) => {
            this.editingSetCurrent = isOn;
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 14, right: 14 })
      .borderRadius(14)
      .border({ width: 1, color: this.themeState.compDivider })
      .margin({ top: 12 })

      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.info_circle'))
          .fontSize(15)
          .fontColor([this.themeState.fontSecondary as ResourceColor])
        Text('创建成功后，可通过分享邀请成员一起协作')
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 14 })

      Button(this.ledgerEditorMode === 'create' ? '创建账本' : '保存修改')
        .width('100%')
        .height(52)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontOnPrimary)
        .backgroundColor(this.themeState.brand)
        .borderRadius(14)
        .margin({ top: 22 })
        .onClick(() => {
          this.saveLedgerEditor();
        })

      Button('取消')
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.brand)
        .backgroundColor('#00000000')
        .margin({ top: 8 })
        .onClick(() => {
          this.closeLedgerEditorSheet();
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 18, bottom: this.winUtil.mainWindowInfo.navIndicatorHeight + 16 })
    .backgroundColor($r('[shared_assets].color.title_bar_bg'))
  }

  @Builder
  private IconOptionCard(option: LedgerIconOption, index: number) {
    Column({ space: 8 }) {
      this.BookIcon(option.icon, this.getIconOptionBackground(option), 40)
      Text(option.label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.editingIconIndex === index ? this.themeState.brand : this.themeState.fontSecondary)
    }
    .layoutWeight(1)
    .height(86)
    .justifyContent(FlexAlign.Center)
    .borderRadius(14)
    .border({ width: 1, color: this.editingIconIndex === index ? this.themeState.brand : this.themeState.compDivider })
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .onClick(() => {
      this.editingIconIndex = index;
    })
  }

  @Builder
  private CurrentMetric(label: string, value: string, color: ResourceColor) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private VerticalDivider(height: number) {
    Column()
      .width(1)
      .height(height)
      .backgroundColor(this.themeState.compDivider)
  }

  @Builder
  private BookIcon(icon: Resource, backgroundColor: ResourceColor, size: number) {
    Row() {
      SymbolGlyph(icon)
        .fontSize(size * 0.52)
        .fontColor([this.themeState.fontOnPrimary as ResourceColor])
    }
    .width(size)
    .height(size)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .borderRadius(11)
    .backgroundColor(backgroundColor)
  }

  @Builder
  private SelectMark(selected: boolean) {
    Row() {
      if (selected) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(20)
          .fontColor([this.themeState.fontOnPrimary as ResourceColor])
      }
    }
    .width(24)
    .height(24)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .borderRadius(12)
    .backgroundColor(selected ? this.themeState.brand : '#00000000')
    .border({ width: selected ? 0 : 1.5, color: selected ? this.themeState.brand : this.themeState.compDivider })
  }
}
