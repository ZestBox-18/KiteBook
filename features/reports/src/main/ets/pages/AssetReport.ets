import { AccountBean, AccountManager, AppThemeState } from 'base';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct AssetReport {
  @Param refreshToken: number = 0;
  @Local accountList: AccountBean[] = [];
  @Local totalAsset: number = 0;
  @Local totalLiability: number = 0;
  @Local netAsset: number = 0;
  @Local loading: boolean = false;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;

  aboutToAppear(): void {
    this.loadReportData();
  }

  @Monitor('refreshToken')
  onRefreshTokenChanged(): void {
    this.loadReportData();
  }

  build() {
    Column() {
      this.SummaryCard();
      this.AccountList();
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  SummaryCard() {
    Column() {
      Row() {
        Column() {
          Text('总资产').fontSize(12).fontColor(this.themeState.fontSecondary)
          Text('¥' + this.formatAmount(this.totalAsset))
            .fontSize(18).fontColor(this.themeState.brand).fontWeight(FontWeight.Bold).margin({ top: 4 })
        }.layoutWeight(1)
        Divider().vertical(true).height(40).color(this.themeState.compDivider)
        Column() {
          Text('总负债').fontSize(12).fontColor(this.themeState.fontSecondary)
          Text('¥' + this.formatAmount(this.totalLiability))
            .fontSize(18).fontColor('#F97316').fontWeight(FontWeight.Bold).margin({ top: 4 })
        }.layoutWeight(1)
        Divider().vertical(true).height(40).color(this.themeState.compDivider)
        Column() {
          Text('净资产').fontSize(12).fontColor(this.themeState.fontSecondary)
          Text('¥' + this.formatAmount(this.netAsset))
            .fontSize(18).fontColor('#4CAF50').fontWeight(FontWeight.Bold).margin({ top: 4 })
        }.layoutWeight(1)
      }.width('100%').padding(16)
    }
    .width('100%')
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(8)
    .border({ width: 1, color: this.themeState.compDivider })
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  @Builder
  AccountList() {
    Column() {
      Text('账户快照').fontSize(16).fontColor(this.themeState.fontPrimary).fontWeight(FontWeight.Medium).width('100%').margin({ bottom: 12 })
      if (this.accountList.length > 0) {
        List() {
          ForEach(this.accountList, (item: AccountBean) => {
            ListItem() {
              Row() {
                SymbolGlyph(item.getIconResource())
                  .fontSize(20)
                  .fontColor([item.isLiability() ? '#F97316' : this.themeState.brand])
                  .width(28)

                Column() {
                  Text(item.name).fontSize(14).fontColor(this.themeState.fontPrimary).fontWeight(FontWeight.Medium)
                  Text(item.isLiability() ? '负债账户' : '资产账户')
                    .fontSize(12)
                    .fontColor(this.themeState.fontSecondary)
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 8 })

                Text('¥' + this.formatAmount(item.balance))
                  .fontSize(14)
                  .fontColor(item.isLiability() ? '#F97316' : this.themeState.fontPrimary)
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
            }
          }, (item: AccountBean) => `${item.id}`)
        }.width('100%').layoutWeight(1).divider({ strokeWidth: 1, color: this.themeState.compDivider, startMargin: 44, endMargin: 16 })
      } else {
        Column() {
          Text(this.loading ? '正在读取账户数据...' : '当前还没有账户数据').fontSize(14).fontColor(this.themeState.fontSecondary)
        }
        .width('100%')
        .height(180)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeState.compBackgroundPrimary)
        .borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(8)
    .border({ width: 1, color: this.themeState.compDivider })
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  private async loadReportData(): Promise<void> {
    this.loading = true;
    try {
      const accounts: AccountBean[] = await AccountManager.getAccounts();
      this.accountList = accounts;
      this.totalAsset = 0;
      this.totalLiability = 0;
      accounts.forEach((item: AccountBean) => {
        if (item.isLiability()) {
          this.totalLiability += item.balance;
        } else {
          this.totalAsset += item.balance;
        }
      });
      this.netAsset = this.totalAsset - this.totalLiability;
    } finally {
      this.loading = false;
    }
  }

  private formatAmount(amount: number): string {
    if (amount >= 10000) return (amount / 10000).toFixed(2) + '万';
    return amount.toFixed(2);
  }
}
