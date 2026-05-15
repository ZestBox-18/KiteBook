/**
 * Copyright (C), 2025-05-13
 * @author ZestBox
 * @date 2025/05/13
 * @version 1.0
 * @description: 首页 - 使用 customContentTransition 实现拖拽实时动画
 */

import { hdsMaterial, HdsNavigation, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import {
  CommonConstants,
  RouterUrlConstants,
  SystemOptions,
  AppThemeState,
  BillManager,
  BillGroup,
  BillBean,
  BillTypeEnum,
  mainTabController,
  GroupHeader
} from 'base';
import { Assets, Ordinary } from 'record';
import { AppStorageV2, LengthMetrics, SymbolGlyphModifier, curves } from '@kit.ArkUI';
import { WindowUtil, Clog } from 'kite_utils';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { BillItemComponent } from '../components/BillItemComponent';
import { EmptyStateComponent } from '../components/EmptyStateComponent';
import { SectionHeaderComponent } from '../components/SectionHeaderComponent';
import { DeleteSwipeButtonComponent } from '../components/DeleteSwipeButtonComponent';

const TAG: string = '[HomeIndex]';
const CARD_COUNT: number = 3;
const MIN_SCALE: number = 0.85;
const MAX_ROTATE: number = 5; // 最大旋转角度
const GRADIENT_DELAY: number = 80;

@Entry
@ComponentV2
export struct Index {
  // 页面路由栈
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  private scrollerForScroll: Scroller = new Scroller();
  // 用户设置项
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  // 账单数据
  @Local billGroups: BillGroup[] = [];
  // Swiper 状态
  @Local swiperIndex: number = 0;
  // 卡片动画状态
  @Local opacityList: number[] = [1, 1, 1];
  @Local scaleList: number[] = [1, 1, 1];
  @Local rotateList: number[] = [0, 0, 0];
  @Local zIndexList: number[] = [0, 0, 0];
  // 指示器控制器
  private indicatorController: IndicatorComponentController = new IndicatorComponentController();
  private swiperController: SwiperController = new SwiperController();

  /**
   * 页面路由表
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
   * 删除按钮 Builder（swipeAction 需要 @Builder）
   */
  @Builder
  DeleteSwipeBuilder(billId: number) {
    DeleteSwipeButtonComponent({ onDelete: () => this.deleteBill(billId) })
  }

  /**
   * 导航到子页面
   */
  private navigateToSubPage(name: string): void {
    mainTabController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
    this.pageInfos.pushPath({ name: name });
  }

  /**
   * 获取 SectionHeader 标题
   */
  private getHeaderTitle(index: number): string {
    if (index === 0) {
      return '预算支出明细';
    }
    if (index === 1) {
      return '收支明细';
    }
    return '资产变动';
  }

  /**
   * 获取 SectionHeader 跳转路由
   */
  private getHeaderRoute(index: number): string {
    if (index === 0) {
      return RouterUrlConstants.ORDINARY;
    }
    if (index === 1) {
      return RouterUrlConstants.ORDINARY;
    }
    return RouterUrlConstants.ASSETS;
  }

  /**
   * 加载账单数据
   */
  private async loadBillData(): Promise<void> {
    try {
      this.billGroups = await BillManager.getRecentBills(3);
    } catch (err) {
      Clog.error(TAG, '加载账单数据失败', err);
    }
  }

  /**
   * 删除账单
   */
  private async deleteBill(billId: number): Promise<void> {
    try {
      await BillManager.deleteBill(billId);
      await this.loadBillData();
    } catch (err) {
      Clog.error(TAG, '删除账单失败', err);
    }
  }

  /**
   * 格式化日期标题
   */
  private formatDateTitle(dateStr: string): string {
    const today = new Date();
    const todayStr = `${today.getFullYear()}-${(today.getMonth() + 1).toString().padStart(2, '0')}-${today.getDate()
      .toString()
      .padStart(2, '0')}`;
    if (dateStr === todayStr) {
      return '今天';
    }
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const yesterdayStr =
      `${yesterday.getFullYear()}-${(yesterday.getMonth() + 1).toString().padStart(2, '0')}-${yesterday.getDate()
        .toString()
        .padStart(2, '0')}`;
    if (dateStr === yesterdayStr) {
      return '昨天';
    }
    return dateStr;
  }

  /**
   * 获取当前月份
   */
  private getCurrentMonth(): string {
    const now = new Date();
    return `${now.getMonth() + 1}月`;
  }

  aboutToAppear() {
    this.loadBillData();
  }

  build() {
    HdsNavigation(this.pageInfos) {
      List({ space: 10 }) {
        // 安全区占位
        ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE)

        // Swiper 卡片区域
        ListItem() {
          this.SwiperSection()
        }

        // SectionHeader
        ListItem() {
          SectionHeaderComponent({
            title: this.getHeaderTitle(this.swiperIndex),
            action: '查看全部',
            onAction: () => this.navigateToSubPage(this.getHeaderRoute(this.swiperIndex)),
            themeState: this.themeState
          })
        }

        // 列表内容（带缩放动画）
        if (this.swiperIndex === 0) {
          this.BudgetListItems()
        } else if (this.swiperIndex === 1) {
          this.IncomeListItems()
        } else {
          this.AssetListItems()
        }
      }
      .width('100%')
      .height('100%')
      .contentEndOffset(this.winUtil.mainWindowInfo.navIndicatorHeight + CommonConstants.TAB_HEIGHT + 8)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .backgroundColor($r('app.color.start_window_background'))
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
              textColor: $r('app.color.text_secondary')
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
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }

  /**
   * Swiper 区域 - 使用 customContentTransition 实现拖拽实时动画
   */
  @Builder
  SwiperSection() {
    Column() {
      Swiper(this.swiperController) {
        this.BudgetCard()
        this.IncomeExpenseCard()
        this.AssetCard()
      }
      .prevMargin(6)
      .nextMargin(6)
      .index(this.swiperIndex)
      .autoPlay(false)
      .indicator(this.indicatorController)
      .itemSpace(16)
      .customContentTransition({
        timeout: 1000,
        transition: (proxy: SwiperContentTransitionProxy) => {
          const pageDistance: number = Math.abs(proxy.position);
          if (proxy.index === proxy.selectedIndex) {
            // 当前页面（正在被滑走）- 跟随手指倾斜，同时缩小变透明
            const progress = Math.min(pageDistance, 1);
            this.opacityList[proxy.index] = 1 - 0.5 * progress;
            this.scaleList[proxy.index] = 1 - (1 - MIN_SCALE) * progress;
            this.rotateList[proxy.index] = MAX_ROTATE * progress * (proxy.position < 0 ? -1 : 1);
            this.zIndexList[proxy.index] = 1;
          } else if (pageDistance < 1) {
            // 目标页面（正在滑入）- 从缩小恢复，从透明恢复
            const progress = 1 - pageDistance;
            this.opacityList[proxy.index] = 0.5 + 0.5 * progress;
            this.scaleList[proxy.index] = MIN_SCALE + (1 - MIN_SCALE) * progress;
            this.rotateList[proxy.index] = MAX_ROTATE * (1 - progress) * (proxy.position < 0 ? 1 : -1);
            this.zIndexList[proxy.index] = 0;
          } else {
            // 非当前页且非目标页 - 隐藏
            this.opacityList[proxy.index] = 0;
            this.scaleList[proxy.index] = MIN_SCALE;
            this.rotateList[proxy.index] = 0;
            this.zIndexList[proxy.index] = 0;
          }
        }
      })
      .onChange((index: number) => {
        this.swiperIndex = index;

        // 平滑重置卡片状态
        this.getUIContext().animateTo({
          duration: 300,
          curve: curves.springMotion(0.6, 0.9)
        }, () => {
          for (let i = 0; i < CARD_COUNT; i++) {
            this.opacityList[i] = 1;
            this.scaleList[i] = 1;
            this.rotateList[i] = 0;
            this.zIndexList[i] = 0;
          }
        });
      })

      // 自定义指示器
      IndicatorComponent(this.indicatorController)
        .initialIndex(0)
        .style(
          new DotIndicator()
            .itemWidth(8)
            .itemHeight(8)
            .selectedItemWidth(16)
            .selectedItemHeight(8)
            .color(this.themeState.compDivider)
            .selectedColor(this.themeState.brand))
        .loop(false)
        .count(CARD_COUNT)
    }
    .width('100%')
  }

  /**
   * 预算卡片
   */
  @Builder
  BudgetCard() {
    Column() {
      // 卡片头部
      Row() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.creditcard'))
            .fontSize(18)
            .fontColor(['#FFFFFF90'])
          Text('本月预算')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFFCC')
        }

        Text(this.getCurrentMonth())
          .fontSize(13)
          .fontColor('#FFFFFF60')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })

      // 预算金额
      Column() {
        Row({ space: 4 }) {
          Text('¥')
            .fontSize(18)
            .fontColor('#FFFFFF90')
          Text('2,580')
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .alignItems(VerticalAlign.Bottom)

        Text('总预算 ¥4,000')
          .fontSize(13)
          .fontColor('#FFFFFF60')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 进度条
      Column() {
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%')
            .height(8)
            .borderRadius(4)
            .backgroundColor('#FFFFFF15')
          Row()
            .width('65%')
            .height(8)
            .borderRadius(4)
            .backgroundColor('#FFFFFF')
        }
        .width('100%')

        Row() {
          Text('已使用 65%')
            .fontSize(12)
            .fontColor('#FFFFFF70')
          Text('剩余 ¥1,420')
            .fontSize(12)
            .fontColor('#FFFFFFA0')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 8 })
      }
      .width('100%')
      .padding({
        top: 16,
        bottom: 12,
        left: 24,
        right: 24
      })
    }
    .width('100%')
    .height(180)
    .padding(24)
    .margin({ left: 8, right: 8 })
    .borderRadius(20)
    .backgroundColor(this.themeState.brand)
    .opacity(this.opacityList[0])
    .scale({ x: this.scaleList[0], y: this.scaleList[0] })
    .rotate({ z: 1, angle: this.rotateList[0] })
    .zIndex(this.zIndexList[0])
  }

  /**
   * 收支卡片
   */
  @Builder
  IncomeExpenseCard() {
    Column() {
      // 卡片头部
      Row() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.arrow_left_arrow_right'))
            .fontSize(18)
            .fontColor(['#FFFFFF90'])
          Text('本月收支')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFFCC')
        }

        Text(this.getCurrentMonth())
          .fontSize(13)
          .fontColor('#FFFFFF60')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 24 })

      Row() {
        // 收入
        Column() {
          Row({ space: 6 }) {
            SymbolGlyph($r('sys.symbol.arrow_down'))
              .fontSize(12)
              .fontColor(['#6EE7B7'])
            Text('收入')
              .fontSize(13)
              .fontColor('#FFFFFF70')
          }
          .margin({ bottom: 8 })

          Row({ space: 2 }) {
            Text('¥')
              .fontSize(14)
              .fontColor('#FFFFFF90')
            Text('15,128')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .alignItems(VerticalAlign.Bottom)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 分隔线
        Column()
          .width(1)
          .height(50)
          .backgroundColor('#FFFFFF15')

        // 支出
        Column() {
          Row({ space: 6 }) {
            SymbolGlyph($r('sys.symbol.arrow_up'))
              .fontSize(12)
              .fontColor(['#FCA5A5'])
            Text('支出')
              .fontSize(13)
              .fontColor('#FFFFFF70')
          }
          .margin({ bottom: 8 })

          Row({ space: 2 }) {
            Text('¥')
              .fontSize(14)
              .fontColor('#FFFFFF90')
            Text('2,580')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .alignItems(VerticalAlign.Bottom)
        }
        .alignItems(HorizontalAlign.End)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 8 })
    }
    .width('100%')
    .height(180)
    .padding(24)
    .margin({ left: 8, right: 8 })
    .borderRadius(20)
    .backgroundColor(this.themeState.brand)
    .opacity(this.opacityList[1])
    .scale({ x: this.scaleList[1], y: this.scaleList[1] })
    .rotate({ z: 1, angle: this.rotateList[1] })
    .zIndex(this.zIndexList[1])
  }

  /**
   * 资产卡片
   */
  @Builder
  AssetCard() {
    Column() {
      // 卡片头部
      Row() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.creditcard'))
            .fontSize(18)
            .fontColor(['#FFFFFF90'])
          Text('总资产')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFFCC')
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      Row({ space: 4 }) {
        Text('¥')
          .fontSize(18)
          .fontColor('#FFFFFF90')
        Text('128,560')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .alignItems(VerticalAlign.Bottom)
      .margin({ bottom: 20 })

      Row() {
        this.AssetItem('现金', '¥15,600')
        this.AssetItem('银行卡', '¥89,200')
        this.AssetItem('其他', '¥23,760')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 4, right: 4 })
    }
    .width('100%')
    .height(180)
    .padding(24)
    .margin({ left: 8, right: 8 })
    .borderRadius(20)
    .backgroundColor(this.themeState.brand)
    .opacity(this.opacityList[2])
    .scale({ x: this.scaleList[2], y: this.scaleList[2] })
    .rotate({ z: 1, angle: this.rotateList[2] })
    .zIndex(this.zIndexList[2])
  }

  /**
   * 资产项目
   */
  @Builder
  AssetItem(label: string, amount: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#FFFFFF50')
      Text(amount)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFFB0')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 预算列表项（直接返回 ListItemGroup）
   */
  @Builder
  BudgetListItems() {
    if (this.billGroups.length === 0) {
      ListItem() {
        EmptyStateComponent({ text: '暂无预算支出记录', themeState: this.themeState })
      }
    } else {
      ForEach(this.billGroups, (group: BillGroup, groupIndex: number) => {
        if (group.totalExpense > 0) {
          ListItemGroup({
            header: GroupHeader(this.formatDateTitle(group.date), `-¥${group.totalExpense.toFixed(2)}`),
            style: ListItemGroupStyle.CARD
          }) {
            ForEach(group.bills.filter((b: BillBean) => b.type === BillTypeEnum.EXPENSE),
              (bill: BillBean, billIndex: number) => {
                ListItem() {
                  BillItemComponent({ bill: bill, themeState: this.themeState })
                }
                .opacity(1)
                .translate({ x: 0 })
                .animation({
                  duration: 300,
                  delay: (groupIndex * 3 + billIndex) * GRADIENT_DELAY,
                  curve: curves.springMotion(0.6, 0.9)
                })
                .swipeAction({
                  end: this.DeleteSwipeBuilder(bill.id)
                })
              })
          }
          .divider({
            strokeWidth: 0.5,
            color: this.themeState.compDivider,
            startMargin: 52,
            endMargin: 16
          })
        }
      })
    }
  }

  /**
   * 收支列表项（直接返回 ListItemGroup）
   */
  @Builder
  IncomeListItems() {
    if (this.billGroups.length === 0) {
      ListItem() {
        EmptyStateComponent({ text: '暂无收支记录', themeState: this.themeState })
      }
    } else {
      ForEach(this.billGroups, (group: BillGroup, groupIndex: number) => {
        ListItemGroup({
          header: GroupHeader(this.formatDateTitle(group.date), this.formatGroupSummary(group)),
          style: ListItemGroupStyle.CARD
        }) {
          ForEach(group.bills, (bill: BillBean, billIndex: number) => {
            ListItem() {
              BillItemComponent({ bill: bill, themeState: this.themeState })
            }
            .opacity(1)
            .translate({ x: 0 })
            .animation({
              duration: 300,
              delay: (groupIndex * 3 + billIndex) * GRADIENT_DELAY,
              curve: curves.springMotion(0.6, 0.9)
            })
            .swipeAction({
              end: this.DeleteSwipeBuilder(bill.id)
            })
           })
         }
         .divider({
           strokeWidth: 0.5,
           color: this.themeState.compDivider,
           startMargin: 52,
           endMargin: 16
         })
       })
     }
   }

   /**
    * 资产列表项（直接返回 ListItemGroup）
    */
  @Builder
  AssetListItems() {
    if (this.billGroups.length === 0) {
      ListItem() {
        EmptyStateComponent({ text: '暂无资产变动记录', themeState: this.themeState })
      }
    } else {
      ForEach(this.billGroups, (group: BillGroup, groupIndex: number) => {
        if (group.totalIncome > 0) {
          ListItemGroup({
            header: GroupHeader(this.formatDateTitle(group.date), `+¥${group.totalIncome.toFixed(2)}`),
            style: ListItemGroupStyle.CARD
          }) {
            ForEach(group.bills.filter((b: BillBean) => b.type === BillTypeEnum.INCOME),
              (bill: BillBean, billIndex: number) => {
                ListItem() {
                  BillItemComponent({ bill: bill, themeState: this.themeState })
                }
                .opacity(1)
                .translate({ x: 0 })
                .animation({
                  duration: 300,
                  delay: (groupIndex * 3 + billIndex) * GRADIENT_DELAY,
                  curve: curves.springMotion(0.6, 0.9)
                })
                .swipeAction({
                  end: this.DeleteSwipeBuilder(bill.id)
                })
               })
           }
           .divider({
             strokeWidth: 0.5,
             color: this.themeState.compDivider,
             startMargin: 52,
             endMargin: 16
           })
         }
       })
     }
   }

  /**
   * 格式化分组摘要
   */
  private formatGroupSummary(group: BillGroup): string {
    const parts: string[] = [];
    if (group.totalIncome > 0) {
      parts.push(`收 ¥${group.totalIncome.toFixed(2)}`);
    }
    if (group.totalExpense > 0) {
      parts.push(`支 ¥${group.totalExpense.toFixed(2)}`);
    }
    return parts.join(' ');
  }


}
