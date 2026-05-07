export class AssetAnalysisBean {
  timeLabel: string = '';
  totalAsset: number = 0;
  liquidAsset: number = 0;
  fixedAsset: number = 0;
  totalLiability: number = 0;
  netAsset: number = 0;
  assetChange: number = 0;
  assetChangeRate: number = 0;
  timestamp: number = 0;
  
  constructor(timeLabel: string, totalAsset: number, liquidAsset: number, fixedAsset: number, totalLiability: number, timestamp: number) {
    this.timeLabel = timeLabel;
    this.totalAsset = totalAsset;
    this.liquidAsset = liquidAsset;
    this.fixedAsset = fixedAsset;
    this.totalLiability = totalLiability;
    this.netAsset = totalAsset - totalLiability;
    this.timestamp = timestamp;
  }
  
  calculateChange(previousAsset: number): void {
    this.assetChange = this.totalAsset - previousAsset;
    if (previousAsset > 0) {
      this.assetChangeRate = (this.assetChange / previousAsset) * 100;
    }
  }
}

export class AssetAnalysisSummaryBean {
  currentTotalAsset: number = 0;
  currentNetAsset: number = 0;
  assetGrowthRate: number = 0;
  maxAsset: number = 0;
  minAsset: number = 0;
  averageAsset: number = 0;
  
  constructor(dataList: AssetAnalysisBean[]) {
    if (dataList.length === 0) return;
    const lastItem = dataList[dataList.length - 1];
    this.currentTotalAsset = lastItem.totalAsset;
    this.currentNetAsset = lastItem.netAsset;
    const firstItem = dataList[0];
    if (firstItem.totalAsset > 0) {
      this.assetGrowthRate = ((this.currentTotalAsset - firstItem.totalAsset) / firstItem.totalAsset) * 100;
    }
    const assets = dataList.map(item => item.totalAsset);
    this.maxAsset = Math.max(...assets);
    this.minAsset = Math.min(...assets);
    this.averageAsset = assets.reduce((sum, val) => sum + val, 0) / assets.length;
  }
}
