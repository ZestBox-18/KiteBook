/**
 * 日志工具类
 * 支持打印任意类型的内容：字符串、数字、对象、数组等
 *
 * @ author ZestBox
 * @ since 2025-09-10
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

/**
 * 支持的日志内容类型
 */
type LogContent = string | number | boolean | null | undefined | object | Array<LogContent>;

interface LogEntry {
  level: 'info' | 'warn' | 'error';
  tag: string;
  message: string;
  time: number;
}

interface WriteOptions {
  offset: number;
  encoding: string;
}


export class Clog {
  private static CHARACTECH_PREFIX: string = '[Charactech]';
  private static LOG_DOMAIN = 0x0fff;
  private static SAVE_DIR?: string;
  private static DISABLE_NON_ERROR_SAVE: boolean = false;

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
   * 关闭除 error 外的落盘
   * 调用后：info/warn 不再写入本地文件；error 仍会写入
   * 不会清空或删除已有目录与文件
   */
  public static disableSave(): void {
    Clog.DISABLE_NON_ERROR_SAVE = true;
  }

  /**
   * 开启所有级别落盘
   * 调用后：info/warn/error 均会写入对应文件及汇总文件（在目录已配置的情况下）
   */
  public static enableSave(): void {
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
  private static getFilePath(level: 'info' | 'warn' | 'error'): string | undefined {
    if (!Clog.SAVE_DIR) {
      return undefined;
    }
    return `${Clog.SAVE_DIR}/clog_${level}.json`;
  }

  /**
   * 返回汇总日志文件路径（包含 info/warn/error 的合并内容）
   * 未配置保存目录时返回 undefined
   */
  private static getCombinedFilePath(): string | undefined {
    if (!Clog.SAVE_DIR) {
      return undefined;
    }
    return `${Clog.SAVE_DIR}/clog_all.json`;
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

  /**
   * 将数据写入文件并关闭文件
   * 以 JSON 数组形式维护文件：
   * - 空文件写入为 `[{...}]`
   * - 非空文件在末尾 `]` 前插入 `,{...}]`
   */
  private static writeStr(path: string, str: string): number {
    const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    let offset = fs.statSync(file.fd).size;
    if (offset === 0) {
      str = `[${str}]`;
    } else {
      offset = offset - 1;
      str = `,${str}]`;
    }
    const options: WriteOptions = { offset: offset, encoding: 'utf-8' };
    const result = fs.writeSync(file.fd, str, options);
    fs.closeSync(file);
    return result;
  }

  /**
   * 根据开关与级别将日志写入对应文件及汇总文件
   * 当 `disableSave()` 已启用时，仅 `error` 级别会落盘
   */
  private static writeLog(level: 'info' | 'warn' | 'error', tag: string, message: string): void {
    if (Clog.DISABLE_NON_ERROR_SAVE && level !== 'error') {
      return;
    }
    const filePath = Clog.getFilePath(level);
    if (!filePath) {
      return;
    }
    const entry: LogEntry = { level, tag, message, time: Date.now() };
    const json = JSON.stringify(entry);
    Clog.writeStr(filePath, json);

    const allPath = Clog.getCombinedFilePath();
    if (allPath) {
      Clog.writeStr(allPath, json);
    }
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