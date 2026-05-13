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
  INCOME = 'income' // 收入
}

/**
 * 账单数据实体
 */
export class BillBean {
  id: number = 0;
  type: string = BillTypeEnum.EXPENSE;
  category: string = '';
  amount: number = 0;
  account: string = '';
  date: number = 0;
  remark: string = '';
  createdAt: number = 0;
  updatedAt: number = 0;

  /**
   * 获取分类图标
   */
  getCategoryIcon(): Resource {
    const iconMap: Record<string, Resource> = {
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
    return iconMap[this.category] ?? $r('sys.symbol.ellipsis_circle');
  }

  /**
   * 格式化金额显示
   */
  formatAmount(): string {
    const prefix = this.type === BillTypeEnum.EXPENSE ? '-' : '+';
    return `${prefix}${this.amount.toFixed(2)}`;
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
