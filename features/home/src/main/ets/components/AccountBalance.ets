/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 账户余额组件
 */

import { formatAmount } from '../utils/HomeDataHelper';

@ComponentV2
export struct AccountBalance {
  @Param accountBalance: number = 0;

  build() {
    Row() {
      Text('账户余额')
        .fontSize(14)
        .fontColor($r('sys.color.font_primary'))

      Blank()

      Text('¥' + formatAmount(this.accountBalance))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
  }
}
