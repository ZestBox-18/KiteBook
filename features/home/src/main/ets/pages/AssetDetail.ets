/**
 * Copyright (C), 2026-06-17
 * @author ZestBox
 * @date 2026/06/17
 * @version 1.0
 * @description: 首页资产详情页
 */

import { hdsMaterial, HdsAnimationMode, HdsNavDestination, ScrollEffectType } from '@kit.UIDesignKit';
import {
  AccountBean,
  AppThemeState,
  BillBean,
  BillTypeEnum,
  CommonConstants,
  RouterUrlConstants,
  mainTabController
} from 'base';
import { AccountManager, BillManager } from 'data_core';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { Clog, WindowUtil } from 'kite_utils';

const TAG: string = '[AssetDetail]';
const LOOKBACK_DAYS: number = 120;

@ComponentV2
export struct AssetDetail {
  @Param accountId: number = 0;

  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local accountList: AccountBean[] = [];
  @Local recentBills: BillBean[] = [];
  @Local titleText: string = '资产详情';
  @Local subtitleText: string = '账户与最近资产变动';
  @Local totalAssets: number = 0;
  @Local totalLiabilities: number = 0;
  @Local netAssets: number = 0;
  @Local selectedAccountName: string = '';

  aboutToAppear(): void {
    this.loadPageData();
  }

  private async loadPageData(): Promise<void> {
    try {
      const accounts: AccountBean[] = await AccountManager.getAccounts();
      this.accountList = accounts;
      this.updateSummary(accounts);
      this.updateCurrentAccount(accounts);
      await this.loadRecentBills();
    } catch (err) {
      Clog.error(TAG, '加载资产详情失败', err);
    }
  }

  private updateSummary(accounts: AccountBean[]): void {
    let assets: number = 0;
    let liabilities: number = 0;
    accounts.forEach((account: AccountBean) => {
      if (account.isLiability()) {
        liabilities += account.balance;
      } else {
        assets += account.balance;
      }
    });
    this.totalAssets = assets;
    this.totalLiabilities = liabilities;
    this.netAssets = assets - liabilities;
  }

  private updateCurrentAccount(accounts: AccountBean[]): void {
    if (this.accountId <= 0) {
      this.selectedAccountName = '';
      this.titleText = '资产详情';
      this.subtitleText = `${accounts.length} 个账户`;
      return;
    }
    const matchedAccount: AccountBean | undefined = accounts.find((item: AccountBean) => item.id === this.accountId);
    if (matchedAccount) {
      this.selectedAccountName = matchedAccount.name;
      this.titleText = matchedAccount.name;
      this.subtitleText = matchedAccount.isLiability() ? '负债账户明细' : '资产账户明细';
      return;
    }
    this.selectedAccountName = '';
    this.titleText = '资产详情';
    this.subtitleText = `${accounts.length} 个账户`;
  }

  private async loadRecentBills(): Promise<void> {
    const endTime: number = Date.now();
    const startTime: number = endTime - LOOKBACK_DAYS * 24 * 60 * 60 * 1000;
    const bills: BillBean[] = await BillManager.getBillsByRange(startTime, endTime, '');
    const filteredBills: BillBean[] = bills.filter((bill: BillBean) => this.isAssetBillMatched(bill));
    this.recentBills = filteredBills.slice(0, 20);
  }

  private isAssetBillMatched(bill: BillBean): boolean {
    if (this.selectedAccountName.length === 0) {
      return bill.account.length > 0 || bill.targetAccount.length > 0;
    }
    return bill.account === this.selectedAccountName || bill.targetAccount === this.selectedAccountName;
  }

  private getSummaryAmountText(amount: number): string {
    const prefix: string = amount < 0 ? '-' : '';
    const absoluteAmount: number = Math.abs(amount);
    const fixed: string = absoluteAmount.toFixed(2);
    const parts: string[] = fixed.split('.');
    const integerPart: string = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    return `${prefix}¥${integerPart}.${parts[1]}`;
  }

  private getBillTintColor(bill: BillBean): ResourceColor {
    if (bill.type === BillTypeEnum.INCOME) {
      return '#10B981';
    }
    if (bill.type === BillTypeEnum.TRANSFER) {
      return this.themeState.brand as ResourceColor;
    }
    return '#E55454';
  }

  private getBillBgColor(bill: BillBean): ResourceColor {
    if (bill.type === BillTypeEnum.INCOME) {
      return '#D1FAE5';
    }
    if (bill.type === BillTypeEnum.TRANSFER) {
      return '#DBEAFE';
    }
    return '#FEE2E2';
  }

  private navigateToAssetManage(): void {
    this.pageInfos.pushPath({ name: RouterUrlConstants.ASSETS });
  }

  build() {
    HdsNavDestination() {
      List({ space: 10 }) {
        ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

        ListItem() {
          Column({ space: 14 }) {
            Row() {
              Column({ space: 6 }) {
                Text('净资产')
                  .fontSize(13)
                  .fontColor(this.themeState.fontSecondary)
                Text(this.getSummaryAmountText(this.netAssets))
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeState.fontPrimary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Button('管理账户')
                .height(34)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeState.brand)
                .backgroundColor(this.themeState.backgroundPrimary)
                .borderRadius(17)
                .border({ width: 1, color: this.themeState.compDivider })
                .onClick(() => {
                  this.navigateToAssetManage();
                })
            }
            .width('100%')

            Row() {
              this.SummaryMetric('总资产', this.getSummaryAmountText(this.totalAssets), '#10B981')
              this.SummaryDivider()
              this.SummaryMetric('总负债', this.getSummaryAmountText(this.totalLiabilities), '#F97316')
            }
            .width('100%')
          }
          .width('100%')
          .padding(18)
        }
        .backgroundColor(this.themeState.compBackgroundPrimary)
        .borderRadius(22)

        if (this.accountList.length > 0) {
          ListItemGroup({
            header: this.SectionHeader('账户列表', `${this.accountList.length} 个账户`),
            style: ListItemGroupStyle.CARD
          }) {
            ForEach(this.accountList, (item: AccountBean) => {
              ListItem() {
                this.AccountRow(item)
              }
            }, (item: AccountBean) => `${item.id}`)
          }
          .divider({
            strokeWidth: 0.5,
            color: this.themeState.compDivider,
            startMargin: 52,
            endMargin: 16
          })
        }

        ListItemGroup({
          header: this.SectionHeader('最近变动', this.selectedAccountName.length > 0 ? this.selectedAccountName : '全部账户'),
          style: ListItemGroupStyle.CARD
        }) {
          if (this.recentBills.length === 0) {
            ListItem() {
              Text('最近没有关联到账户变动的账单')
                .fontSize(14)
                .fontColor(this.themeState.fontSecondary)
                .width('100%')
                .padding(16)
            }
          } else {
            ForEach(this.recentBills, (bill: BillBean) => {
              ListItem() {
                this.BillRow(bill)
              }
            }, (bill: BillBean) => `${bill.id}`)
          }
        }
        .divider({
          strokeWidth: 0.5,
          color: this.themeState.compDivider,
          startMargin: 52,
          endMargin: 16
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('[shared_assets].color.start_window_background'))
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .contentEndOffset(this.winUtil.mainWindowInfo.navIndicatorHeight + 16)
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
        }
      },
      content: {
        title: {
          mainTitle: this.titleText,
          subTitle: this.subtitleText
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
  private SectionHeader(title: string, subtitle: string) {
    Row() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontPrimary)
      Text(subtitle)
        .fontSize(12)
        .fontColor(this.themeState.fontSecondary)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
  }

  @Builder
  private SummaryMetric(title: string, value: string, color: ResourceColor) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Text(value)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
  }

  @Builder
  private SummaryDivider() {
    Column()
      .width(1)
      .height(40)
      .backgroundColor(this.themeState.compDivider)
      .margin({ left: 12, right: 12 })
  }

  @Builder
  private AccountRow(account: AccountBean) {
    Row({ space: 12 }) {
      SymbolGlyph(account.getIconResource())
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor([account.isLiability() ? '#F97316' : this.themeState.brand as ResourceColor])
        .width(36)
        .height(36)
        .borderRadius(8)
        .backgroundColor(account.isLiability() ? '#FFF7ED' : '#EEF6FF')
        .padding(8)

      Column({ space: 2 }) {
        Text(account.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
        Text(account.getSubtitleText())
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.getSummaryAmountText(account.balance))
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(account.isLiability() ? '#F97316' : this.themeState.fontPrimary)
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }

  @Builder
  private BillRow(bill: BillBean) {
    Row({ space: 12 }) {
      SymbolGlyph(bill.getCategoryIcon())
        .fontSize(20)
        .fontColor([this.getBillTintColor(bill)])
        .width(36)
        .height(36)
        .borderRadius(8)
        .backgroundColor(this.getBillBgColor(bill))
        .padding(8)

      Column({ space: 2 }) {
        Text(bill.category)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
        Text(bill.getAccountDisplayText())
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column({ space: 2 }) {
        Text(bill.formatAmount())
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getBillTintColor(bill))
        Text(bill.getDateString())
          .fontSize(12)
          .fontColor(this.themeState.fontSecondary)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }
}
