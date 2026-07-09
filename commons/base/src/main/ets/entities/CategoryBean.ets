/**
 * Copyright (C), 2026-05-20
 * @author ZestBox
 * @date 2026/05/20
 * @version 1.0
 * @description: 分类数据实体
 */

import { BillTypeEnum } from './BillBean';

/**
 * 分类数据实体，负责承载数据库中的分类记录。
 */
export class CategoryBean {
  id: number = 0;
  uuid: string = '';
  remoteId: string = '';
  ledgerId: number = 1;
  name: string = '';
  type: string = BillTypeEnum.EXPENSE;
  icon: string = 'ellipsis_circle';
  sortOrder: number = 0;
  isSystem: boolean = false;
  syncStatus: string = 'pending';
  syncVersion: number = 0;
  deletedAt: number = 0;
  createdAt: number = 0;
  updatedAt: number = 0;

  /**
   * 将数据库中的图标标识映射为 ArkUI 可直接使用的系统图标资源。
   */
  getIconResource(): Resource {
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
      'arrow_left_arrow_right': $r('sys.symbol.arrow_left_arrow_right')
    };
    return iconMap[this.icon] ?? $r('sys.symbol.ellipsis_circle');
  }
}
