/**
 * @ author ZestBox
 * @ since 2025-09-10
 */

import { DatabaseUpgradeSql, initDatabaseConfig } from './Config';
import { DatabaseCallbacks, dbManager } from './DatabaseManager';
import { relationalStore } from '@kit.ArkData';


/**
 * 数据库升级脚本配置
 * 注意：确保升级路径的连续性，每个版本都要有对应的升级脚本
 */
const upgradeSqls: DatabaseUpgradeSql[] = [
  {
    fromVersion: 1,
    toVersion: 2,
    description: '添加用户头像字段和最后登录时间',
    sql: [
      `CREATE TABLE IF NOT EXISTS user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        setting_key TEXT NOT NULL,
        setting_value TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, setting_key)
      );`,
    ]
  },
  {
    fromVersion: 2,
    toVersion: 3,
    description: '创建用户设置表和用户角色表',
    sql: [
      `CREATE TABLE IF NOT EXISTS user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        setting_key TEXT NOT NULL,
        setting_value TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, setting_key)
      );`,
      `CREATE TABLE IF NOT EXISTS user_roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        role_name TEXT NOT NULL,
        granted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        granted_by INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by) REFERENCES users(id)
      );`,
      'CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings(user_id);',
      'CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);',
      'CREATE INDEX IF NOT EXISTS idx_user_roles_role_name ON user_roles(role_name);'
    ]
  }
];

/**
 * 初始化数据库管理器
 * @param context 应用上下文
 */
export function dbManagerInit(context: Context): void {
  initDatabaseConfig({
    dbName: 'db_charactech',
    SecurityLevel: relationalStore.SecurityLevel.S3,
    dbSql: {
      "users": 'CREATE TABLE IF NOT EXISTS users (\n' +
        '    id INTEGER PRIMARY KEY AUTOINCREMENT,\n' +
        '    name TEXT NOT NULL,\n' +
        '    email TEXT UNIQUE NOT NULL,\n' +
        '    phone TEXT,\n' +
        '    age INTEGER,\n' +
        '    gender TEXT,\n' +
        '    address TEXT,\n' +
        '    avatar_url TEXT,\n' +
        '    last_login_at DATETIME,\n' +
        '    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,\n' +
        '    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP\n' +
        ');',
      "user_settings": `CREATE TABLE IF NOT EXISTS user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        setting_key TEXT NOT NULL,
        setting_value TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, setting_key)
      );`,
      "user_roles": `CREATE TABLE IF NOT EXISTS user_roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        role_name TEXT NOT NULL,
        granted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        granted_by INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by) REFERENCES users(id)
      );`
    },
    version: 3,
    upgradeSqls: upgradeSqls
  });

  // 设置数据库回调
  const callbacks: DatabaseCallbacks = {
    onDatabaseInitialized: async (): Promise<void> => {
      console.log('=== 数据库初始化完成回调 ===');
      console.log('数据库首次创建完成，可以执行初始化操作');
    },
    onDatabaseUpgraded: async (fromVersion: number, toVersion: number): Promise<void> => {
      console.log('=== 数据库升级完成回调 ===');
      console.log(`数据库升级完成: ${fromVersion} -> ${toVersion}`);
      console.log('可以在这里执行升级后的清理或初始化操作');
    },
    onDatabaseVersionConsistent: async (currentVersion: number): Promise<void> => {
      console.log('=== 数据库版本一致回调 ===');
      console.log(`当前数据库版本已是最新，无需操作，版本: ${currentVersion}`);
    }
  };

  dbManager.setCallbacks(callbacks);
  dbManager.init(context);
  dbManager.createDatabaseStore();
}