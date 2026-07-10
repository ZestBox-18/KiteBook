import localUnitTest from './LocalUnit.test';
import budgetProgressCalculatorTest from './BudgetProgressCalculator.test';

export default function testsuite() {
  localUnitTest();
  budgetProgressCalculatorTest();
}
