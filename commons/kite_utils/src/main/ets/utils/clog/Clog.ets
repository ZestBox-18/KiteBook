/**
 * 日志工具类
 * 支持打印任意类型的内容：字符串、数字、对象、数组等
 *
 * @ author ZestBox
 * @ since 2025-09-10
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common, errorManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 支持的日志内容类型
 */
type LogContent = string | number | boolean | null | undefined | object | Array<LogContent>;
type LogLevel = 'info' | 'warn' | 'error';
type LogFileKind = 'info' | 'warn' | 'error' | 'all';

interface LogEntry {
  level: LogLevel;
  tag: string;
  message: string;
  time: number;
}

interface WriteOptions {
  offset: number;
  encoding: string;
}

export class ClogLogEntry {
  level: string = 'info';
  tag: string = '';
  message: string = '';
  time: number = 0;
}

export class ClogExceptionInfo {
  name: string = '';
  message: string = '';
  stack: string = '';
  time: number = 0;
}

type ClogExceptionCallback = (info: ClogExceptionInfo) => void;

export class Clog {
  private static CHARACTECH_PREFIX: string = '[Charactech]';
  private static LOG_DOMAIN = 0x0fff;
  private static SAVE_DIR?: string;
  private static SAVE_ENABLED: boolean = false;
  private static DISABLE_NON_ERROR_SAVE: boolean = false;
  private static BUFFER: LogEntry[] = [];
  private static FLUSH_TIMER_ID: number = -1;
  private static FLUSH_DELAY_MS: number = 2000;
  private static MAX_BUFFER_SIZE: number = 20;
  private static MAX_LOG_FILE_SIZE: number = 2 * 1024 * 1024;
  private static MAX_COMMON_FILE_COUNT: number = 5;
  private static MAX_ERROR_FILE_COUNT: number = 10;
  private static CRASH_OBSERVER_ID?: number;

  // 日志格式：TAG message
  private static TWO_PLACEHOLDER_FORMAT: string = '%{public}s    %{public}s';

  /**
   * 设置日志域
   * @param domain 日志域值，默认为0x0fff
   */
  public static setLogDomain(domain: number): void {
    Clog.LOG_DOMAIN = domain;
  }

  /**
   * 设置日志前缀
   * @param prefix 日志前缀字符串，默认为'[Charactech]'
   */
  public static setPrefix(prefix: string): void {
    Clog.CHARACTECH_PREFIX = prefix;
  }

  /**
   * 设置日志保存目录
   * 仅设置目录本身，不清空既有文件，也不更改落盘开关
   */
  public static setSaveDir(dir: string): void {
    Clog.SAVE_DIR = dir;
  }

  /**
   * 关闭详细日志落盘
   * 关闭后仅保留 error 级别本地日志
   */
  public static disableSave(): void {
    Clog.flush();
    Clog.SAVE_ENABLED = false;
    Clog.cancelFlushTimer();
  }

  /**
   * 开启所有级别落盘
   * 调用后：info/warn/error 均会进入本地日志
   */
  public static enableSave(): void {
    Clog.SAVE_ENABLED = true;
    Clog.DISABLE_NON_ERROR_SAVE = false;
  }

  /**
   * 获取当前保存目录路径
   * 未配置时返回空字符串
   */
  public static getSaveDirPath(): string {
    if (Clog.SAVE_DIR) {
      return Clog.SAVE_DIR
    }
    return ''
  }

  /**
   * 判断当前是否开启本地日志落盘
   */
  public static isSaveEnabled(): boolean {
    return Clog.SAVE_ENABLED;
  }

  private static createExceptionInfo(name: string, message: string, stack: string): ClogExceptionInfo {
    const info = new ClogExceptionInfo();
    info.name = name;
    info.message = message;
    info.stack = stack;
    info.time = Date.now();
    return info;
  }

  /**
   * 开启全局 JS crash 捕获。捕获到的异常会统一进入 Clog error 日志。
   */
  public static enableCrashCapture(callback?: ClogExceptionCallback): void {
    try {
      if (Clog.CRASH_OBSERVER_ID !== undefined) {
        return;
      }

      Clog.CRASH_OBSERVER_ID = errorManager.on('error', {
        onUnhandledException(errMsg: string): void {
          const info: ClogExceptionInfo =
            Clog.createExceptionInfo('UnhandledException', errMsg, '');
          Clog.error('[Crash]', info);
          if (callback) {
            callback(info);
          }
        },
        onException(errObject: Error): void {
          const stack: string = errObject.stack ? errObject.stack : '';
          const info: ClogExceptionInfo =
            Clog.createExceptionInfo(errObject.name, errObject.message, stack);
          Clog.error('[Crash]', info);
          if (callback) {
            callback(info);
          }
        }
      });
    } catch (error) {
      Clog.error('[Crash]', error as object);
    }
  }

  /**
   * 关闭全局 JS crash 捕获。
   */
  public static disableCrashCapture(): void {
    try {
      const observerId = Clog.CRASH_OBSERVER_ID;
      if (observerId === undefined) {
        return;
      }
      errorManager.off('error', observerId, (err: BusinessError) => {
        if (err) {
          Clog.error('[Crash]', err);
          return;
        }
        Clog.CRASH_OBSERVER_ID = undefined;
      });
    } catch (error) {
      Clog.error('[Crash]', error as object);
    }
  }

  public static isCrashCaptureEnabled(): boolean {
    return Clog.CRASH_OBSERVER_ID !== undefined;
  }


  /**
   * 初始化日志目录（仅需传入 Context）
   * 目录位置：`context.filesDir/logs`，若不存在则创建
   * 仅设置目录，不更改落盘开关
   */
  public static init(context: common.UIAbilityContext): void {

    const baseDir = context.filesDir;
    const dir = `${baseDir}/logs`;
    try {
      fs.statSync(dir);
    } catch {
      try {
        fs.mkdirSync(dir);
      } catch {
      }
    }
    Clog.SAVE_DIR = dir;
  }


  /**
   * 获取当前日志域
   * @returns 当前日志域值
   */
  public static getLogDomain(): number {
    return Clog.LOG_DOMAIN;
  }

  /**
   * 获取当前日志前缀
   * @returns 当前日志前缀字符串
   */
  public static getPrefix(): string {
    return Clog.CHARACTECH_PREFIX;
  }

  /**
   * 根据日志级别返回对应的文件路径
   * 未配置保存目录时返回 undefined
   */
  private static getFileCount(kind: LogFileKind): number {
    if (kind === 'error') {
      return Clog.MAX_ERROR_FILE_COUNT;
    }
    return Clog.MAX_COMMON_FILE_COUNT;
  }

  private static getIndexedFilePath(kind: LogFileKind, index: number): string | undefined {
    if (!Clog.SAVE_DIR) {
      return undefined;
    }
    return `${Clog.SAVE_DIR}/clog_${kind}_${index}.jsonl`;
  }

  /**
   * 根据日志级别返回当前写入文件路径
   * 未配置保存目录时返回 undefined
   */
  private static getFilePath(level: LogLevel): string | undefined {
    return Clog.getIndexedFilePath(level, 0);
  }

  private static getLegacyJsonlFilePath(kind: LogFileKind): string | undefined {
    if (!Clog.SAVE_DIR) {
      return undefined;
    }
    return `${Clog.SAVE_DIR}/clog_${kind}.jsonl`;
  }

  private static getLegacyJsonFilePath(kind: LogFileKind): string | undefined {
    if (!Clog.SAVE_DIR) {
      return undefined;
    }
    return `${Clog.SAVE_DIR}/clog_${kind}.json`;
  }

  /**
   * 返回当前汇总日志文件路径
   * 未配置保存目录时返回 undefined
   */
  private static getCombinedFilePath(): string | undefined {
    return Clog.getIndexedFilePath('all', 0);
  }

  private static isFileExist(path: string): boolean {
    try {
      fs.statSync(path);
      return true;
    } catch {
      return false;
    }
  }

  private static deleteFileIfExists(path: string): void {
    if (!Clog.isFileExist(path)) {
      return;
    }
    try {
      fs.unlinkSync(path);
    } catch {
    }
  }

  private static getFileSize(path: string): number {
    try {
      return fs.statSync(path).size;
    } catch {
      return 0;
    }
  }

  private static writeText(path: string, content: string): void {
    try {
      Clog.deleteFileIfExists(path);
      const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      try {
        fs.writeSync(file.fd, content, { offset: 0, encoding: 'utf-8' });
      } finally {
        fs.closeSync(file);
      }
    } catch {
    }
  }

  private static moveFileIfExists(sourcePath: string, targetPath: string): void {
    if (!Clog.isFileExist(sourcePath)) {
      return;
    }
    try {
      const content: string = fs.readTextSync(sourcePath);
      Clog.writeText(targetPath, content);
      Clog.deleteFileIfExists(sourcePath);
    } catch {
    }
  }

  private static rotateIfNeeded(kind: LogFileKind, incomingLength: number): void {
    const activePath = Clog.getIndexedFilePath(kind, 0);
    if (!activePath) {
      return;
    }
    const currentSize: number = Clog.getFileSize(activePath);
    if (currentSize + incomingLength <= Clog.MAX_LOG_FILE_SIZE) {
      return;
    }
    const maxCount: number = Clog.getFileCount(kind);
    const oldestPath = Clog.getIndexedFilePath(kind, maxCount - 1);
    if (oldestPath) {
      Clog.deleteFileIfExists(oldestPath);
    }
    for (let index = maxCount - 2; index >= 0; index--) {
      const sourcePath = Clog.getIndexedFilePath(kind, index);
      const targetPath = Clog.getIndexedFilePath(kind, index + 1);
      if (sourcePath && targetPath) {
        Clog.moveFileIfExists(sourcePath, targetPath);
      }
    }
  }

  private static hasSavedLogForKind(kind: LogFileKind): boolean {
    const maxCount: number = Clog.getFileCount(kind);
    for (let index = 0; index < maxCount; index++) {
      const path = Clog.getIndexedFilePath(kind, index);
      if (path && Clog.isFileExist(path)) {
        return true;
      }
    }
    const legacyJsonlPath = Clog.getLegacyJsonlFilePath(kind);
    if (legacyJsonlPath && Clog.isFileExist(legacyJsonlPath)) {
      return true;
    }
    const legacyJsonPath = Clog.getLegacyJsonFilePath(kind);
    if (legacyJsonPath && Clog.isFileExist(legacyJsonPath)) {
      return true;
    }
    return false;
  }

  private static clearSavedLogForKind(kind: LogFileKind): void {
    const maxCount: number = Clog.getFileCount(kind);
    for (let index = 0; index < maxCount; index++) {
      const path = Clog.getIndexedFilePath(kind, index);
      if (path) {
        Clog.deleteFileIfExists(path);
      }
    }
    const legacyJsonlPath = Clog.getLegacyJsonlFilePath(kind);
    if (legacyJsonlPath) {
      Clog.deleteFileIfExists(legacyJsonlPath);
    }
    const legacyJsonPath = Clog.getLegacyJsonFilePath(kind);
    if (legacyJsonPath) {
      Clog.deleteFileIfExists(legacyJsonPath);
    }
  }

  private static appendRecentLogsFromPath(path: string, logs: ClogLogEntry[], level: string): void {
    if (!Clog.isFileExist(path)) {
      return;
    }
    try {
      const content: string = fs.readTextSync(path);
      const lines: string[] = content.split('\n');
      lines.forEach((line: string) => {
        const text: string = line.trim();
        if (text.length === 0) {
          return;
        }
        try {
          const entry: ClogLogEntry = JSON.parse(text);
          if (level !== 'all' && entry.level !== level) {
            return;
          }
          logs.push(entry);
        } catch {
        }
      });
    } catch {
    }
  }

  /**
   * 读取最近日志。底层仍使用 JSONL 存储，页面展示时再转成人类友好的列表。
   */
  public static readRecentLogs(limit: number, level: string = 'all'): ClogLogEntry[] {
    Clog.flush();
    const logs: ClogLogEntry[] = [];
    const maxCount: number = Clog.getFileCount('all');
    for (let index = 0; index < maxCount; index++) {
      const path = Clog.getIndexedFilePath('all', index);
      if (path) {
        Clog.appendRecentLogsFromPath(path, logs, level);
      }
    }
    const legacyPath = Clog.getLegacyJsonlFilePath('all');
    if (legacyPath) {
      Clog.appendRecentLogsFromPath(legacyPath, logs, level);
    }
    logs.sort((left: ClogLogEntry, right: ClogLogEntry): number => {
      return right.time - left.time;
    });
    if (logs.length <= limit) {
      return logs;
    }
    return logs.slice(0, limit);
  }

  /**
   * 判断是否已有可导出的日志文件
   */
  public static hasSavedLogs(): boolean {
    if (Clog.BUFFER.length > 0) {
      return true;
    }
    return Clog.hasSavedLogForKind('info') ||
      Clog.hasSavedLogForKind('warn') ||
      Clog.hasSavedLogForKind('error') ||
      Clog.hasSavedLogForKind('all');
  }

  /**
   * 清空已保存的本地日志文件
   */
  public static clearSavedLogs(): void {
    Clog.BUFFER = [];
    Clog.cancelFlushTimer();
    Clog.clearSavedLogForKind('info');
    Clog.clearSavedLogForKind('warn');
    Clog.clearSavedLogForKind('error');
    Clog.clearSavedLogForKind('all');
  }

  /**
   * 格式化日志内容
   * @param content 支持的日志内容类型
   * @returns 格式化后的字符串
   */
  private static formatContent(content: LogContent): string {
    if (typeof content === 'string') {
      return content;
    } else if (typeof content === 'number' || typeof content === 'boolean') {
      return content.toString();
    } else if (Array.isArray(content)) {
      const formattedItems = content.map((item: LogContent): string => {
        if (typeof item === 'object' && item !== null) {
          try {
            return '\n' + JSON.stringify(item, null, 2)
          } catch {
            return '[Object]'
          }
        } else {
          return Clog.formatContent(item)
        }
      });
      return `\n[${formattedItems.join(', ')}]`;
    } else if (content === null) {
      return 'null';
    } else if (content === undefined) {
      return 'undefined';
    } else {
      try {
        const jsonStr = JSON.stringify(content, null, 2);
        // 确保JSON对象从新行开始，提供更好的可读性
        return '\n' + jsonStr;
      } catch (error) {
        return '[Object]';
      }
    }
  }

  private static appendText(kind: LogFileKind, path: string, content: string): number {
    if (content.length === 0) {
      return 0;
    }
    Clog.rotateIfNeeded(kind, content.length);
    try {
      const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      try {
        const offset = fs.statSync(file.fd).size;
        const options: WriteOptions = { offset: offset, encoding: 'utf-8' };
        return fs.writeSync(file.fd, content, options);
      } finally {
        fs.closeSync(file);
      }
    } catch {
      return 0;
    }
  }

  private static cancelFlushTimer(): void {
    if (Clog.FLUSH_TIMER_ID < 0) {
      return;
    }
    clearTimeout(Clog.FLUSH_TIMER_ID);
    Clog.FLUSH_TIMER_ID = -1;
  }

  private static scheduleFlush(): void {
    if (Clog.FLUSH_TIMER_ID >= 0) {
      return;
    }
    Clog.FLUSH_TIMER_ID = setTimeout(() => {
      Clog.FLUSH_TIMER_ID = -1;
      Clog.flush();
    }, Clog.FLUSH_DELAY_MS);
  }

  /**
   * 将缓冲日志批量追加到 JSONL 文件
   */
  public static flush(): void {
    if (Clog.BUFFER.length === 0) {
      return;
    }
    const entries: LogEntry[] = Clog.BUFFER;
    Clog.BUFFER = [];
    Clog.cancelFlushTimer();

    let infoContent: string = '';
    let warnContent: string = '';
    let errorContent: string = '';
    let allContent: string = '';
    entries.forEach((entry: LogEntry) => {
      const line: string = `${JSON.stringify(entry)}\n`;
      allContent += line;
      if (entry.level === 'info') {
        infoContent += line;
      } else if (entry.level === 'warn') {
        warnContent += line;
      } else {
        errorContent += line;
      }
    });

    const infoPath = Clog.getFilePath('info');
    const warnPath = Clog.getFilePath('warn');
    const errorPath = Clog.getFilePath('error');
    const allPath = Clog.getCombinedFilePath();
    if (infoPath) {
      Clog.appendText('info', infoPath, infoContent);
    }
    if (warnPath) {
      Clog.appendText('warn', warnPath, warnContent);
    }
    if (errorPath) {
      Clog.appendText('error', errorPath, errorContent);
    }
    if (allPath) {
      Clog.appendText('all', allPath, allContent);
    }
  }

  /**
   * 根据开关与级别将日志写入对应文件及汇总文件
   * 当 `disableSave()` 已启用时，仅 error 级别继续落盘
   */
  private static writeLog(level: 'info' | 'warn' | 'error', tag: string, message: string): void {
    if (!Clog.SAVE_ENABLED && level !== 'error') {
      return;
    }
    if (Clog.DISABLE_NON_ERROR_SAVE && level !== 'error') {
      return;
    }
    const filePath = Clog.getFilePath(level);
    if (!filePath) {
      return;
    }
    const entry: LogEntry = { level, tag, message, time: Date.now() };
    Clog.BUFFER.push(entry);
    if (level === 'error' || Clog.BUFFER.length >= Clog.MAX_BUFFER_SIZE) {
      Clog.flush();
      return;
    }
    Clog.scheduleFlush();
  }

  /**
   * 打印信息日志
   * @param tag 标签
   * @param content 日志内容
   */
  public static info(tag: string, content: LogContent): void;
  /**
   * 打印信息日志
   * @param tag 标签
   * @param content1 第一个日志内容
   * @param content2 第二个日志内容
   */
  public static info(tag: string, content1: LogContent, content2: LogContent): void;
  public static info(tag: string, content1: LogContent, content2?: LogContent): void {
    if (content2 !== undefined) {
      const message1 = Clog.formatContent(content1);
      const message2 = Clog.formatContent(content2);
      const combinedMessage = message1 + ' ' + message2;
      hilog.info(Clog.LOG_DOMAIN, Clog.CHARACTECH_PREFIX, Clog.TWO_PLACEHOLDER_FORMAT, tag, combinedMessage);
      Clog.writeLog('info', tag, combinedMessage);
    } else {
      const message = Clog.formatContent(content1);
      hilog.info(Clog.LOG_DOMAIN, Clog.CHARACTECH_PREFIX, Clog.TWO_PLACEHOLDER_FORMAT, tag, message);
      Clog.writeLog('info', tag, message);
    }
  }



  /**
   * 打印警告日志
   * @param tag 标签
   * @param content 日志内容
   */
  public static warn(tag: string, content: LogContent): void;
  /**
   * 打印警告日志
   * @param tag 标签
   * @param content1 第一个日志内容
   * @param content2 第二个日志内容
   */
  public static warn(tag: string, content1: LogContent, content2: LogContent): void;
  public static warn(tag: string, content1: LogContent, content2?: LogContent): void {
    if (content2 !== undefined) {
      const message1 = Clog.formatContent(content1);
      const message2 = Clog.formatContent(content2);
      const combinedMessage = message1 + ' ' + message2;
      hilog.warn(Clog.LOG_DOMAIN, Clog.CHARACTECH_PREFIX, Clog.TWO_PLACEHOLDER_FORMAT, tag, combinedMessage);
      Clog.writeLog('warn', tag, combinedMessage);
    } else {
      const message = Clog.formatContent(content1);
      hilog.warn(Clog.LOG_DOMAIN, Clog.CHARACTECH_PREFIX, Clog.TWO_PLACEHOLDER_FORMAT, tag, message);
      Clog.writeLog('warn', tag, message);
    }
  }

  /**
   * 打印错误日志
   * @param tag 标签
   * @param content 日志内容
   */
  public static error(tag: string, content: LogContent): void;
  /**
   * 打印错误日志
   * @param tag 标签
   * @param content1 第一个日志内容
   * @param content2 第二个日志内容
   */
  public static error(tag: string, content1: LogContent, content2: LogContent): void;
  public static error(tag: string, content1: LogContent, content2?: LogContent): void {
    if (content2 !== undefined) {
      const message1 = Clog.formatContent(content1);
      const message2 = Clog.formatContent(content2);
      const combinedMessage = message1 + ' ' + message2;
      hilog.error(Clog.LOG_DOMAIN, Clog.CHARACTECH_PREFIX, Clog.TWO_PLACEHOLDER_FORMAT, tag, combinedMessage);
      Clog.writeLog('error', tag, combinedMessage);
    } else {
      const message = Clog.formatContent(content1);
      hilog.error(Clog.LOG_DOMAIN, Clog.CHARACTECH_PREFIX, Clog.TWO_PLACEHOLDER_FORMAT, tag, message);
      Clog.writeLog('error', tag, message);
    }
  }

  /**
   * 打印普通日志（使用info级别）
   * @param tag 标签
   * @param content 日志内容
   */
  public static log(tag: string, content: LogContent): void;
  /**
   * 打印普通日志（使用info级别）
   * @param tag 标签
   * @param content1 第一个日志内容
   * @param content2 第二个日志内容
   */
  public static log(tag: string, content1: LogContent, content2: LogContent): void;
  public static log(tag: string, content1: LogContent, content2?: LogContent): void {
    if (content2 !== undefined) {
      Clog.info(tag, content1, content2);
    } else {
      Clog.info(tag, content1);
    }
  }
}
