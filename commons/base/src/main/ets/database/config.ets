import { DatabaseUpgradeSql, dbManager, initDatabaseConfig, Clog } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';

const TAG: string = '[DatabaseConfig]';

/**
 * 数据库升级脚本配置
 * 注意：确保升级路径的连续性，每个版本都要有对应的升级脚本
 */
const upgradeSqls: DatabaseUpgradeSql[] = [
  {
    fromVersion: 1,
    toVersion: 2,
    sql: [
      // 账单表
      `CREATE TABLE IF NOT EXISTS bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        account TEXT NOT NULL,
        date INTEGER NOT NULL,
        remark TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      
      // 分类预算表
      `CREATE TABLE IF NOT EXISTS budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        month TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      
      // 账户余额表
      `CREATE TABLE IF NOT EXISTS accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      
      // 创建索引
      `CREATE INDEX IF NOT EXISTS idx_bills_date ON bills(date)`,
      `CREATE INDEX IF NOT EXISTS idx_bills_category ON bills(category)`,
      `CREATE INDEX IF NOT EXISTS idx_budgets_month ON budgets(month)`
    ]
  }
];

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
    version: 2,
    upgradeSqls: upgradeSqls
  });

  // 设置数据库回调
  dbManager.setCallbacks({
    onDatabaseInitialized: async (): Promise<void> => {
      Clog.info(TAG, '数据库首次创建完成');
    },
    onDatabaseUpgraded: async (fromVersion: number, toVersion: number): Promise<void> => {
      Clog.info(TAG, `数据库升级完成: ${fromVersion} -> ${toVersion}`);
    },
    onDatabaseVersionConsistent: async (version: number): Promise<void> => {
      Clog.info(TAG, `数据库版本一致: ${version}`);
    }
  });

  dbManager.init(context);
  dbManager.createDatabaseStore();
}
