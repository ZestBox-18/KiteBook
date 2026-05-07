/**
 * Copyright (C), 2026-05-06
 * @author ZestBox
 * @date 2026/05/06
 * @version 1.0
 * @description: 报表主页面
 */

import { IncomeExpenseReport } from './IncomeExpenseReport';
import { CategoryReport } from './CategoryReport';
import { AssetReport } from './AssetReport';
import { BudgetReport } from './BudgetReport';

interface TabItem {
  label: Resource;
  icon: string;
}

@Entry
@ComponentV2
export struct Index {
  @Local currentTabIndex: number = 0;
  
  private readonly TABS: TabItem[] = [
    { label: $r('app.string.reports_income_expense'), icon: '📊' },
    { label: $r('app.string.reports_category'), icon: '📈' },
    { label: $r('app.string.reports_asset'), icon: '💰' },
    { label: $r('app.string.reports_budget'), icon: '📋' }
  ];
  
  build() {
    Column() {
      this.TabSelector();
      this.ContentArea();
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
  
  @Builder
  TabSelector() {
    Row() {
      ForEach(this.TABS, (tab: TabItem, index: number) => {
        Column() {
          Text(tab.icon)
            .fontSize(20)
          Text(tab.label)
            .fontSize(12)
            .fontColor(this.currentTabIndex === index ? '#2196F3' : '#757575')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
        .backgroundColor(this.currentTabIndex === index ? '#E3F2FD' : '#FFFFFF')
        .borderRadius(8)
        .onClick(() => {
          this.currentTabIndex = index;
        })
      }, (tab: TabItem, index: number) => index.toString())
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })
  }
  
  @Builder
  ContentArea() {
    Stack() {
      if (this.currentTabIndex === 0) {
        IncomeExpenseReport()
      } else if (this.currentTabIndex === 1) {
        CategoryReport()
      } else if (this.currentTabIndex === 2) {
        AssetReport()
      } else if (this.currentTabIndex === 3) {
        BudgetReport()
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
