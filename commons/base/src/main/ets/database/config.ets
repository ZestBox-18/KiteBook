import { DatabaseUpgradeSql, dbManager, initDatabaseConfig } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';

/**
 * 数据库升级脚本配置
 * 注意：确保升级路径的连续性，每个版本都要有对应的升级脚本
 */
const upgradeSqls: DatabaseUpgradeSql[] = [];

/**
 * 初始化数据库管理器
 * @param context 应用上下文
 */
export function dbManagerInit(context: Context): void {
  initDatabaseConfig({
    dbName: 'KiteBook_db',
    SecurityLevel: relationalStore.SecurityLevel.S3,
    dbSql: {
      "test": `CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        device TEXT NOT NULL
      );`
    },
    version: 1,
    upgradeSqls: upgradeSqls
  });

  dbManager.init(context);
  dbManager.createDatabaseStore();
}
