/**
 * 数据库配置类
 *
 * @ author ZestBox
 * @ since 2025-09-10
 */
import { relationalStore } from '@kit.ArkData';

/**
 * 数据库升级脚本接口
 */
export interface DatabaseUpgradeSql {
  /** 源版本号 */
  fromVersion: number;
  /** 目标版本号 */
  toVersion: number;
  /** 升级SQL语句数组，按顺序执行 */
  sql: string[];
  /** 升级脚本描述 */
  description?: string;
}

/**
 * 数据库配置接口
 */
interface DatabaseConfig {
  /** 数据库名称 */
  dbName: string;
  /** 安全级别 */
  SecurityLevel: relationalStore.SecurityLevel;
  /** 初始建表SQL语句 */
  dbSql?: Record<string, string>;
  /** 当前版本号 */
  version: number;
  /** 升级脚本数组 */
  upgradeSqls?: DatabaseUpgradeSql[];
}

let initConfig: DatabaseConfig

export function initDatabaseConfig(config: DatabaseConfig) {
  initConfig = config;
}

export class USERDATA_DATABASE_CONFIG {
  /**
   * 获取数据库存储配置
   */
  getConfig(): relationalStore.StoreConfig {
    let USERDATA_STORE_CONFIG: relationalStore.StoreConfig = {
      name: initConfig.dbName,
      securityLevel: initConfig.SecurityLevel,
    };
    return USERDATA_STORE_CONFIG
  }

  /**
   * 获取建表SQL语句
   */
  getCreateTableSql(): Record<string, string>|undefined {
    return initConfig.dbSql
  }

  /**
   * 获取配置版本号
   */
  getConfigVersion(): number {
    return initConfig.version
  }

  /**
   * 获取升级脚本数组
   */
  getUpgradeSqls(): DatabaseUpgradeSql[] {
    return initConfig.upgradeSqls || [];
  }

  /**
   * 根据当前版本获取需要执行的升级脚本
   * @param currentVersion 当前数据库版本
   * @returns 需要执行的升级脚本数组，按版本顺序排列
   */
  getUpgradeSqlsForVersion(currentVersion: number): DatabaseUpgradeSql[] {
    const scripts = this.getUpgradeSqls();
    const targetVersion = this.getConfigVersion();

    if (currentVersion >= targetVersion) {
      return [];
    }

    // 构建升级路径
    const upgradePath: DatabaseUpgradeSql[] = [];
    let nextVersion = currentVersion;

    while (nextVersion < targetVersion) {
      const script = scripts.find(s => s.fromVersion === nextVersion);
      if (!script) {
        throw new Error(`找不到从版本 ${nextVersion} 的升级脚本`);
      }
      upgradePath.push(script);
      nextVersion = script.toVersion;
    }

    return upgradePath;
  }
}
