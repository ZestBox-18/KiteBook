/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页周账单列表区组件
 */

import { AppThemeState, BillBean, BillGroup } from 'base';
import { curves } from '@kit.ArkUI';
import { BillItemComponent } from './BillItemComponent';
import { DeleteSwipeButtonComponent } from './DeleteSwipeButtonComponent';
import { EmptyStateComponent } from './EmptyStateComponent';

const GRADIENT_DELAY: number = 80;

@ComponentV2
export struct WeeklyBillListSectionComponent {
  @Param themeState: AppThemeState = new AppThemeState();
  @Param isAmountSortMode: boolean = false;
  @Param sortedWeekBills: BillBean[] = [];
  @Param sortedWeekBillGroups: BillGroup[] = [];
  @Param billSortModeText: string = '';
  @Param onDeleteBill: (billId: number) => void = (_billId: number) => {
  };
  @Param formatDateTitle: (dateStr: string) => string = (dateStr: string): string => {
    return dateStr;
  };
  @Param formatGroupTurnover: (group: BillGroup) => string = (_group: BillGroup): string => {
    return '';
  };

  /**
   * 构建周账单列表区，支持扁平排序和按天分组两种展示方式。
   */
  build() {
    if (this.sortedWeekBills.length === 0 && this.sortedWeekBillGroups.length === 0) {
      ListItem() {
        EmptyStateComponent({ text: '本周暂无账单记录', themeState: this.themeState })
      }
    } else if (this.isAmountSortMode) {
      ListItemGroup({
        header: this.FlatListHeader(),
        style: ListItemGroupStyle.CARD
      }) {
        ForEach(this.sortedWeekBills, (bill: BillBean, billIndex: number) => {
          ListItem() {
            BillItemComponent({ bill: bill, themeState: this.themeState })
          }
          .opacity(1)
          .translate({ x: 0 })
          .animation({
            duration: 300,
            delay: billIndex * GRADIENT_DELAY,
            curve: curves.springMotion(0.6, 0.9)
          })
          .swipeAction({
            end: this.DeleteSwipeBuilder(bill.id)
          })
        }, (bill: BillBean) => `${bill.id}`)
      }
      .divider({
        strokeWidth: 0.5,
        color: this.themeState.compDivider,
        startMargin: 52,
        endMargin: 16
      })
    } else {
      ForEach(this.sortedWeekBillGroups, (group: BillGroup, groupIndex: number) => {
        ListItemGroup({
          header: this.GroupHeader(group),
          style: ListItemGroupStyle.CARD
        }) {
          ForEach(group.bills, (bill: BillBean, billIndex: number) => {
            ListItem() {
              BillItemComponent({ bill: bill, themeState: this.themeState })
            }
            .opacity(1)
            .translate({ x: 0 })
            .animation({
              duration: 300,
              delay: (groupIndex * 3 + billIndex) * GRADIENT_DELAY,
              curve: curves.springMotion(0.6, 0.9)
            })
            .swipeAction({
              end: this.DeleteSwipeBuilder(bill.id)
            })
          }, (bill: BillBean) => `${group.date}-${bill.id}`)
        }
        .divider({
          strokeWidth: 0.5,
          color: this.themeState.compDivider,
          startMargin: 52,
          endMargin: 16
        })
      }, (group: BillGroup) => group.date)
    }
  }

  @Builder
  /**
   * 构建右滑删除操作按钮。
   */
  private DeleteSwipeBuilder(billId: number) {
    DeleteSwipeButtonComponent({
      onDelete: () => {
        this.onDeleteBill(billId);
      }
    })
  }

  @Builder
  /**
   * 构建按金额排序时使用的列表头部。
   */
  private FlatListHeader() {
    Row() {
      Text('最近 7 天')
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Text(this.billSortModeText)
        .fontSize(12)
        .fontColor(this.themeState.brand)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
  }

  @Builder
  /**
   * 构建按日期分组时的分组头部。
   */
  private GroupHeader(group: BillGroup) {
    Row() {
      Text(this.formatDateTitle(group.date))
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontSecondary)
      Text(this.formatGroupTurnover(group))
        .fontSize(12)
        .fontColor(this.themeState.brand)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
  }
}
