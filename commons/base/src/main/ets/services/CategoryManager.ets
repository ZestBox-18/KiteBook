/**
 * Copyright (C), 2026-05-20
 * @author ZestBox
 * @date 2026/05/20
 * @version 1.0
 * @description: 分类数据库操作管理类
 */

import { dbManager, resultSet2Record, Clog } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { BillTypeEnum } from '../entities/BillBean';
import { CategoryBean } from '../entities/CategoryBean';

const TAG: string = '[CategoryManager]';
const TABLE_NAME: string = 'categories';
const BILL_TABLE_NAME: string = 'bills';

/**
 * 默认分类种子项，避免 ArkTS 对匿名对象字面量的限制。
 */
class CategorySeed {
  name: string = '';
  icon: string = '';

  constructor(name: string, icon: string) {
    this.name = name;
    this.icon = icon;
  }
}

/**
 * 分类数据库操作管理类，统一处理默认分类、查询以及新增编辑。
 */
export class CategoryManager {
  /**
   * 构建默认分类列表，用于新用户首次建库时写入初始化数据。
   */
  private static buildDefaultCategories(): CategoryBean[] {
    const expenseDefaults: CategorySeed[] = [
      new CategorySeed('餐饮', 'fork_knife'),
      new CategorySeed('交通', 'car'),
      new CategorySeed('购物', 'cart'),
      new CategorySeed('娱乐', 'gamecontroller'),
      new CategorySeed('住房', 'house'),
      new CategorySeed('医疗', 'cross_case'),
      new CategorySeed('教育', 'book'),
      new CategorySeed('其他', 'ellipsis_circle')
    ];
    const incomeDefaults: CategorySeed[] = [
      new CategorySeed('工资', 'creditcard'),
      new CategorySeed('奖金', 'gift'),
      new CategorySeed('理财', 'arrow_up_circle'),
      new CategorySeed('其他', 'ellipsis_circle')
    ];
    const categories: CategoryBean[] = [];

    expenseDefaults.forEach((item: CategorySeed, index: number) => {
      const category: CategoryBean = new CategoryBean();
      category.name = item.name;
      category.type = BillTypeEnum.EXPENSE;
      category.icon = item.icon;
      category.sortOrder = index;
      category.isSystem = true;
      categories.push(category);
    });

    incomeDefaults.forEach((item: CategorySeed, index: number) => {
      const category: CategoryBean = new CategoryBean();
      category.name = item.name;
      category.type = BillTypeEnum.INCOME;
      category.icon = item.icon;
      category.sortOrder = index;
      category.isSystem = true;
      categories.push(category);
    });

    return categories;
  }

  /**
   * 查询指定类型的分类列表，按排序号和主键稳定输出。
   */
  static async getCategoriesByType(type: string): Promise<CategoryBean[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('type', type);
    predicates.orderByAsc('sort_order');
    predicates.orderByAsc('id');

    return new Promise<CategoryBean[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          const categories: CategoryBean[] = rows.map((row: Record<string, object>) => {
            const category: CategoryBean = new CategoryBean();
            category.id = Number(row['id']);
            category.name = String(row['name']);
            category.type = String(row['type']);
            category.icon = String(row['icon']);
            category.sortOrder = Number(row['sort_order']);
            category.isSystem = Number(row['is_system']) === 1;
            category.createdAt = Number(row['created_at']);
            category.updatedAt = Number(row['updated_at']);
            return category;
          });
          Clog.info(TAG, `查询分类成功: type=${type}, count=${categories.length}`);
          resolve(categories);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询分类失败, code=${err.code}, msg=${err.message}`);
          reject([]);
        });
    });
  }

  /**
   * 查询全部分类，供账单显示和导出等场景复用。
   */
  static async getAllCategories(): Promise<CategoryBean[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByAsc('type');
    predicates.orderByAsc('sort_order');
    predicates.orderByAsc('id');

    return new Promise<CategoryBean[]>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          const categories: CategoryBean[] = rows.map((row: Record<string, object>) => {
            const category: CategoryBean = new CategoryBean();
            category.id = Number(row['id']);
            category.name = String(row['name']);
            category.type = String(row['type']);
            category.icon = String(row['icon']);
            category.sortOrder = Number(row['sort_order']);
            category.isSystem = Number(row['is_system']) === 1;
            category.createdAt = Number(row['created_at']);
            category.updatedAt = Number(row['updated_at']);
            return category;
          });
          resolve(categories);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询全部分类失败, code=${err.code}, msg=${err.message}`);
          reject([]);
        });
    });
  }

  /**
   * 按主键查询分类，供改名时同步历史账单使用。
   */
  static async getCategoryById(id: number): Promise<CategoryBean | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);

    return new Promise<CategoryBean | null>((resolve, reject) => {
      dbManager.dbStore?.query(predicates)
        .then((result) => {
          const rows = resultSet2Record(result) as Record<string, object>[];
          if (rows.length === 0) {
            resolve(null);
            return;
          }
          const row: Record<string, object> = rows[0];
          const category: CategoryBean = new CategoryBean();
          category.id = Number(row['id']);
          category.name = String(row['name']);
          category.type = String(row['type']);
          category.icon = String(row['icon']);
          category.sortOrder = Number(row['sort_order']);
          category.isSystem = Number(row['is_system']) === 1;
          category.createdAt = Number(row['created_at']);
          category.updatedAt = Number(row['updated_at']);
          resolve(category);
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 查询分类详情失败, code=${err.code}, msg=${err.message}`);
          reject(null);
        });
    });
  }

  /**
   * 新增一个自定义分类，并自动追加到同类型分类列表的尾部。
   */
  static async addCategory(name: string, type: string, icon: string = 'ellipsis_circle'): Promise<number> {
    const now: number = Date.now();
    const categories: CategoryBean[] = await CategoryManager.getCategoriesByType(type);
    const sortOrder: number = categories.length;
    const data: relationalStore.ValuesBucket = {
      name: name,
      type: type,
      icon: icon,
      sort_order: sortOrder,
      is_system: 0,
      created_at: now,
      updated_at: now
    };

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.insert(TABLE_NAME, data)
        .then((id: number) => {
          if (id === -1) {
            reject(-1);
          } else {
            resolve(id);
          }
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 新增分类失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 更新分类名称或图标，保持更新时间与数据库一致。
   */
  static async updateCategory(id: number, patch: Partial<CategoryBean>): Promise<number> {
    const originalCategory: CategoryBean | null = await CategoryManager.getCategoryById(id);
    if (originalCategory === null) {
      return -1;
    }
    const data: relationalStore.ValuesBucket = {
      updated_at: Date.now()
    };
    if (patch.name !== undefined) {
      data.name = patch.name;
    }
    if (patch.icon !== undefined) {
      data.icon = patch.icon;
    }
    if (patch.sortOrder !== undefined) {
      data.sort_order = patch.sortOrder;
    }

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);

    return new Promise<number>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then(async (num: number) => {
          if (num === -1) {
            reject(-1);
          } else {
            if (patch.name !== undefined && patch.name !== originalCategory.name) {
              await CategoryManager.renameBillsForCategory(originalCategory, patch.name);
            }
            resolve(num);
          }
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 更新分类失败, code=${err.code}, msg=${err.message}`);
          reject(-1);
        });
    });
  }

  /**
   * 分类改名后同步历史账单中的分类名称，避免列表和统计出现断层。
   */
  private static async renameBillsForCategory(category: CategoryBean, nextName: string): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(BILL_TABLE_NAME);
    predicates.equalTo('category', category.name);
    predicates.equalTo('type', category.type);
    const data: relationalStore.ValuesBucket = {
      category: nextName,
      updated_at: Date.now()
    };

    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.update(data, predicates)
        .then(() => {
          resolve();
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 同步账单分类名称失败, code=${err.code}, msg=${err.message}`);
          reject(err);
        });
    });
  }

  /**
   * 首次建库后写入默认分类，避免把分类定义散落在页面本地状态里。
   */
  static async insertDefaultCategories(): Promise<void> {
    const defaults: CategoryBean[] = CategoryManager.buildDefaultCategories();
    for (const category of defaults) {
      await CategoryManager.addSeedCategory(category);
    }
  }

  /**
   * 将默认分类以系统数据的方式插入数据库，供首次初始化时复用。
   */
  private static async addSeedCategory(category: CategoryBean): Promise<void> {
    const now: number = Date.now();
    const data: relationalStore.ValuesBucket = {
      name: category.name,
      type: category.type,
      icon: category.icon,
      sort_order: category.sortOrder,
      is_system: category.isSystem ? 1 : 0,
      created_at: now,
      updated_at: now
    };

    await new Promise<void>((resolve, reject) => {
      dbManager.dbStore?.insert(TABLE_NAME, data)
        .then((id: number) => {
          if (id === -1) {
            reject(-1);
          } else {
            resolve();
          }
        })
        .catch((err: BusinessError) => {
          console.error(`${TAG} 写入默认分类失败, code=${err.code}, msg=${err.message}`);
          reject(err);
        });
    });
  }
}
