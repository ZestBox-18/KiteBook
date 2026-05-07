/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 首页数据处理工具测试
 */

import { describe, it, expect } from '@ohos/hypium';
import { BillItem } from '../main/ets/entities/BillItem';
import { BudgetItem } from '../main/ets/entities/BudgetItem';
import { 
  calculateMonthIncome,
  calculateMonthExpense,
  calculateMonthBalance,
  calculateBudgetProgress,
  formatAmount
} from '../main/ets/utils/HomeDataHelper';

export default function homeUtilsTest() {
  describe('HomeDataHelper', () => {
    it('should calculate month income correctly', 0, () => {
      const bills: BillItem[] = [
        { type: 'income', amount: 1000 } as BillItem,
        { type: 'expense', amount: 500 } as BillItem,
        { type: 'income', amount: 2000 } as BillItem
      ];
      const income = calculateMonthIncome(bills);
      expect(income).assertEqual(3000);
    });
    
    it('should calculate month expense correctly', 0, () => {
      const bills: BillItem[] = [
        { type: 'income', amount: 1000 } as BillItem,
        { type: 'expense', amount: 500 } as BillItem,
        { type: 'expense', amount: 300 } as BillItem
      ];
      const expense = calculateMonthExpense(bills);
      expect(expense).assertEqual(800);
    });
    
    it('should calculate month balance correctly', 0, () => {
      const balance = calculateMonthBalance(3000, 800);
      expect(balance).assertEqual(2200);
    });
    
    it('should handle empty bills array', 0, () => {
      const bills: BillItem[] = [];
      const income = calculateMonthIncome(bills);
      const expense = calculateMonthExpense(bills);
      expect(income).assertEqual(0);
      expect(expense).assertEqual(0);
    });
    
    it('should format amount correctly', 0, () => {
      const result = formatAmount(1234.56);
      expect(result).assertEqual('1,234.56');
    });
    
    it('should format zero amount', 0, () => {
      const result = formatAmount(0);
      expect(result).assertEqual('0.00');
    });
  });
}
