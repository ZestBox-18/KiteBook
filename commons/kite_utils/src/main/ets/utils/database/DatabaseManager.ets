/**
 * 关系型数据库relationalStore管理工具类
 *
 * @ author ZestBox
 * @ since 2025-09-10
 */

import { relationalStore } from "@kit.ArkData";
import { USERDATA_DATABASE_CONFIG, DatabaseUpgradeSql } from "./Config";
import { BusinessError } from '@kit.BasicServicesKit';
import { Clog } from "../clog/Clog";

const TAG: string = '[DatabaseManager]';

/**
 * 数据库回调接口
 */
interface DatabaseCallbacks {
  /** 数据库初始化完成回调（首次创建数据库时调用） */
  onDatabaseInitialized?: () => void | Promise<void>;
  /** 数据库升级完成回调（数据库版本升级后调用） */
  onDatabaseUpgraded?: (fromVersion: number, toVersion: number) => void | Promise<void>;
  /** 数据库版本一致回调（当前版本与目标版本一致，无需任何操作时调用） */
  onDatabaseVersionConsistent?: (currentVersion: number) => void | Promise<void>;
}

class DatabaseManager {
  private dbContext?: Context;
  public dbStore?: relationalStore.RdbStore
  private dbConfig:USERDATA_DATABASE_CONFIG = new USERDATA_DATABASE_CONFIG()
  private callbacks?: DatabaseCallbacks

  init(context: Context) {
    this.dbContext = context;
  }

  /**
   * 设置数据库回调函数
   * @param callbacks 回调函数配置
   */
  setCallbacks(callbacks: DatabaseCallbacks): void {
    this.callbacks = callbacks;
  }

  /**
   * 检查数据库状态并执行相应的初始化或升级操作
   */
  private async checkDatabaseState(): Promise<void> {
    if (!this.dbStore) {
      throw new Error('数据库存储对象未初始化');
    }

    const currentVersion = this.dbStore.version;
    const targetVersion = this.dbConfig.getConfigVersion();
    
    Clog.log(TAG,`当前数据库版本: ${currentVersion}, 目标版本: ${targetVersion}`);

    try {
      if (currentVersion === 0) {
        // 首次安装，直接创建最新版本的表结构
        await this.initializeDatabase();
      } else if (currentVersion < targetVersion) {
        // 需要升级
        await this.upgradeDatabase(currentVersion, targetVersion);
      } else if (currentVersion > targetVersion) {
        // 版本回退，这种情况通常不应该发生
        Clog.warn(TAG,`数据库版本 ${currentVersion} 高于目标版本 ${targetVersion}，可能存在版本回退`);
      } else {
        // 版本一致，无需操作
        Clog.log(TAG,'数据库版本已是最新，无需升级');
        // 调用数据库版本一致回调
        if (this.callbacks?.onDatabaseVersionConsistent) {
          try {
            await this.callbacks.onDatabaseVersionConsistent(currentVersion);
            Clog.log(TAG,'数据库版本一致回调执行完成');
          } catch (callbackError) {
            Clog.error(TAG,'数据库版本一致回调执行失败:', callbackError);
          }
        }
      }
    } catch (error) {
      Clog.error(TAG,'数据库状态检查失败:', error);
      const err = error as Error;
      throw new Error(`数据库状态检查失败: ${err.message}`);
    }
  }

  /**
   * 初始化数据库（首次安装，带事务支持）
   */
  private async initializeDatabase(): Promise<void> {
    Clog.log(TAG,'检测到版本号为0，开始初始化数据库');
    
    // 开始事务
    await this.dbStore!.beginTransaction();
    Clog.log(TAG,'数据库初始化事务已开始');
    
    try {
      const createTableSql = this.dbConfig.getCreateTableSql();
      if (createTableSql) {
        const tableNames = Object.keys(createTableSql);

        for (const tableName of tableNames) {
          try {
            Clog.log(TAG,`正在创建 ${tableName} 表...`);
            await this.dbStore!.executeSql(createTableSql[tableName]);
            Clog.log(TAG,`${tableName} 表创建成功`);
          } catch (error) {
            const err = error as BusinessError;
            Clog.error(TAG,`创建 ${tableName} 表失败. Code:${err.code}, message:${err.message}`);
            throw new Error(`创建 ${tableName} 表失败: ${err.message}`);
          }
        }
      }
      
      // 更新数据库版本
      this.dbStore!.version = this.dbConfig.getConfigVersion();
      
      // 提交事务
      await this.dbStore!.commit();
      Clog.log(TAG,`数据库初始化完成，版本更新为: ${this.dbStore!.version}，事务已提交`);
      
      // 调用初始化完成回调
      if (this.callbacks?.onDatabaseInitialized) {
        try {
          await this.callbacks.onDatabaseInitialized();
          Clog.log(TAG,'数据库初始化回调执行完成');
        } catch (callbackError) {
          Clog.error(TAG,'数据库初始化回调执行失败:', callbackError);
        }
      }
      
    } catch (error) {
      Clog.error(TAG,'数据库初始化失败，回滚事务:', error);
      try {
        await this.dbStore!.rollBack();
        Clog.log(TAG,'数据库初始化事务已回滚');
      } catch (rollbackError) {
        const rollbackErr = rollbackError as BusinessError;
        Clog.error(TAG,`事务回滚失败. Code:${rollbackErr.code}, message:${rollbackErr.message}`);
      }
      const err = error as Error;
      throw new Error(`数据库初始化失败: ${err.message}`);
    }
  }

  /**
   * 升级数据库（带事务支持）
   * @param currentVersion 当前版本
   * @param targetVersion 目标版本
   */
  private async upgradeDatabase(currentVersion: number, targetVersion: number): Promise<void> {
    Clog.log(TAG,`开始数据库升级: ${currentVersion} -> ${targetVersion}`);
    
    // 开始事务
    await this.dbStore!.beginTransaction();
    Clog.log(TAG,'数据库升级事务已开始');
    
    try {
      const upgradeSqls = this.dbConfig.getUpgradeSqlsForVersion(currentVersion);
      
      if (upgradeSqls.length === 0) {
        Clog.log(TAG,'无需执行升级脚本');
        await this.dbStore!.commit();
        Clog.log(TAG,'空升级事务已提交');
        return;
      }
      
      for (const script of upgradeSqls) {
        await this.executeUpgradeScript(script);
      }
      
      // 更新数据库版本
      this.dbStore!.version = targetVersion;
      
      // 提交事务
      await this.dbStore!.commit();
      Clog.log(TAG,`数据库升级完成，版本更新为: ${targetVersion}，事务已提交`);
      
      // 调用升级完成回调
      if (this.callbacks?.onDatabaseUpgraded) {
        try {
          await this.callbacks.onDatabaseUpgraded(currentVersion, targetVersion);
          Clog.log(TAG,'数据库升级回调执行完成');
        } catch (callbackError) {
          Clog.error(TAG,'数据库升级回调执行失败:', callbackError);
        }
      }
      
    } catch (error) {
      Clog.error(TAG,'数据库升级失败，回滚事务:', error);
      try {
        await this.dbStore!.rollBack();
        Clog.log(TAG,'数据库升级事务已回滚');
      } catch (rollbackError) {
        const rollbackErr = rollbackError as BusinessError;
        Clog.error(TAG,`事务回滚失败. Code:${rollbackErr.code}, message:${rollbackErr.message}`);
      }
      const err = error as Error;
      throw new Error(`数据库升级失败: ${err.message}`);
    }
  }

  /**
   * 执行单个升级脚本
   * @param script 升级脚本
   */
  private async executeUpgradeScript(script: DatabaseUpgradeSql): Promise<void> {
    Clog.log(TAG,`执行升级脚本: ${script.fromVersion} -> ${script.toVersion}`);
    
    if (script.description) {
      Clog.log(TAG,`升级描述: ${script.description}`);
    }
    
    for (let i = 0; i < script.sql.length; i++) {
      const sqlStatement = script.sql[i];
      try {
        Clog.log(TAG,`执行SQL语句 ${i + 1}/${script.sql.length}: ${sqlStatement.substring(0, 100)}...`);
        await this.dbStore!.executeSql(sqlStatement);
        Clog.log(TAG,`SQL语句 ${i + 1} 执行成功`);
      } catch (error) {
        const err = error as BusinessError;
        Clog.error(TAG,`SQL语句执行失败. Code:${err.code}, message:${err.message}`);
        Clog.error(TAG,`失败的SQL: ${sqlStatement}`);
        throw new Error(`SQL语句执行失败: ${err.message}`);
      }
    }
    
    Clog.log(TAG,`升级脚本 ${script.fromVersion} -> ${script.toVersion} 执行完成`);
  }

  /**
   * 创建数据库存储对象
   */
  createDatabaseStore(): Promise<relationalStore.RdbStore> {
    return new Promise<relationalStore.RdbStore>((resolve, reject) => {
      relationalStore.getRdbStore(this.dbContext, this.dbConfig.getConfig(), async (err, store) => {
        if (err) {
          Clog.error(TAG,`获取关系数据库管理对象失败. Code:${err.code}, message:${err.message}`);
          reject(err);
          return;
        }
        
        this.dbStore = store;
        Clog.log(TAG,'关系型数据库对象创建成功');
        
        try {
          await this.checkDatabaseState();
          resolve(store);
        } catch (error) {
          Clog.error(TAG,'数据库状态检查失败:', error);
          reject(error);
        }
      });
    });
  }
}

export let dbManager = new DatabaseManager()
export { DatabaseCallbacks }