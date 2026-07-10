/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 数据导出页面
 */

import {
  AccountBean,
  AppThemeState,
  BillBean,
  BillTypeEnum,
  BudgetBean,
  billSyncController,
  CategoryBean,
  CommonConstants,
  GroupHeader,
  SystemOptions,
  mainTabController
} from 'base';
import { AccountManager, BillManager, BudgetManager, CategoryManager } from 'data_core';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, HdsAnimationMode } from '@kit.UIDesignKit';
import { WindowUtil, dbManager } from 'kite_utils';
import { UserProfile } from '../entities/UserProfile';
import { common } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';

const DAY_MS: number = 24 * 60 * 60 * 1000;
const LATEST_JSON_BACKUP_FILE_NAME: string = 'kitebook_backup_latest.json';

class BackupPayload {
  exportedAt: number = 0;
  exportRange: string = '';
  billCount: number = 0;
  accountCount: number = 0;
  categoryCount: number = 0;
  budgetCount: number = 0;
  bills: BillBean[] = [];
  accounts: AccountBean[] = [];
  categories: CategoryBean[] = [];
  budgets: BudgetBean[] = [];
  settings: SystemOptions = new SystemOptions();
  userProfile: UserProfile = new UserProfile();
}

class ExportRangeInfo {
  startTime: number = 0;
  endTime: number = 0;
  yearPrefix: string = '';
  monthKey: string = '';
  label: string = '';

  constructor(startTime: number, endTime: number, yearPrefix: string, monthKey: string, label: string) {
    this.startTime = startTime;
    this.endTime = endTime;
    this.yearPrefix = yearPrefix;
    this.monthKey = monthKey;
    this.label = label;
  }
}

@ComponentV2
export struct DataExport {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  @Local userProfile: UserProfile =
    PersistenceV2.connect(UserProfile, 'UserProfile', () => new UserProfile())!
  @Local exporting: boolean = false
  @Local exportFormat: string = 'csv'
  @Local exportRange: string = 'all'
  @Local lastExportPath: string = ''
  @Local lastExportSummary: string = ''
  @Local importing: boolean = false
  @Local latestBackupPath: string = ''
  @Local latestBackupAvailable: boolean = false
  @Local lastImportSummary: string = ''
  // 主题颜色
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!

  private getAbilityContext(): common.UIAbilityContext | null {
    const hostContext = this.getUIContext().getHostContext()
    if (!hostContext) {
      return null
    }
    return hostContext as common.UIAbilityContext
  }

  aboutToAppear(): void {
    this.refreshLatestBackupState();
  }

  private buildRangeInfo(): ExportRangeInfo {
    if (this.exportRange === 'month') {
      const now: Date = new Date();
      const monthStart: number = new Date(now.getFullYear(), now.getMonth(), 1).getTime();
      const monthEnd: number = new Date(now.getFullYear(), now.getMonth() + 1, 1).getTime();
      const monthKey: string = BudgetManager.buildMonthKey(monthStart);
      return new ExportRangeInfo(monthStart, monthEnd, `${now.getFullYear()}`, monthKey, '本月数据');
    }
    if (this.exportRange === 'year') {
      const now: Date = new Date();
      const yearStart: number = new Date(now.getFullYear(), 0, 1).getTime();
      const yearEnd: number = new Date(now.getFullYear() + 1, 0, 1).getTime();
      return new ExportRangeInfo(yearStart, yearEnd, `${now.getFullYear()}`, '', '今年数据');
    }
    return new ExportRangeInfo(0, Date.now() + DAY_MS, '', '', '全部数据');
  }

  private filterBudgetsByRange(budgets: BudgetBean[], rangeInfo: ExportRangeInfo): BudgetBean[] {
    if (this.exportRange === 'month') {
      return budgets.filter((item: BudgetBean) => item.month === rangeInfo.monthKey);
    }
    if (this.exportRange === 'year') {
      return budgets.filter((item: BudgetBean) => item.month.startsWith(rangeInfo.yearPrefix));
    }
    return budgets;
  }

  private buildExportFileName(extension: string): string {
    const now: Date = new Date();
    const timestamp: string =
      `${now.getFullYear()}${(now.getMonth() + 1).toString().padStart(2, '0')}${now.getDate()
        .toString()
        .padStart(2, '0')}_${now.getHours().toString().padStart(2, '0')}${now.getMinutes()
        .toString()
        .padStart(2, '0')}${now.getSeconds().toString().padStart(2, '0')}`;
    return `kitebook_export_${timestamp}.${extension}`;
  }

  private ensureExportDir(): string {
    const context = this.getAbilityContext()
    if (!context) {
      return ''
    }
    const exportDir: string = `${context.filesDir}/exports`;
    try {
      fs.statSync(exportDir);
    } catch {
      fs.mkdirSync(exportDir);
    }
    return exportDir;
  }

  private getLatestJsonBackupPath(): string {
    const exportDir: string = this.ensureExportDir()
    if (exportDir.length === 0) {
      return ''
    }
    return `${exportDir}/${LATEST_JSON_BACKUP_FILE_NAME}`;
  }

  private refreshLatestBackupState(): void {
    const latestBackupPath: string = this.getLatestJsonBackupPath();
    if (latestBackupPath.length === 0) {
      this.latestBackupAvailable = false;
      this.latestBackupPath = '';
      return;
    }
    try {
      fs.statSync(latestBackupPath);
      this.latestBackupAvailable = true;
      this.latestBackupPath = latestBackupPath;
    } catch {
      this.latestBackupAvailable = false;
      this.latestBackupPath = '';
    }
  }

  private writeExportFile(fileName: string, content: string): string {
    const exportDir: string = this.ensureExportDir();
    if (exportDir.length === 0) {
      throw new Error('export dir unavailable');
    }
    const filePath: string = `${exportDir}/${fileName}`;
    const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, content, { offset: 0, encoding: 'utf-8' });
    fs.closeSync(file);
    return filePath;
  }

  private writeLatestJsonBackup(content: string): string {
    return this.writeExportFile(LATEST_JSON_BACKUP_FILE_NAME, content);
  }

  private escapeCsvValue(value: string): string {
    const escaped: string = value.replace(/"/g, '""');
    return `"${escaped}"`;
  }

  private buildCsvContent(bills: BillBean[]): string {
    const header: string = 'id,type,category,amount,account,targetAccount,date,remark,createdAt,updatedAt';
    const lines: string[] = [header];
    bills.forEach((bill: BillBean) => {
      const row: string =
        `${bill.id},${this.escapeCsvValue(bill.type)},${this.escapeCsvValue(bill.category)},${bill.amount.toFixed(2)},` +
        `${this.escapeCsvValue(bill.account)},${this.escapeCsvValue(bill.targetAccount)},${bill.date},` +
        `${this.escapeCsvValue(bill.remark)},${bill.createdAt},${bill.updatedAt}`;
      lines.push(row);
    });
    return lines.join('\n');
  }

  private buildJsonContent(
    rangeInfo: ExportRangeInfo,
    bills: BillBean[],
    accounts: AccountBean[],
    categories: CategoryBean[],
    budgets: BudgetBean[]
  ): string {
    const payload: BackupPayload = new BackupPayload();
    payload.exportedAt = Date.now();
    payload.exportRange = rangeInfo.label;
    payload.billCount = bills.length;
    payload.accountCount = accounts.length;
    payload.categoryCount = categories.length;
    payload.budgetCount = budgets.length;
    payload.bills = bills;
    payload.accounts = accounts;
    payload.categories = categories;
    payload.budgets = budgets;
    payload.settings = this.optionSystem;
    payload.userProfile = this.userProfile;
    return JSON.stringify(payload, null, 2);
  }

  private async clearTable(tableName: string): Promise<void> {
    await dbManager.dbStore?.executeSql(`DELETE FROM ${tableName}`);
  }

  private async restoreAccounts(accounts: AccountBean[]): Promise<void> {
    for (const account of accounts) {
      await dbManager.dbStore?.insert('accounts', {
        id: account.id,
        name: account.name,
        balance: account.balance,
        type: account.type,
        icon: account.icon,
        created_at: account.createdAt,
        updated_at: account.updatedAt
      });
    }
  }

  private async restoreCategories(categories: CategoryBean[]): Promise<void> {
    for (const category of categories) {
      await dbManager.dbStore?.insert('categories', {
        id: category.id,
        name: category.name,
        type: category.type,
        icon: category.icon,
        sort_order: category.sortOrder,
        is_system: category.isSystem ? 1 : 0,
        created_at: category.createdAt,
        updated_at: category.updatedAt
      });
    }
  }

  private async restoreBudgets(budgets: BudgetBean[]): Promise<void> {
    for (const budget of budgets) {
      await dbManager.dbStore?.insert('budgets', {
        id: budget.id,
        category: budget.category,
        amount: budget.amount,
        month: budget.month,
        created_at: budget.createdAt,
        updated_at: budget.updatedAt
      });
    }
  }

  private async restoreBills(bills: BillBean[]): Promise<void> {
    for (const bill of bills) {
      await dbManager.dbStore?.insert('bills', {
        id: bill.id,
        type: bill.type,
        category: bill.category,
        amount: bill.amount,
        account: bill.account,
        target_account: bill.targetAccount,
        date: bill.date,
        remark: bill.remark,
        created_at: bill.createdAt,
        updated_at: bill.updatedAt
      });
    }
  }

  private async restoreSnapshot(payload: BackupPayload): Promise<void> {
    await dbManager.dbStore?.beginTransaction();
    try {
      await this.clearTable('bills');
      await this.clearTable('budgets');
      await this.clearTable('categories');
      await this.clearTable('accounts');
      await this.restoreAccounts(payload.accounts);
      await this.restoreCategories(payload.categories);
      await this.restoreBudgets(payload.budgets);
      await this.restoreBills(payload.bills);
      await dbManager.dbStore?.commit();
    } catch (error) {
      await dbManager.dbStore?.rollBack();
      throw new Error('restore snapshot failed');
    }
  }

  private async importLatestBackup(): Promise<void> {
    if (this.importing || this.exporting) {
      return;
    }
    this.refreshLatestBackupState();
    if (!this.latestBackupAvailable || this.latestBackupPath.length === 0) {
      this.showToast('还没有可恢复的 JSON 备份');
      return;
    }

    this.importing = true;
    try {
      const content: string = fs.readTextSync(this.latestBackupPath);
      const payload: BackupPayload = JSON.parse(content);
      await this.restoreSnapshot(payload);
      this.optionSystem.updateFromData(payload.settings);
      this.userProfile.updateFromData(payload.userProfile);
      PersistenceV2.save('UserProfile');
      billSyncController.notifyBillChanged();
      this.lastImportSummary =
        `已恢复账单 ${payload.bills.length} 条，账户 ${payload.accounts.length} 个，分类 ${payload.categories.length} 个，预算 ${payload.budgets.length} 条`;
      this.showToast('恢复完成');
    } catch {
      this.showToast('恢复失败，请检查最近备份文件');
    } finally {
      this.importing = false;
    }
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 1800
      });
    } catch {
    }
  }

  private async exportData(): Promise<void> {
    if (this.exporting) {
      return;
    }
    this.exporting = true;
    try {
      const rangeInfo: ExportRangeInfo = this.buildRangeInfo();
      const result = await Promise.all([
        BillManager.getBillsByRange(rangeInfo.startTime, rangeInfo.endTime, ''),
        AccountManager.getAccounts(),
        CategoryManager.getCategoriesByType(BillTypeEnum.EXPENSE),
        CategoryManager.getCategoriesByType(BillTypeEnum.INCOME),
        BudgetManager.getAllBudgets()
      ]);
      const bills: BillBean[] = result[0];
      const accounts: AccountBean[] = result[1];
      const categories: CategoryBean[] = result[2].concat(result[3]);
      const budgets: BudgetBean[] = this.filterBudgetsByRange(result[4], rangeInfo);

      let filePath: string;
      if (this.exportFormat === 'json') {
        const jsonContent: string = this.buildJsonContent(rangeInfo, bills, accounts, categories, budgets);
        filePath = this.writeExportFile(this.buildExportFileName('json'), jsonContent);
        this.writeLatestJsonBackup(jsonContent);
        this.refreshLatestBackupState();
      } else {
        const csvContent: string = this.buildCsvContent(bills);
        filePath = this.writeExportFile(this.buildExportFileName('csv'), csvContent);
      }

      this.lastExportPath = filePath;
      this.lastExportSummary = `账单 ${bills.length} 条，账户 ${accounts.length} 个，分类 ${categories.length} 个，预算 ${budgets.length} 条`;
      this.showToast('导出完成');
    } catch {
      this.showToast('导出失败，请稍后重试');
    } finally {
      this.exporting = false;
    }
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          // 导出说明
          ListItemGroup({
            header: GroupHeader('导出说明'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Column() {
                Row() {
                  SymbolGlyph($r('sys.symbol.doc_text'))
                    .fontSize(20)
                    .fontWeight(this.optionSystem.iconThickness)
                    .fontColor([this.themeState.brand])
                    .margin({ right: 12 })

                  Text('数据导出')
                    .fontSize(16)
                    .fontWeight(this.optionSystem.fontThickness)
                    .fontColor($r('[shared_assets].color.text_primary'))
                }
                .width('100%')

                Text('将您的记账数据导出为文件，可用于备份或导入其他设备。导出的数据包含账单记录、分类信息等。')
                  .fontSize(14)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('[shared_assets].color.text_secondary'))
                  .margin({ top: 8 })
                  .width('100%')

                Text('JSON 会导出完整账本快照，CSV 会导出当前范围内的账单明细。')
                  .fontSize(12)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('[shared_assets].color.text_secondary'))
                  .margin({ top: 6 })
                  .width('100%')

                Text('导出 JSON 时会同时更新一份“最近备份”，可直接用于本机恢复。')
                  .fontSize(12)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('[shared_assets].color.text_secondary'))
                  .margin({ top: 6 })
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .alignItems(HorizontalAlign.Start)
            }
          }

          // 导出格式
          ListItemGroup({
            header: GroupHeader('导出格式'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row() {
                Text('CSV 表格')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('[shared_assets].color.text_primary'))

                Blank()

                Radio({ value: 'csv', group: 'formatGroup' })
                  .checked(this.exportFormat === 'csv')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportFormat = 'csv'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }

            ListItem() {
              Row() {
                Text('JSON 数据')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('[shared_assets].color.text_primary'))

                Blank()

                Radio({ value: 'json', group: 'formatGroup' })
                  .checked(this.exportFormat === 'json')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportFormat = 'json'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }
          }

          // 导出范围
          ListItemGroup({
            header: GroupHeader('导出范围'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row() {
                Text('全部数据')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('[shared_assets].color.text_primary'))

                Blank()

                Radio({ value: 'all', group: 'rangeGroup' })
                  .checked(this.exportRange === 'all')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportRange = 'all'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }

            ListItem() {
              Row() {
                Text('今年数据')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('[shared_assets].color.text_primary'))

                Blank()

                Radio({ value: 'year', group: 'rangeGroup' })
                  .checked(this.exportRange === 'year')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportRange = 'year'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }

            ListItem() {
              Row() {
                Text('本月数据')
                  .fontSize(16)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor($r('[shared_assets].color.text_primary'))

                Blank()

                Radio({ value: 'month', group: 'rangeGroup' })
                  .checked(this.exportRange === 'month')
                  .radioStyle({ checkedBackgroundColor: this.themeState.brand })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.exportRange = 'month'
                    }
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
            }
          }

          // 导出按钮
          ListItem() {
            Button(this.exporting ? '导出中...' : '导出数据')
              .width('100%')
              .height(48)
              .backgroundColor(this.themeState.brand)
              .fontWeight(this.optionSystem.fontThickness)
              .fontColor(Color.White)
              .borderRadius(12)
              .enabled(!this.exporting)
              .onClick(() => {
                this.exportData()
              })
          }
          .padding({ left: 16, right: 16, top: 8 })

          ListItemGroup({
            header: GroupHeader('数据恢复', '恢复会覆盖当前本地账本'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Column({ space: 10 }) {
                Text(this.latestBackupAvailable ? '最近 JSON 备份已就绪，可直接恢复。' : '暂无最近 JSON 备份，请先导出一次 JSON。')
                  .fontSize(14)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor(this.themeState.fontPrimary)
                  .width('100%')

                if (this.latestBackupPath.length > 0) {
                  Text(this.latestBackupPath)
                    .fontSize(12)
                    .fontWeight(this.optionSystem.fontThickness)
                    .fontColor(this.themeState.fontSecondary)
                    .width('100%')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }

                Button(this.importing ? '恢复中...' : '恢复最近 JSON 备份')
                  .width('100%')
                  .height(46)
                  .backgroundColor(this.latestBackupAvailable ? this.themeState.brand : '#D1D5DB')
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor(Color.White)
                  .borderRadius(12)
                  .enabled(this.latestBackupAvailable && !this.importing && !this.exporting)
                  .onClick(() => {
                    this.importLatestBackup();
                  })
              }
              .width('100%')
              .padding(16)
              .alignItems(HorizontalAlign.Start)
            }
          }

          if (this.lastExportPath.length > 0) {
            ListItemGroup({
              header: GroupHeader('最近导出'),
              space: 1,
              style: ListItemGroupStyle.CARD
            }) {
              ListItem() {
                Column({ space: 8 }) {
                  Text(this.lastExportSummary)
                    .fontSize(14)
                    .fontWeight(this.optionSystem.fontThickness)
                    .fontColor(this.themeState.fontPrimary)
                    .width('100%')

                  Text(this.lastExportPath)
                    .fontSize(12)
                    .fontWeight(this.optionSystem.fontThickness)
                    .fontColor(this.themeState.fontSecondary)
                    .width('100%')
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
                .padding(16)
                .alignItems(HorizontalAlign.Start)
              }
            }
          }

          if (this.lastImportSummary.length > 0) {
            ListItemGroup({
              header: GroupHeader('最近恢复'),
              space: 1,
              style: ListItemGroupStyle.CARD
            }) {
              ListItem() {
                Text(this.lastImportSummary)
                  .fontSize(14)
                  .fontWeight(this.optionSystem.fontThickness)
                  .fontColor(this.themeState.fontPrimary)
                  .width('100%')
                  .padding(16)
              }
            }
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
            backIconStyle: {
              backgroundColor: $r('[shared_assets].color.action_bg'),
              iconColor: $r('[shared_assets].color.text_primary')
            }
          }
        }
      },
      content: { title: { mainTitle: "数据导出" } },
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
