/**
 * Copyright (C), 2026-07-03
 * @author ZestBox
 * @date 2026/07/03
 * @version 1.0
 * @description: 首页金额展示格式化工具
 */

export class HomeAmountFormatter {
  /**
   * 将金额格式化为两位小数和千分位形式。
   */
  static formatAmount(amount: number): string {
    const fixedAmount: string = amount.toFixed(2);
    const amountParts: string[] = fixedAmount.split('.');
    let integerPart: string = amountParts[0];
    const decimalPart: string = amountParts[1];
    const resultParts: string[] = [];

    while (integerPart.length > 3) {
      resultParts.unshift(integerPart.slice(integerPart.length - 3));
      integerPart = integerPart.slice(0, integerPart.length - 3);
    }
    resultParts.unshift(integerPart);
    return `${resultParts.join(',')}.${decimalPart}`;
  }

  /**
   * 按显隐状态格式化普通金额文本。
   */
  static getAmountText(amount: number, hidden: boolean): string {
    if (hidden) {
      return '****';
    }
    return `¥${HomeAmountFormatter.formatAmount(amount)}`;
  }

  /**
   * 按显隐状态格式化带正负号的金额文本。
   */
  static getSignedAmountText(amount: number, hidden: boolean): string {
    if (hidden) {
      return '****';
    }
    const prefix: string = amount >= 0 ? '+' : '-';
    return `${prefix}¥${HomeAmountFormatter.formatAmount(Math.abs(amount))}`;
  }
}
