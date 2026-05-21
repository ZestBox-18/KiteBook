import { dbManager, initDatabaseConfig, Clog } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';
import { AccountManager } from '../services/AccountManager';
import { CategoryManager } from '../services/CategoryManager';

const TAG: string = '[DatabaseConfig]';

/**
 * 初始化数据库管理器
 * @param context 应用上下文
 */
export function dbManagerInit(context: Context): void {
  initDatabaseConfig({
    dbName: 'KiteBook_db',
    SecurityLevel: relationalStore.SecurityLevel.S3,
    dbSql: {
      // 账单表
      "bills": `CREATE TABLE IF NOT EXISTS bills (
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
      "budgets": `CREATE TABLE IF NOT EXISTS budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        month TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      // 账户余额表
      "accounts": `CREATE TABLE IF NOT EXISTS accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      // 分类表
      "categories": `CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_system INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      // 创建索引
      "idx_bills_date": `CREATE INDEX IF NOT EXISTS idx_bills_date ON bills(date)`,
      "idx_bills_category": `CREATE INDEX IF NOT EXISTS idx_bills_category ON bills(category)`,
      "idx_budgets_month": `CREATE INDEX IF NOT EXISTS idx_budgets_month ON budgets(month)`,
      "idx_categories_type_sort": `CREATE INDEX IF NOT EXISTS idx_categories_type_sort ON categories(type, sort_order)`
    },
    version: 1
  });

  // 设置数据库回调
  dbManager.setCallbacks({
    onDatabaseInitialized: async (): Promise<void> => {
      Clog.info(TAG, '数据库首次创建完成');
      await AccountManager.ensureDefaultAccounts();
      await CategoryManager.insertDefaultCategories();
    },
    onDatabaseUpgraded: async (fromVersion: number, toVersion: number): Promise<void> => {
      Clog.info(TAG, `数据库升级完成: ${fromVersion} -> ${toVersion}`);
      await AccountManager.ensureDefaultAccounts();
    },
    onDatabaseVersionConsistent: async (version: number): Promise<void> => {
      Clog.info(TAG, `数据库版本一致: ${version}`);
      await AccountManager.ensureDefaultAccounts();
    }
  });

  dbManager.init(context);
  dbManager.createDatabaseStore();
}
