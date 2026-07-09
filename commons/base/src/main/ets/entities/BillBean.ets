/**
 * Copyright (C), 2025-05-13
 * @author ZestBox
 * @date 2025/05/13
 * @version 1.0
 * @description: 账单数据模型
 */

/**
 * 账单类型枚举
 */
export enum BillTypeEnum {
  EXPENSE = 'expense', // 支出
  INCOME = 'income', // 收入
  TRANSFER = 'transfer' // 转账
}

/**
 * 账单数据实体
 */
export class BillBean {
  id: number = 0;
  uuid: string = '';
  remoteId: string = '';
  ledgerId: number = 1;
  type: string = BillTypeEnum.EXPENSE;
  category: string = '';
  categoryIconKey: string = '';
  amount: number = 0;
  account: string = '';
  accountId: number = 0;
  targetAccount: string = '';
  targetAccountId: number = 0;
  paidByMemberId: number = 1;
  createdByMemberId: number = 1;
  splitMode: string = 'none';
  affectAsset: boolean = true;
  currency: string = 'CNY';
  date: number = 0;
  remark: string = '';
  syncStatus: string = 'pending';
  syncVersion: number = 0;
  deletedAt: number = 0;
  createdAt: number = 0;
  updatedAt: number = 0;

  /**
   * 获取分类图标
   */
  getCategoryIcon(): Resource {
    const iconMap: Record<string, Resource> = {
      'fork_knife': $r('sys.symbol.fork_knife'),
      'car': $r('sys.symbol.car'),
      'cart': $r('sys.symbol.cart'),
      'gamecontroller': $r('sys.symbol.gamecontroller'),
      'house': $r('sys.symbol.house'),
      'cross_case': $r('sys.symbol.cross_case'),
      'book': $r('sys.symbol.book'),
      'creditcard': $r('sys.symbol.creditcard'),
      'gift': $r('sys.symbol.gift'),
      'arrow_up_circle': $r('sys.symbol.arrow_up_circle'),
      'ellipsis_circle': $r('sys.symbol.ellipsis_circle'),
      'arrow_left_arrow_right': $r('sys.symbol.arrow_left_arrow_right'),
      '餐饮': $r('sys.symbol.fork_knife'),
      '交通': $r('sys.symbol.car'),
      '购物': $r('sys.symbol.cart'),
      '娱乐': $r('sys.symbol.gamecontroller'),
      '住房': $r('sys.symbol.house'),
      '医疗': $r('sys.symbol.cross_case'),
      '教育': $r('sys.symbol.book'),
      '工资': $r('sys.symbol.creditcard'),
      '奖金': $r('sys.symbol.gift'),
      '理财': $r('sys.symbol.creditcard'),
      '其他': $r('sys.symbol.ellipsis_circle')
    };
    if (this.categoryIconKey.length > 0) {
      const categoryIcon: Resource | undefined = iconMap[this.categoryIconKey];
      if (categoryIcon !== undefined) {
        return categoryIcon;
      }
    }
    return iconMap[this.category] ?? $r('sys.symbol.ellipsis_circle');
  }

  /**
   * 格式化金额显示
   */
  formatAmount(): string {
    if (this.type === BillTypeEnum.TRANSFER) {
      return `¥${this.amount.toFixed(2)}`;
    }
    const prefix = this.type === BillTypeEnum.EXPENSE ? '-' : '+';
    return `${prefix}${this.amount.toFixed(2)}`;
  }

  /**
   * 获取账单展示使用的账户文案。
   */
  getAccountDisplayText(): string {
    if (this.type === BillTypeEnum.TRANSFER && this.targetAccount.trim().length > 0) {
      return `${this.account} -> ${this.targetAccount}`;
    }
    return this.account;
  }

  /**
   * 获取日期字符串
   */
  getDateString(): string {
    const date = new Date(this.date);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${month}-${day}`;
  }

  /**
   * 获取时间字符串
   */
  getTimeString(): string {
    const date = new Date(this.date);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
}

/**
 * 按日期分组的账单列表
 */
export class BillGroup {
  date: string = '';
  dateTimestamp: number = 0;
  totalExpense: number = 0;
  totalIncome: number = 0;
  bills: BillBean[] = [];
}
