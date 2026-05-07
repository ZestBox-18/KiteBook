export enum BudgetStatusEnum {
  NORMAL = 'normal',
  WARNING = 'warning',
  EXCEEDED = 'exceeded'
}

export class BudgetAnalysisBean {
  budgetName: string = '';
  budgetAmount: number = 0;
  usedAmount: number = 0;
  remainingAmount: number = 0;
  exceededAmount: number = 0;
  usageRate: number = 0;
  budgetStatus: BudgetStatusEnum = BudgetStatusEnum.NORMAL;
  budgetPeriod: string = '';
  
  constructor(budgetName: string, budgetAmount: number, usedAmount: number, budgetPeriod: string) {
    this.budgetName = budgetName;
    this.budgetAmount = budgetAmount;
    this.usedAmount = usedAmount;
    this.budgetPeriod = budgetPeriod;
    this.calculateRemaining();
    this.calculateUsageRate();
    this.determineStatus();
  }
  
  private calculateRemaining(): void {
    if (this.usedAmount <= this.budgetAmount) {
      this.remainingAmount = this.budgetAmount - this.usedAmount;
      this.exceededAmount = 0;
    } else {
      this.remainingAmount = 0;
      this.exceededAmount = this.usedAmount - this.budgetAmount;
    }
  }
  
  private calculateUsageRate(): void {
    if (this.budgetAmount > 0) {
      this.usageRate = (this.usedAmount / this.budgetAmount) * 100;
    }
  }
  
  private determineStatus(): void {
    if (this.usageRate >= 100) {
      this.budgetStatus = BudgetStatusEnum.EXCEEDED;
    } else if (this.usageRate >= 80) {
      this.budgetStatus = BudgetStatusEnum.WARNING;
    } else {
      this.budgetStatus = BudgetStatusEnum.NORMAL;
    }
  }
}

export class BudgetAnalysisSummaryBean {
  totalBudget: number = 0;
  totalUsed: number = 0;
  totalRemaining: number = 0;
  totalExceeded: number = 0;
  overallUsageRate: number = 0;
  normalCount: number = 0;
  warningCount: number = 0;
  exceededCount: number = 0;
  
  constructor(dataList: BudgetAnalysisBean[]) {
    if (dataList.length === 0) return;
    this.totalBudget = dataList.reduce((sum, item) => sum + item.budgetAmount, 0);
    this.totalUsed = dataList.reduce((sum, item) => sum + item.usedAmount, 0);
    this.totalRemaining = dataList.reduce((sum, item) => sum + item.remainingAmount, 0);
    this.totalExceeded = dataList.reduce((sum, item) => sum + item.exceededAmount, 0);
    if (this.totalBudget > 0) {
      this.overallUsageRate = (this.totalUsed / this.totalBudget) * 100;
    }
    this.normalCount = dataList.filter(item => item.budgetStatus === BudgetStatusEnum.NORMAL).length;
    this.warningCount = dataList.filter(item => item.budgetStatus === BudgetStatusEnum.WARNING).length;
    this.exceededCount = dataList.filter(item => item.budgetStatus === BudgetStatusEnum.EXCEEDED).length;
  }
}
