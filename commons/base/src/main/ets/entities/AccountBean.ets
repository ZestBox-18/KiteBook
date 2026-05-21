/**
 * Copyright (C), 2026-05-21
 * @author ZestBox
 * @date 2026/05/21
 * @version 1.0
 * @description: 账户数据实体
 */

export enum AccountTypeEnum {
  ASSET = 'asset',
  LIABILITY = 'liability'
}

/**
 * 账户数据实体，负责承载数据库中的账户记录。
 */
export class AccountBean {
  id: number = 0;
  name: string = '';
  balance: number = 0;
  type: string = AccountTypeEnum.ASSET;
  icon: string = 'creditcard';
  createdAt: number = 0;
  updatedAt: number = 0;

  /**
   * 判断当前账户是否为负债账户。
   */
  isLiability(): boolean {
    return this.type === AccountTypeEnum.LIABILITY;
  }

  /**
   * 返回首页列表使用的账户副标题。
   */
  getSubtitleText(): string {
    if (this.isLiability()) {
      return '待还账户';
    }
    return '资金账户';
  }

  /**
   * 将数据库中的图标标识映射为 ArkUI 可直接使用的系统图标资源。
   */
  getIconResource(): Resource {
    const iconMap: Record<string, Resource> = {
      'creditcard': $r('sys.symbol.creditcard'),
      'house': $r('sys.symbol.house'),
      'arrow_up_circle': $r('sys.symbol.arrow_up_circle'),
      'ellipsis_circle': $r('sys.symbol.ellipsis_circle')
    };
    return iconMap[this.icon] ?? $r('sys.symbol.creditcard');
  }
}
