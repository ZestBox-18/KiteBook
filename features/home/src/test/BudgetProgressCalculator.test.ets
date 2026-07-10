/**
 * Copyright (C), 2026-07-10
 * @author ZestBox
 * @date 2026/07/10
 * @version 1.0
 * @description: 预算进度客观指标计算测试
 */

import { describe, expect, it } from '@ohos/hypium';
import {
  BudgetProgressCalculator,
  BudgetProgressSummary
} from '../main/ets/utils/BudgetProgressCalculator';

export default function budgetProgressCalculatorTest() {
  describe('BudgetProgressCalculator', () => {
    it('builds current month progress from budget and calendar facts', 0, () => {
      const monthAnchor: number = new Date(2026, 6, 1).getTime();
      const nowTimestamp: number = new Date(2026, 6, 10, 12).getTime();
      const summary: BudgetProgressSummary =
        BudgetProgressCalculator.build(monthAnchor, 8000, 3260, nowTimestamp);

      expect(Math.round(summary.usagePercent * 10)).assertEqual(408);
      expect(Math.round(summary.timeProgressPercent * 10)).assertEqual(323);
      expect(Math.round(summary.progressDifference * 10)).assertEqual(85);
      expect(summary.remainingAmount).assertEqual(4740);
      expect(summary.remainingDays).assertEqual(22);
      expect(Math.round(summary.dailyAvailableAmount * 100)).assertEqual(21545);
    });

    it('does not infer progress when no budget exists', 0, () => {
      const monthAnchor: number = new Date(2026, 6, 1).getTime();
      const nowTimestamp: number = new Date(2026, 6, 10, 12).getTime();
      const summary: BudgetProgressSummary =
        BudgetProgressCalculator.build(monthAnchor, 0, 3260, nowTimestamp);

      expect(summary.usagePercent).assertEqual(0);
      expect(summary.remainingAmount).assertEqual(0);
      expect(summary.dailyAvailableAmount).assertEqual(0);
    });
  });
}
