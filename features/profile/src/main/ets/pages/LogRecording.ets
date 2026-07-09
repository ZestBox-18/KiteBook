/**
 * Copyright (C), 2026-07-09
 * @author ZestBox
 * @date 2026/07/09
 * @version 1.0
 * @description: 日志记录设置页面
 */

import { common } from '@kit.AbilityKit';
import { zlib } from '@kit.BasicServicesKit';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';
import {
  AppThemeState,
  CommonConstants,
  GroupHeader,
  mainTabController,
  SystemOptions
} from 'base';
import { hdsMaterial, HdsAnimationMode, HdsNavDestination, ScrollEffectType } from '@kit.UIDesignKit';
import { Clog, ClogLogEntry, WindowUtil } from 'kite_utils';

const TAG: string = '[LogRecording]';

class LogActionResult {
  success: boolean = false;
  message: string = '';
  path: string = '';

  constructor(success: boolean, message: string, path: string = '') {
    this.success = success;
    this.message = message;
    this.path = path;
  }
}

@ComponentV2
export struct LogRecording {
  @Local pageInfos: NavPathStack = new NavPathStack()
  @Local winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  @Local themeState: AppThemeState =
    AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!
  @Local exporting: boolean = false
  @Local clearing: boolean = false
  @Local logDirText: string = ''
  @Local hasLogs: boolean = false
  @Local logSizeText: string = '0 KB'
  @Local latestLogText: string = '暂无'
  @Local showRecentLogSheet: boolean = false
  @Local recentLogs: ClogLogEntry[] = []
  @Local recentLogFilter: string = 'all'
  private uiContext: UIContext | undefined = undefined
  private context: common.UIAbilityContext | undefined = undefined

  aboutToAppear(): void {
    this.initPageContext();
    this.ensureLogReady();
    this.refreshLogState();
  }

  private initPageContext(): void {
    this.uiContext = this.getUIContext();
    const hostContext = this.uiContext.getHostContext();
    if (hostContext) {
      this.context = hostContext as common.UIAbilityContext;
    }
  }

  private getAbilityContext(): common.UIAbilityContext | null {
    if (this.context) {
      return this.context;
    }
    this.initPageContext();
    if (this.context) {
      return this.context;
    }
    return null;
  }

  private ensureLogReady(): boolean {
    const context = this.getAbilityContext();
    if (!context) {
      return false;
    }
    Clog.init(context);
    if (this.optionSystem.logRecording) {
      Clog.enableSave();
    } else {
      Clog.disableSave();
    }
    return true;
  }

  private refreshLogState(): void {
    this.logDirText = Clog.getSaveDirPath();
    this.hasLogs = Clog.hasSavedLogs();
    this.logSizeText = this.formatFileSize(this.getLogDirectorySize(this.logDirText));
    this.latestLogText = this.formatLatestLogTime(this.getLatestLogModifyTime(this.logDirText));
  }

  private resetLogState(): void {
    this.hasLogs = false;
    this.logSizeText = '0 KB';
    this.latestLogText = '暂无';
    this.recentLogs = [];
  }

  private applyLogStateCleared(): void {
    const uiContext = this.uiContext ? this.uiContext : this.getUIContext();
    uiContext.animateTo({ duration: 0 }, () => {
      this.resetLogState();
    });
  }

  private showToast(message: string): void {
    try {
      const uiContext = this.uiContext ? this.uiContext : this.getUIContext();
      uiContext.getPromptAction().showToast({
        message: message,
        duration: 1800
      });
    } catch {
    }
  }

  private handleLogSwitch(isOn: boolean): void {
    if (!this.ensureLogReady()) {
      this.showToast('日志目录初始化失败');
      return;
    }
    this.optionSystem.logRecording = isOn;
    PersistenceV2.save('SystemOptions');
    if (isOn) {
      Clog.enableSave();
      Clog.info(TAG, '详细日志记录已开启');
      this.showToast('详细日志已开启');
    } else {
      Clog.info(TAG, '详细日志记录已关闭');
      Clog.disableSave();
      this.showToast('已切换为仅记录错误');
    }
    this.refreshLogState();
  }

  private buildExportFileName(): string {
    const now: Date = new Date();
    const timestamp: string =
      `${now.getFullYear()}${(now.getMonth() + 1).toString().padStart(2, '0')}${now.getDate()
        .toString()
        .padStart(2, '0')}_${now.getHours().toString().padStart(2, '0')}${now.getMinutes()
        .toString()
        .padStart(2, '0')}${now.getSeconds().toString().padStart(2, '0')}`;
    return `kitebook_logs_${timestamp}.zip`;
  }

  private getLogZipPath(): string {
    const context = this.getAbilityContext();
    if (!context) {
      return '';
    }
    return `${context.filesDir}/logs.zip`;
  }

  private deleteFileIfExists(path: string): void {
    try {
      if (fs.accessSync(path)) {
        fs.unlinkSync(path);
      }
    } catch {
    }
  }

  private clearLogDirectoryFiles(dir: string): void {
    if (dir.length === 0) {
      return;
    }
    try {
      const files: string[] = fs.listFileSync(dir);
      files.forEach((fileName: string) => {
        this.deleteFileIfExists(`${dir}/${fileName}`);
      });
    } catch {
    }
  }

  private getLogDirectorySize(dir: string): number {
    if (dir.length === 0) {
      return 0;
    }
    try {
      const files: string[] = fs.listFileSync(dir);
      let totalSize: number = 0;
      files.forEach((fileName: string) => {
        try {
          totalSize += fs.statSync(`${dir}/${fileName}`).size;
        } catch {
        }
      });
      return totalSize;
    } catch {
      return 0;
    }
  }

  private getLatestLogModifyTime(dir: string): number {
    if (dir.length === 0) {
      return 0;
    }
    try {
      const files: string[] = fs.listFileSync(dir);
      let latestTime: number = 0;
      files.forEach((fileName: string) => {
        try {
          const modifyTime: number = fs.statSync(`${dir}/${fileName}`).mtime;
          if (modifyTime > latestTime) {
            latestTime = modifyTime;
          }
        } catch {
        }
      });
      return latestTime;
    } catch {
      return 0;
    }
  }

  private formatFileSize(size: number): string {
    if (size <= 0) {
      return '0 KB';
    }
    if (size < 1024 * 1024) {
      const kb: number = Math.max(1, Math.round(size / 1024));
      return `${kb} KB`;
    }
    const mb: number = Math.round(size / 1024 / 1024 * 10) / 10;
    return `${mb.toFixed(1)} MB`;
  }

  private formatLatestLogTime(time: number): string {
    if (time <= 0) {
      return '暂无';
    }
    const date: Date = new Date(time);
    const now: Date = new Date();
    const timeText: string = `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes()
      .toString()
      .padStart(2, '0')}`;
    if (date.getFullYear() === now.getFullYear() &&
      date.getMonth() === now.getMonth() &&
      date.getDate() === now.getDate()) {
      return `今天 ${timeText}`;
    }
    return `${date.getMonth() + 1}月${date.getDate()}日 ${timeText}`;
  }

  private copyFile(sourcePath: string, targetUri: string): void {
    try {
      const stat = fs.statSync(sourcePath);
      const sourceFile = fs.openSync(sourcePath, fs.OpenMode.READ_ONLY);
      try {
        const targetFile = fs.openSync(targetUri, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
        try {
          if (stat.size > 0) {
            const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
            fs.readSync(sourceFile.fd, buffer);
            fs.writeSync(targetFile.fd, buffer);
          }
        } finally {
          fs.closeSync(targetFile);
        }
      } finally {
        fs.closeSync(sourceFile);
      }
    } catch (error) {
      Clog.error(TAG, '复制日志文件失败', error);
      throw new Error('copy log file failed');
    }
  }

  private async prepareLogZip(): Promise<LogActionResult> {
    if (!this.ensureLogReady()) {
      return new LogActionResult(false, '日志目录初始化失败');
    }
    Clog.flush();
    const saveDir: string = Clog.getSaveDirPath();
    if (saveDir.length === 0 || !Clog.hasSavedLogs()) {
      return new LogActionResult(false, '暂无日志文件');
    }
    const zipPath: string = this.getLogZipPath();
    if (zipPath.length === 0) {
      return new LogActionResult(false, '日志压缩路径无效');
    }
    this.deleteFileIfExists(zipPath);
    try {
      await zlib.compressFile(saveDir, zipPath, {});
    } catch (error) {
      Clog.error(TAG, '日志压缩失败', error);
      return new LogActionResult(false, '日志压缩失败');
    }
    try {
      if (!fs.accessSync(zipPath)) {
        return new LogActionResult(false, '日志压缩文件不存在');
      }
    } catch {
      return new LogActionResult(false, '日志压缩文件不存在');
    }
    return new LogActionResult(true, '日志压缩完成', zipPath);
  }

  private async exportLogs(): Promise<void> {
    if (this.exporting) {
      return;
    }
    this.exporting = true;
    this.showToast('正在导出日志');
    try {
      const zipResult: LogActionResult = await this.prepareLogZip();
      if (!zipResult.success) {
        this.showToast(zipResult.message);
        return;
      }

      const documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [this.buildExportFileName()];
      documentSaveOptions.fileSuffixChoices = ['压缩文件|zip'];
      const documentPicker = new picker.DocumentViewPicker();
      const savedUris: string[] = await documentPicker.save(documentSaveOptions);
      if (savedUris.length === 0) {
        this.showToast('已取消保存');
        return;
      }

      this.copyFile(zipResult.path, savedUris[0]);
      Clog.info(TAG, '日志导出成功');
      this.showToast('日志导出成功');
    } catch (error) {
      Clog.error(TAG, '日志导出失败', error);
      this.showToast('日志导出失败');
    } finally {
      this.exporting = false;
      this.refreshLogState();
    }
  }

  private clearLogs(): void {
    if (this.clearing) {
      return;
    }
    this.clearing = true;
    try {
      Clog.clearSavedLogs();
      this.clearLogDirectoryFiles(Clog.getSaveDirPath());
      const zipPath: string = this.getLogZipPath();
      if (zipPath.length > 0) {
        this.deleteFileIfExists(zipPath);
      }
      this.applyLogStateCleared();
      this.showToast('日志已清空');
    } catch (error) {
      Clog.error(TAG, '清空日志失败', error);
      this.showToast('清空日志失败');
    } finally {
      this.clearing = false;
    }
  }

  private confirmClearLogs(): void {
    try {
      const uiContext = this.uiContext ? this.uiContext : this.getUIContext();
      uiContext.showAlertDialog({
        title: '清空本地日志',
        message: '仅清空本机保存的日志文件，不影响账单、账户、预算等业务数据。清空后日志无法恢复。',
        primaryButton: {
          value: '取消',
          action: () => {
          }
        },
        secondaryButton: {
          value: '清空',
          fontColor: '#E55454',
          action: () => {
            this.clearLogs();
          }
        }
      });
    } catch (error) {
      Clog.error(TAG, '显示清空日志确认弹窗失败', error);
    }
  }

  private openRecentLogs(): void {
    this.refreshRecentLogs();
    this.showRecentLogSheet = true;
  }

  private refreshRecentLogs(): void {
    this.ensureLogReady();
    this.recentLogs = Clog.readRecentLogs(80, this.recentLogFilter);
    this.refreshLogState();
  }

  private setRecentLogFilter(filter: string): void {
    this.recentLogFilter = filter;
    this.refreshRecentLogs();
  }

  private getFilterLabel(filter: string): string {
    if (filter === 'error') {
      return '错误';
    }
    if (filter === 'warn') {
      return '警告';
    }
    if (filter === 'info') {
      return '信息';
    }
    return '全部';
  }

  private getLevelLabel(level: string): string {
    if (level === 'error') {
      return 'ERROR';
    }
    if (level === 'warn') {
      return 'WARN';
    }
    return 'INFO';
  }

  private getLevelColor(level: string): ResourceColor {
    if (level === 'error') {
      return '#EF4444';
    }
    if (level === 'warn') {
      return '#F59E0B';
    }
    return this.themeState.brand;
  }

  private formatLogTime(time: number): string {
    if (time <= 0) {
      return '--:--:--';
    }
    const date: Date = new Date(time);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes()
      .toString()
      .padStart(2, '0')}:${date.getSeconds().toString().padStart(2, '0')}`;
  }

  @Builder
  private RecentLogActionRow() {
    Button() {
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.list_bullet'))
            .fontSize(20)
            .fontWeight(this.optionSystem.iconThickness)
            .fontColor([this.hasLogs ? this.themeState.brand : this.themeState.fontSecondary])
        }
        .width(36)
        .height(36)
        .borderRadius(10)
        .backgroundColor($r('[shared_assets].color.action_bg'))
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })

        Column() {
          Text('查看最近日志')
            .fontSize(15)
            .fontWeight(this.optionSystem.fontThickness)
            .fontColor(this.hasLogs ? this.themeState.fontPrimary : this.themeState.fontSecondary)
            .width('100%')

          Text('以易读方式预览最近 80 条记录')
            .fontSize(12)
            .fontWeight(this.optionSystem.fontThickness)
            .fontColor(this.themeState.fontSecondary)
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(18)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.fontSecondary])
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })
    }
    .backgroundColor('#00000000')
    .enabled(this.hasLogs)
    .onClick(() => {
      this.openRecentLogs();
    })
  }

  @Builder
  private ClearLogActionRow() {
    Button() {
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.trash'))
            .fontSize(20)
            .fontWeight(this.optionSystem.iconThickness)
            .fontColor([this.hasLogs && !this.exporting && !this.clearing ? this.themeState.brand :
            this.themeState.fontSecondary])
        }
        .width(36)
        .height(36)
        .borderRadius(10)
        .backgroundColor($r('[shared_assets].color.action_bg'))
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })

        Column() {
          Text(this.clearing ? '清空中...' : '清空本地日志')
            .fontSize(15)
            .fontWeight(this.optionSystem.fontThickness)
            .fontColor(this.hasLogs && !this.exporting && !this.clearing ? this.themeState.fontPrimary :
            this.themeState.fontSecondary)
            .width('100%')

          Text('只清理本机日志，不影响业务数据')
            .fontSize(12)
            .fontWeight(this.optionSystem.fontThickness)
            .fontColor(this.themeState.fontSecondary)
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(18)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.fontSecondary])
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })
    }
    .backgroundColor('#00000000')
    .enabled(this.hasLogs && !this.exporting && !this.clearing)
    .onClick(() => {
      this.confirmClearLogs();
    })
  }

  @Builder
  private ExportBadgeButton() {
    Button() {
      Row({ space: 7 }) {
        SymbolGlyph($r('sys.symbol.arrow_up_circle'))
          .fontSize(17)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.hasLogs && !this.exporting ? this.themeState.brand : this.themeState.fontSecondary])

        Text(this.exporting ? '导出中' : '可导出')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.hasLogs && !this.exporting ? this.themeState.brand : this.themeState.fontSecondary)
      }
      .padding({ left: 12, right: 12 })
    }
    .height(34)
    .borderRadius(17)
    .backgroundColor('#00000000')
    .border({
      width: 1,
      color: this.hasLogs && !this.exporting ? this.themeState.brand : this.themeState.compDivider
    })
    .enabled(this.hasLogs && !this.exporting && !this.clearing)
    .onClick(() => {
      this.exportLogs();
    })
  }

  @Builder
  private LatestLogMeta() {
    Row({ space: 7 }) {
      SymbolGlyph($r('sys.symbol.clock'))
        .fontSize(15)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([this.themeState.fontSecondary])

      Text(`最近更新：${this.latestLogText}`)
        .fontSize(12)
        .fontWeight(this.optionSystem.fontThickness)
        .fontColor(this.themeState.fontSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
  }

  @Builder
  private LogSizeMeta() {
    Row({ space: 7 }) {
      SymbolGlyph($r('sys.symbol.doc_text'))
        .fontSize(15)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([this.themeState.fontSecondary])

      Text(`本地占用：${this.logSizeText}`)
        .fontSize(12)
        .fontWeight(this.optionSystem.fontThickness)
        .fontColor(this.themeState.fontSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
  }

  @Builder
  private LogStatusCard() {
    Column() {
      Row() {
        Text(this.optionSystem.logRecording ? '详细日志' : '仅错误日志')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontPrimary)
          .layoutWeight(1)

        this.ExportBadgeButton()
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(this.hasLogs ? '最近已生成可导出的日志文件，系统会自动轮转保存' : '暂无可导出的日志文件，出现错误后会自动保留')
        .fontSize(12)
        .fontWeight(this.optionSystem.fontThickness)
        .fontColor(this.themeState.fontSecondary)
        .lineHeight(18)
        .width('100%')
        .margin({ top: 8 })

      Row() {
        this.LatestLogMeta()

        Divider()
          .vertical(true)
          .height(14)
          .color(this.themeState.compDivider)
          .margin({ left: 10, right: 10 })

        this.LogSizeMeta()
      }
      .width('100%')
      .margin({ top: 16 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
  }

  @Builder
  private LogFilterButton(filter: string) {
    Button(this.getFilterLabel(filter))
      .height(34)
      .layoutWeight(1)
      .backgroundColor(this.recentLogFilter === filter ? this.themeState.brand : $r('[shared_assets].color.action_bg'))
      .fontColor(this.recentLogFilter === filter ? Color.White : this.themeState.fontPrimary)
      .fontSize(13)
      .fontWeight(this.optionSystem.fontThickness)
      .borderRadius(10)
      .onClick(() => {
        this.setRecentLogFilter(filter);
      })
  }

  @Builder
  private LogPreviewItem(entry: ClogLogEntry) {
    Column({ space: 6 }) {
      Row() {
        Text(this.getLevelLabel(entry.level))
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .padding({ left: 7, right: 7, top: 3, bottom: 3 })
          .backgroundColor(this.getLevelColor(entry.level))
          .borderRadius(6)

        Text(this.formatLogTime(entry.time))
          .fontSize(12)
          .fontWeight(this.optionSystem.fontThickness)
          .fontColor(this.themeState.fontSecondary)
          .margin({ left: 8 })

        Text(entry.tag)
          .fontSize(12)
          .fontWeight(this.optionSystem.fontThickness)
          .fontColor(this.themeState.fontSecondary)
          .margin({ left: 8 })
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')

      Text(entry.message)
        .fontSize(13)
        .fontWeight(this.optionSystem.fontThickness)
        .fontColor(this.themeState.fontPrimary)
        .lineHeight(18)
        .width('100%')
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor($r('[shared_assets].color.card_background'))
    .borderRadius(12)
  }

  @Builder
  private RecentLogSheetBuilder() {
    Column() {
      Row() {
        Column() {
          Text('最近日志')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)
            .width('100%')

          Text(`最多展示最近 ${this.recentLogs.length} 条，导出文件仍包含完整轮转日志`)
            .fontSize(13)
            .fontWeight(this.optionSystem.fontThickness)
            .fontColor(this.themeState.fontSecondary)
            .margin({ top: 4 })
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(18)
            .fontWeight(this.optionSystem.iconThickness)
            .fontColor([this.themeState.fontPrimary])
        }
        .width(38)
        .height(38)
        .borderRadius(19)
        .backgroundColor($r('[shared_assets].color.action_bg'))
        .onClick(() => {
          this.showRecentLogSheet = false;
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 12 })

      Row({ space: 8 }) {
        this.LogFilterButton('all')
        this.LogFilterButton('error')
        this.LogFilterButton('warn')
        this.LogFilterButton('info')
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 12 })

      List({ space: 8 }) {
        if (this.recentLogs.length === 0) {
          ListItem() {
            Column() {
              SymbolGlyph($r('sys.symbol.doc_text'))
                .fontSize(28)
                .fontWeight(this.optionSystem.iconThickness)
                .fontColor([this.themeState.fontSecondary])
                .margin({ bottom: 8 })

              Text('暂无日志')
                .fontSize(15)
                .fontWeight(this.optionSystem.fontThickness)
                .fontColor(this.themeState.fontSecondary)
            }
            .width('100%')
            .height(160)
            .justifyContent(FlexAlign.Center)
          }
        } else {
          ForEach(this.recentLogs, (entry: ClogLogEntry) => {
            ListItem() {
              this.LogPreviewItem(entry)
            }
          })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 20, right: 20, bottom: this.winUtil.mainWindowInfo.navIndicatorHeight + 16 })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('[shared_assets].color.title_bar_bg'))
  }

  build() {
    HdsNavDestination() {
      Column() {
        List({ space: 10 }) {
          ListItem().height(this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI)

          ListItemGroup({
            header: GroupHeader('日志开关'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              Row() {
                SymbolGlyph($r('sys.symbol.doc_text'))
                  .fontSize(20)
                  .fontWeight(this.optionSystem.iconThickness)
                  .fontColor([$r('[shared_assets].color.text_primary')])
                  .margin({ right: 12 })

                Column() {
                  Text('记录运行日志')
                    .fontSize(16)
                    .fontWeight(this.optionSystem.fontThickness)
                    .fontColor($r('[shared_assets].color.text_primary'))

                  Text('关闭时仅保留错误日志，开启后记录 info、warn、error 详情')
                    .fontSize(12)
                    .fontWeight(this.optionSystem.fontThickness)
                    .fontColor($r('[shared_assets].color.text_secondary'))
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Toggle({ type: ToggleType.Switch, isOn: this.optionSystem.logRecording })
                  .selectedColor(this.themeState.brand)
                  .switchPointColor('#FFFFFF')
                  .onChange((isOn: boolean) => {
                    this.handleLogSwitch(isOn);
                  })
              }
              .width('100%')
              .height(64)
              .padding({ left: 16, right: 16 })
            }
          }

          ListItemGroup({
            header: GroupHeader('日志状态'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              this.LogStatusCard()
            }
          }

          ListItemGroup({
            header: GroupHeader('日志操作'),
            space: 1,
            style: ListItemGroupStyle.CARD
          }) {
            ListItem() {
              this.RecentLogActionRow()
            }

            ListItem() {
              this.ClearLogActionRow()
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
      content: { title: { mainTitle: '日志记录' } },
      avoidLayoutSafeArea: true
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .onBackPressed(() => {
      mainTabController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
      return false;
    })
    .bindSheet($$this.showRecentLogSheet, this.RecentLogSheetBuilder, {
      detents: [SheetSize.LARGE],
      preferType: SheetType.BOTTOM,
      blurStyle: BlurStyle.Thick,
      showClose: false,
      showInSubWindow: false,
      backgroundColor: $r('[shared_assets].color.title_bar_bg'),
      dragBar: true
    })
  }
}
