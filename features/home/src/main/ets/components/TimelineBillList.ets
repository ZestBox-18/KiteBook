/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 时间轴账单列表组件
 */

import { BillItem } from '../entities/BillItem';
import { TimelineHeader } from './TimelineHeader';
import { TimelineBillItem } from './TimelineBillItem';

interface BillGroup {
  date: string;
  bills: BillItem[];
}

@ComponentV2
export struct TimelineBillList {
  @Param bills: BillItem[] = [];
  @Param onBillClick: (bill: BillItem) => void = () => {};
  @Param onBillDelete: (bill: BillItem) => void = () => {};

  build() {
    Column() {
      if (this.bills.length === 0) {
        Column() {
          Text('暂无账单记录')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))

          Text('点击下方快捷按钮开始记账')
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ top: 8 })
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.groupBillsByDate(), (group: BillGroup) => {
          Column() {
            TimelineHeader({
              date: group.date,
              billCount: group.bills.length
            })

            ForEach(group.bills, (bill: BillItem) => {
              TimelineBillItem({
                bill: bill,
                onBillClick: this.onBillClick,
                onBillDelete: this.onBillDelete
              })
            })
          }
          .width('100%')
        })
      }
    }
    .width('100%')
  }

  private groupBillsByDate(): BillGroup[] {
    const groups: Map<string, BillItem[]> = new Map();

    for (const bill of this.bills) {
      const date = this.formatDate(bill.date);
      if (!groups.has(date)) {
        groups.set(date, []);
      }
      groups.get(date)!.push(bill);
    }

    const result: BillGroup[] = [];
    groups.forEach((bills: BillItem[], date: string) => {
      const group: BillGroup = { date: date, bills: bills };
      result.push(group);
    });
    return result;
  }

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const billDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());

    if (billDate.getTime() === today.getTime()) {
      return '今天';
    } else if (billDate.getTime() === yesterday.getTime()) {
      return '昨天';
    } else {
      return `${date.getMonth() + 1}月${date.getDate()}日`;
    }
  }
}
