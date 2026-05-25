export class CategoryStatBean {
  categoryName: string = '';
  categoryIcon: Resource = $r('sys.symbol.ellipsis_circle');
  categoryColor: string = '#2196F3';
  amount: number = 0;
  ratio: number = 0;
  count: number = 0;
  
  constructor(categoryName: string, categoryIcon: Resource, categoryColor: string, amount: number, count: number) {
    this.categoryName = categoryName;
    this.categoryIcon = categoryIcon;
    this.categoryColor = categoryColor;
    this.amount = amount;
    this.count = count;
  }
  
  calculateRatio(totalAmount: number): void {
    if (totalAmount > 0) {
      this.ratio = (this.amount / totalAmount) * 100;
    }
  }
}

export class CategoryStatSummaryBean {
  totalAmount: number = 0;
  totalCount: number = 0;
  categoryCount: number = 0;
  
  constructor(dataList: CategoryStatBean[]) {
    if (dataList.length === 0) return;
    this.categoryCount = dataList.length;
    this.totalAmount = dataList.reduce((sum, item) => sum + item.amount, 0);
    this.totalCount = dataList.reduce((sum, item) => sum + item.count, 0);
    dataList.forEach(item => item.calculateRatio(this.totalAmount));
  }
}
