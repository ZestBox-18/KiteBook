/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 时间轴账单卡片组件
 */

import { BillItem } from '../entities/BillItem';
import { TimelineBillList } from './TimelineBillList';

@ComponentV2
export struct TimelineBillCard {
  @Param bills: BillItem[] = [];
  @Param onBillClick: (bill: BillItem) => void = () => {};
  @Param onBillDelete: (bill: BillItem) => void = () => {};
  @Param onViewAll: () => void = () => {};

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('最近账单')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Blank()

        Text('查看全部')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .onClick(() => {
            this.onViewAll();
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 时间轴账单列表
      TimelineBillList({
        bills: this.bills,
        onBillClick: this.onBillClick,
        onBillDelete: this.onBillDelete
      })
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding(20)
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
  }
}
