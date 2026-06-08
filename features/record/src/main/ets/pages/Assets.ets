/**
 * Copyright (C), 2026-04-01
 * @author ZestBox
 * @date 2026-04-01 
 * @version 1.0
 * @description: 资产管理页面
 */
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from "@kit.UIDesignKit";
import {
  AccountBean,
  AccountTypeEnum,
  AppThemeState,
  billSyncController,
  CommonConstants,
  GroupHeader,
  SystemOptions,
  mainTabController
} from 'base';
import { AccountManager } from 'data_core';
import { AppStorageV2, LengthMetrics, PersistenceV2 } from '@kit.ArkUI';
import { WindowUtil, Clog } from 'kite_utils';

@ComponentV2
export struct Assets {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local accountList: AccountBean[] = [];
  @Local accountNameText: string = '';
  @Local accountBalanceText: string = '';
  @Local accountType: string = AccountTypeEnum.ASSET;
  @Local editingAccountId: number = 0
  @Local saving: boolean = false

  aboutToAppear(): void {
    this.loadAccounts();
  }

  /**
   * 加载全部账户数据，供资产管理页和列表展示复用。
   */
  private async loadAccounts(): Promise<void> {
    try {
      this.accountList = await AccountManager.getAccounts();
    } catch (err) {
      Clog.error('[Assets]', '加载账户失败', err);
      this.showToast('账户加载失败');
    }
  }

  /**
   * 校验新增账户表单，返回可提交的余额数值。
   */
  private validateAccountForm(): number {
    const name: string = this.accountNameText.trim();
    if (name.length === 0) {
      this.showToast('请输入账户名称');
      return -1;
    }
    const duplicated: boolean =
      this.accountList.some((item: AccountBean) => item.name === name && item.id !== this.editingAccountId);
    if (duplicated) {
      this.showToast('账户名称已存在');
      return -1;
    }
    const balance: number = Number(this.accountBalanceText);
    if (!Number.isFinite(balance) || balance < 0) {
      this.showToast('请输入正确的账户余额');
      return -1;
    }
    return balance;
  }

  /**
   * 根据账户类型返回默认图标标识，避免新增时缺少图标字段。
   */
  private getDefaultIconByType(): string {
    if (this.accountType === AccountTypeEnum.LIABILITY) {
      return 'arrow_up_circle';
    }
    return 'creditcard';
  }

  /**
   * 当前是否处于编辑账户状态。
   */
  private isEditingAccount(): boolean {
    return this.editingAccountId > 0;
  }

  /**
   * 将账户数据回填到表单，便于直接编辑。
   */
  private startEditingAccount(account: AccountBean): void {
    this.editingAccountId = account.id;
    this.accountNameText = account.name;
    this.accountBalanceText = account.balance.toFixed(2);
    this.accountType = account.type;
  }

  /**
   * 重置账户表单，回到新增模式。
   */
  private resetAccountForm(): void {
    this.editingAccountId = 0;
    this.accountNameText = '';
    this.accountBalanceText = '';
    this.accountType = AccountTypeEnum.ASSET;
  }

  /**
   * 提交新增账户，并刷新列表让首页与记账页读取同一份数据。
   */
  private async submitAccount(): Promise<void> {
    if (this.saving) {
      return;
    }
    const balance: number = this.validateAccountForm();
    if (balance < 0) {
      return;
    }

    this.saving = true;
    const editingMode: boolean = this.isEditingAccount();
    try {
      if (editingMode) {
        await AccountManager.updateAccount(
          this.editingAccountId,
          this.accountNameText.trim(),
          balance,
          this.accountType,
          this.getDefaultIconByType()
        );
      } else {
        await AccountManager.addAccount(
          this.accountNameText.trim(),
          balance,
          this.accountType,
          this.getDefaultIconByType()
        );
      }
      this.resetAccountForm();
      await this.loadAccounts();
      billSyncController.notifyBillChanged();
      this.showToast(editingMode ? '账户已更新' : '已添加账户');
    } catch (err) {
      Clog.error('[Assets]', editingMode ? '更新账户失败' : '新增账户失败', err);
      this.showToast(editingMode ? '更新失败，请稍后重试' : '添加失败，请稍后重试');
    } finally {
      this.saving = false;
    }
  }

  /**
   * 删除当前编辑中的账户；若账单仍引用该账户则阻止删除。
   */
  private async deleteEditingAccount(): Promise<void> {
    if (!this.isEditingAccount() || this.saving) {
      return;
    }
    this.saving = true;
    try {
      const result: number = await AccountManager.deleteAccount(this.editingAccountId);
      if (result === -2) {
        this.showToast('该账户已被账单引用，暂不能删除');
        return;
      }
      if (result <= 0) {
        this.showToast('删除失败，请稍后重试');
        return;
      }
      this.resetAccountForm();
      await this.loadAccounts();
      billSyncController.notifyBillChanged();
      this.showToast('账户已删除');
    } catch (err) {
      Clog.error('[Assets]', '删除账户失败', err);
      this.showToast('删除失败，请稍后重试');
    } finally {
      this.saving = false;
    }
  }

  /**
   * 返回账户数量说明文案。
   */
  private getAccountCountText(): string {
    return `${this.accountList.length} 个账户`;
  }

  /**
   * 将账户余额格式化为带千分位的金额文案。
   */
  private formatAmount(amount: number): string {
    const fixed: string = amount.toFixed(2);
    const parts: string[] = fixed.split('.');
    const integerPart: string = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    return `¥${integerPart}.${parts[1]}`;
  }

  /**
   * 返回账户类型对应的标签文字。
   */
  private getAccountTypeText(account: AccountBean): string {
    return account.isLiability() ? '负债' : '资产';
  }

  /**
   * 返回账户金额颜色，负债账户保持橙色强调。
   */
  private getAccountAmountColor(account: AccountBean): ResourceColor {
    if (account.isLiability()) {
      return '#F97316';
    }
    return this.themeState.fontPrimary as ResourceColor;
  }

  /**
   * 统一弹出提示文案。
   */
  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 1800
      });
    } catch {
    }
  }

  @Builder
  private AccountTypeSelector(label: string, type: string) {
    Button(label)
      .height(34)
      .padding({ left: 14, right: 14 })
      .backgroundColor(this.accountType === type ? this.themeState.brand as ResourceColor :
        this.themeState.backgroundPrimary)
      .fontColor(this.accountType === type ? this.themeState.fontOnPrimary : this.themeState.fontPrimary)
      .fontWeight(this.accountType === type ? FontWeight.Bold : FontWeight.Medium)
      .borderRadius(17)
      .border({
        width: 1,
        color: this.accountType === type ? this.themeState.brand as ResourceColor : this.themeState.compDivider
      })
      .stateEffect(false)
      .onClick(() => {
        this.accountType = type;
      })
  }

  @Builder
  private AccountCreateSection() {
    ListItemGroup({
      header: GroupHeader(this.isEditingAccount() ? '编辑账户' : '新增账户',
        this.isEditingAccount() ? '修改后会同步历史账单中的账户名称' : '保存后记账页可直接选择'),
      style: ListItemGroupStyle.CARD
    }) {
      ListItem() {
        Column({ space: 12 }) {
          TextInput({ text: this.accountNameText, placeholder: '账户名称，例如：招商银行卡' })
            .width('100%')
            .height(44)
            .fontSize(15)
            .fontColor(this.themeState.fontPrimary)
            .backgroundColor(this.themeState.backgroundPrimary)
            .borderRadius(12)
            .padding({ left: 12, right: 12 })
            .onChange((value: string) => {
              this.accountNameText = value;
            })

          TextInput({ text: this.accountBalanceText, placeholder: '账户余额，例如：1000.00' })
            .width('100%')
            .height(44)
            .fontSize(15)
            .fontColor(this.themeState.fontPrimary)
            .backgroundColor(this.themeState.backgroundPrimary)
            .borderRadius(12)
            .padding({ left: 12, right: 12 })
            .type(InputType.Number)
            .onChange((value: string) => {
              this.accountBalanceText = value;
            })

          Row({ space: 10 }) {
            this.AccountTypeSelector('资产账户', AccountTypeEnum.ASSET)
            this.AccountTypeSelector('负债账户', AccountTypeEnum.LIABILITY)
          }
          .width('100%')

          if (this.isEditingAccount()) {
            Row({ space: 10 }) {
              Button('取消编辑')
                .layoutWeight(1)
                .height(46)
                .backgroundColor(this.themeState.backgroundPrimary)
                .fontColor(this.themeState.fontPrimary)
                .fontWeight(FontWeight.Medium)
                .borderRadius(14)
                .border({ width: 1, color: this.themeState.compDivider })
                .enabled(!this.saving)
                .stateEffect(false)
                .onClick(() => {
                  this.resetAccountForm();
                })

              Button(this.saving ? '保存中...' : '保存修改')
                .layoutWeight(1)
                .height(46)
                .backgroundColor(this.themeState.brand as ResourceColor)
                .fontColor(this.themeState.fontOnPrimary)
                .fontWeight(FontWeight.Bold)
                .borderRadius(14)
                .enabled(!this.saving)
                .stateEffect(false)
                .onClick(() => {
                  this.submitAccount();
                })
            }
            .width('100%')

            Button(this.saving ? '处理中...' : '删除当前账户')
              .width('100%')
              .height(42)
              .backgroundColor('#FFF1F2')
              .fontColor('#DC2626')
              .fontWeight(FontWeight.Medium)
              .borderRadius(14)
              .enabled(!this.saving)
              .stateEffect(false)
              .onClick(() => {
                this.deleteEditingAccount();
              })
          } else {
            Button(this.saving ? '保存中...' : '添加账户')
              .width('100%')
              .height(46)
              .backgroundColor(this.themeState.brand as ResourceColor)
              .fontColor(this.themeState.fontOnPrimary)
              .fontWeight(FontWeight.Bold)
              .borderRadius(14)
              .enabled(!this.saving)
              .stateEffect(false)
              .onClick(() => {
                this.submitAccount();
              })
          }
        }
        .width('100%')
        .padding(16)
      }
    }
  }

  @Builder
  private AccountListSection() {
    if (this.accountList.length === 0) {
      ListItemGroup({
        header: GroupHeader('账户列表', '暂无账户'),
        style: ListItemGroupStyle.CARD
      }) {
        ListItem() {
          Text('还没有资产账户，先添加一个账户吧')
            .fontSize(14)
            .fontColor(this.themeState.fontSecondary)
            .width('100%')
            .padding(16)
        }
      }
    } else {
      ListItemGroup({
        header: GroupHeader('账户列表', this.getAccountCountText()),
        style: ListItemGroupStyle.CARD
      }) {
        ForEach(this.accountList, (item: AccountBean) => {
          ListItem() {
            Row() {
              SymbolGlyph(item.getIconResource())
                .fontSize(20)
                .fontWeight(this.optionSystem.iconThickness)
                .fontColor([item.isLiability() ? '#F97316' : this.themeState.brand as ResourceColor])
                .width(36)
                .height(36)
                .borderRadius(8)
                .backgroundColor(item.isLiability() ? '#FFF7ED' : '#EEF6FF')
                .padding(8)

              Column() {
                Text(item.name)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeState.fontPrimary)
                Text(`${this.getAccountTypeText(item)} · ${item.getSubtitleText()}`)
                  .fontSize(13)
                  .fontColor(this.themeState.fontSecondary)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
              .layoutWeight(1)

              Text(this.formatAmount(item.balance))
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getAccountAmountColor(item))
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.themeState.compBackgroundPrimary)
            .onClick(() => {
              this.startEditingAccount(item);
            })
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
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)
          this.AccountCreateSection()
          this.AccountListSection()
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 16 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
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
          mainTitle: '管理资产',
          subTitle: '新增和维护账户'
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
}
