export class IncomeExpenseBean {
  timeLabel: string = '';
  income: number = 0;
  expense: number = 0;
  balance: number = 0;
  timestamp: number = 0;
  
  constructor(timeLabel: string, income: number, expense: number, timestamp: number) {
    this.timeLabel = timeLabel;
    this.income = income;
    this.expense = expense;
    this.balance = income - expense;
    this.timestamp = timestamp;
  }
}

export class IncomeExpenseSummaryBean {
  totalIncome: number = 0;
  totalExpense: number = 0;
  totalBalance: number = 0;
  averageIncome: number = 0;
  averageExpense: number = 0;
  count: number = 0;
  
  constructor(dataList: IncomeExpenseBean[]) {
    if (dataList.length === 0) return;
    this.count = dataList.length;
    this.totalIncome = dataList.reduce((sum, item) => sum + item.income, 0);
    this.totalExpense = dataList.reduce((sum, item) => sum + item.expense, 0);
    this.totalBalance = this.totalIncome - this.totalExpense;
    this.averageIncome = this.totalIncome / this.count;
    this.averageExpense = this.totalExpense / this.count;
  }
}
