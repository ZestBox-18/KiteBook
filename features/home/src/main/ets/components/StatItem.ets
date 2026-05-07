/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 统计项组件
 */

import { formatAmount } from '../utils/HomeDataHelper';

@ComponentV2
export struct StatItem {
  @Param label: string = '';
  @Param value: number = 0;
  @Param prefix: string = '';  // '+' | '-' | ''
  
  build() {
    Column() {
      Text(this.label)
        .fontSize(12)
        .fontColor($r('sys.color.font_secondary'))
      
      Text((this.prefix === '+' ? '+' : (this.prefix === '-' ? '-' : '')) + '¥' + formatAmount(Math.abs(this.value)))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(
          this.prefix === '+' ? $r('app.color.income') :
          this.prefix === '-' ? $r('app.color.expense') :
          $r('sys.color.font_primary')
        )
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }
}
