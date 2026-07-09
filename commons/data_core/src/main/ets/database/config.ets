import { dbManager, initDatabaseConfig, Clog } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';
import { AccountManager } from '../services/AccountManager';
import { CategoryManager } from '../services/CategoryManager';
import { LedgerManager } from '../services/LedgerManager';

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
      "ledgers": `CREATE TABLE IF NOT EXISTS ledgers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL DEFAULT '',
        remote_id TEXT DEFAULT '',
        name TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'personal',
        icon TEXT DEFAULT 'book',
        description TEXT DEFAULT '',
        currency TEXT NOT NULL DEFAULT 'CNY',
        owner_user_id TEXT DEFAULT 'local_user',
        is_current INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        sync_version INTEGER NOT NULL DEFAULT 0,
        deleted_at INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      "ledger_members": `CREATE TABLE IF NOT EXISTS ledger_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL DEFAULT '',
        remote_id TEXT DEFAULT '',
        ledger_id INTEGER NOT NULL,
        user_id TEXT DEFAULT '',
        display_name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'owner',
        status TEXT NOT NULL DEFAULT 'active',
        is_local_only INTEGER NOT NULL DEFAULT 1,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        sync_version INTEGER NOT NULL DEFAULT 0,
        deleted_at INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      "accounts": `CREATE TABLE IF NOT EXISTS accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL DEFAULT '',
        remote_id TEXT DEFAULT '',
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        owner_type TEXT NOT NULL DEFAULT 'user',
        owner_id TEXT NOT NULL DEFAULT 'local_user',
        ledger_id INTEGER NOT NULL DEFAULT 1,
        currency TEXT NOT NULL DEFAULT 'CNY',
        sync_status TEXT NOT NULL DEFAULT 'pending',
        sync_version INTEGER NOT NULL DEFAULT 0,
        deleted_at INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      "bills": `CREATE TABLE IF NOT EXISTS bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL DEFAULT '',
        remote_id TEXT DEFAULT '',
        ledger_id INTEGER NOT NULL DEFAULT 1,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        account_id INTEGER NOT NULL DEFAULT 0,
        target_account_id INTEGER NOT NULL DEFAULT 0,
        paid_by_member_id INTEGER NOT NULL DEFAULT 1,
        created_by_member_id INTEGER NOT NULL DEFAULT 1,
        split_mode TEXT NOT NULL DEFAULT 'none',
        affect_asset INTEGER NOT NULL DEFAULT 1,
        currency TEXT NOT NULL DEFAULT 'CNY',
        date INTEGER NOT NULL,
        remark TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        sync_version INTEGER NOT NULL DEFAULT 0,
        deleted_at INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      "bill_splits": `CREATE TABLE IF NOT EXISTS bill_splits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL DEFAULT '',
        remote_id TEXT DEFAULT '',
        bill_id INTEGER NOT NULL,
        ledger_id INTEGER NOT NULL,
        member_id INTEGER NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        ratio REAL NOT NULL DEFAULT 0,
        shares REAL NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        sync_version INTEGER NOT NULL DEFAULT 0,
        deleted_at INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      "budgets": `CREATE TABLE IF NOT EXISTS budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL DEFAULT '',
        remote_id TEXT DEFAULT '',
        ledger_id INTEGER NOT NULL DEFAULT 1,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        month TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        sync_version INTEGER NOT NULL DEFAULT 0,
        deleted_at INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      "categories": `CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL DEFAULT '',
        remote_id TEXT DEFAULT '',
        ledger_id INTEGER NOT NULL DEFAULT 1,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_system INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        sync_version INTEGER NOT NULL DEFAULT 0,
        deleted_at INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )`,
      "idx_ledgers_current": `CREATE INDEX IF NOT EXISTS idx_ledgers_current ON ledgers(is_current, deleted_at)`,
      "idx_ledger_members_ledger": `CREATE INDEX IF NOT EXISTS idx_ledger_members_ledger ON ledger_members(ledger_id, status, deleted_at)`,
      "idx_accounts_owner": `CREATE INDEX IF NOT EXISTS idx_accounts_owner ON accounts(owner_type, owner_id, deleted_at)`,
      "idx_accounts_ledger": `CREATE INDEX IF NOT EXISTS idx_accounts_ledger ON accounts(ledger_id, deleted_at)`,
      "idx_bills_ledger_date": `CREATE INDEX IF NOT EXISTS idx_bills_ledger_date ON bills(ledger_id, date, deleted_at)`,
      "idx_bills_category": `CREATE INDEX IF NOT EXISTS idx_bills_category ON bills(category, deleted_at)`,
      "idx_bill_splits_bill": `CREATE INDEX IF NOT EXISTS idx_bill_splits_bill ON bill_splits(bill_id, deleted_at)`,
      "idx_budgets_ledger_month": `CREATE INDEX IF NOT EXISTS idx_budgets_ledger_month ON budgets(ledger_id, month, deleted_at)`,
      "idx_categories_ledger_type_sort": `CREATE INDEX IF NOT EXISTS idx_categories_ledger_type_sort ON categories(ledger_id, type, sort_order, deleted_at)`
    },
    version: 1
  });

  dbManager.setCallbacks({
    onDatabaseInitialized: async (): Promise<void> => {
      Clog.info(TAG, '数据库首次创建完成');
      await LedgerManager.ensureDefaultLedger();
      await AccountManager.ensureDefaultAccounts();
      await CategoryManager.insertDefaultCategories();
    },
    onDatabaseVersionConsistent: async (version: number): Promise<void> => {
      Clog.info(TAG, `数据库版本一致: ${version}`);
      await LedgerManager.ensureDefaultLedger();
      await AccountManager.ensureDefaultAccounts();
    }
  });

  dbManager.init(context);
  dbManager.createDatabaseStore();
}
