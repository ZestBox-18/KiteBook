/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 最近账单卡片
 */

import { BillItem } from '../entities/BillItem';
import { BillItemRow } from './BillItemRow';

@ComponentV2
export struct RecentBillCard {
  @Param bills: BillItem[] = [];
  @Param onBillClick: (bill: BillItem) => void = () => {};
  @Param onBillDelete: (bill: BillItem) => void = () => {};
  @Param onViewAll: () => void = () => {};
  
  @Builder
  deleteButton(bill: BillItem) {
    Button('删除')
      .backgroundColor($r('app.color.expense'))
      .fontColor($r('sys.color.font_on_primary'))
      .onClick(() => {
        this.onBillDelete(bill);
      })
  }
  
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
      
      // 账单列表
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
        List() {
          ForEach(this.bills, (bill: BillItem, index: number) => {
            ListItem() {
              BillItemRow({ bill: bill })
            }
            .swipeAction({ end: this.deleteButton(bill) })
            .onClick(() => {
              this.onBillClick(bill);
            })
          })
        }
        .width('100%')
        .height(this.bills.length * 60)
        .divider({
          strokeWidth: 1,
          color: '#F0F0F0'
        })
      }
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
