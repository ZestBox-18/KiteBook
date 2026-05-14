/**
 * Copyright (C), 2026-05-14
 * @author ZestBox
 * @date 2026/05/14
 * @version 1.0
 * @description: 测试页面 - 用于插入测试数据
 */

import { CommonConstants, RouterUrlConstants, mainTabController, AppThemeState, SystemOptions, BillManager, BillBean, BillTypeEnum } from 'base';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { WindowUtil, Clog, dbManager } from 'kite_utils';
import { promptAction } from '@kit.ArkUI';

const TAG: string = '[TestPage]';

@ComponentV2
export struct TestPage {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!
  @Local isInserting: boolean = false

  /**
   * 插入示例数据
   */
  private async insertSampleData(): Promise<void> {
    if (this.isInserting) return;
    this.isInserting = true;

    try {
      Clog.info(TAG, '开始插入示例数据...');
      Clog.info(TAG, `数据库状态: ${dbManager.dbStore ? '已初始化' : '未初始化'}`);

      // 逐条插入，便于定位问题
      const now = new Date();
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

      const bills: BillBean[] = [
        this.createBill(BillTypeEnum.EXPENSE, '餐饮', 35.00, '微信', today.getTime() + 12 * 60 * 60 * 1000, '午餐'),
        this.createBill(BillTypeEnum.EXPENSE, '交通', 6.00, '支付宝', today.getTime() + 9 * 60 * 60 * 1000, '地铁'),
        this.createBill(BillTypeEnum.INCOME, '工资', 15000.00, '银行卡', today.getTime() + 10 * 60 * 60 * 1000, '5月工资'),
        this.createBill(BillTypeEnum.EXPENSE, '购物', 299.00, '支付宝', today.getTime() - 24 * 60 * 60 * 1000 + 15 * 60 * 60 * 1000, '买衣服'),
        this.createBill(BillTypeEnum.EXPENSE, '餐饮', 88.00, '微信', today.getTime() - 24 * 60 * 60 * 1000 + 19 * 60 * 60 * 1000, '晚餐聚餐'),
        this.createBill(BillTypeEnum.EXPENSE, '娱乐', 50.00, '微信', today.getTime() - 2 * 24 * 60 * 60 * 1000 + 20 * 60 * 60 * 1000, '电影票'),
        this.createBill(BillTypeEnum.EXPENSE, '餐饮', 42.00, '支付宝', today.getTime() - 2 * 24 * 60 * 60 * 1000 + 12 * 60 * 60 * 1000, '午餐外卖'),
        this.createBill(BillTypeEnum.INCOME, '理财', 128.50, '银行卡', today.getTime() - 2 * 24 * 60 * 60 * 1000 + 9 * 60 * 60 * 1000, '基金收益'),
      ];

      let successCount = 0;
      for (const bill of bills) {
        try {
          const id = await BillManager.addBill(bill);
          Clog.info(TAG, `插入成功: ${bill.category} ${bill.amount}, id=${id}`);
          successCount++;
        } catch (err) {
          Clog.error(TAG, `插入失败: ${bill.category} ${bill.amount}`, err);
        }
      }

      if (successCount > 0) {
        promptAction.showToast({ message: `成功插入 ${successCount} 条数据` });
      } else {
        promptAction.showToast({ message: '插入失败，请检查数据库' });
      }
    } catch (err) {
      Clog.error(TAG, '插入示例数据失败', err);
      promptAction.showToast({ message: '插入失败' });
    } finally {
      this.isInserting = false;
    }
  }

  private createBill(type: string, category: string, amount: number, account: string, date: number, remark: string): BillBean {
    const bill = new BillBean();
    bill.type = type;
    bill.category = category;
    bill.amount = amount;
    bill.account = account;
    bill.date = date;
    bill.remark = remark;
    return bill;
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          // 数据操作
          ListItemGroup({
            header: this.itemHead('数据操作'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Button('插入示例数据')
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontWeight(this.optionSystem.fontThickness)
                .backgroundColor(this.themeState.brand)
                .borderRadius(12)
                .onClick(() => {
                  this.insertSampleData();
                })
                .enabled(!this.isInserting)
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          }

          // 说明
          ListItem() {
            Column({ space: 8 }) {
              Text('说明')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeState.fontPrimary)

              Text('点击上方按钮可插入8条示例账单数据，包含今天、昨天、前天的收支记录。')
                .fontSize(14)
                .fontColor(this.themeState.fontSecondary)
                .lineHeight(20)

              Text('插入后返回首页即可看到数据变化。')
                .fontSize(14)
                .fontColor(this.themeState.fontSecondary)
                .lineHeight(20)
            }
            .width('100%')
            .padding(16)
            .alignItems(HorizontalAlign.Start)
            .borderRadius(12)
            .backgroundColor(this.themeState.compBackgroundPrimary)
          }
          .padding({ left: 16, right: 16 })
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
      content: { title: { mainTitle: "测试工具" } },
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
  itemHead(title: string) {
    Text(title)
      .fontSize(13)
      .fontWeight(FontWeight.Normal)
      .fontColor(this.themeState.fontSecondary)
      .padding({ left: 16, top: 8, bottom: 8 })
  }
}
