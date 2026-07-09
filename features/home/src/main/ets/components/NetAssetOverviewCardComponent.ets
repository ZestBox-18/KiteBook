/**
 * Copyright (C), 2026-07-03
 * @author ZestBox
 * @date 2026/07/03
 * @version 1.0
 * @description: 首页净资产概览卡片
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { AccountBean, AppThemeState, BillBean, BillGroup, BillTypeEnum, billSyncController } from 'base';
import { AccountManager, BillManager } from 'data_core';
import { Clog } from 'kite_utils';
import { HomeAmountFormatter } from '../utils/HomeAmountFormatter';

const TAG: string = '[NetAssetOverviewCardComponent]';

@ComponentV2
export struct NetAssetOverviewCardComponent {
  @Event onAssetClick: () => void = () => {
  };

  @Local themeState: AppThemeState = AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
  @Local hideAssetAmount: boolean = false;
  @Local totalAssets: number = 0;
  @Local totalLiabilities: number = 0;
  @Local netAssets: number = 0;
  @Local monthChange: number = 0;
  @Local trendValues: number[] = [];
  private assetTrendSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private assetTrendContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.assetTrendSettings);
  private assetTrendReady: boolean = false;
  private billSyncListenerId: number = -1;

  aboutToAppear(): void {
    if (this.billSyncListenerId < 0) {
      this.billSyncListenerId = billSyncController.register(async () => {
        await this.loadOverviewData();
      })
    }
    this.loadOverviewData();
  }

  aboutToDisappear(): void {
    if (this.billSyncListenerId >= 0) {
      billSyncController.unregister(this.billSyncListenerId);
      this.billSyncListenerId = -1;
    }
  }

  private async loadOverviewData(): Promise<void> {
    try {
      await this.loadAssetSummary();
      await this.loadBillDerivedData();
    } catch (err) {
      Clog.error(TAG, '加载净资产卡片数据失败', err);
    }
  }

  private async loadAssetSummary(): Promise<void> {
    const accounts: AccountBean[] = await AccountManager.getAccounts();
    let assets: number = 0;
    let liabilities: number = 0;
    accounts.forEach((account: AccountBean) => {
      if (account.isLiability()) {
        liabilities += account.balance;
      } else {
        assets += account.balance;
      }
    });
    this.totalAssets = assets;
    this.totalLiabilities = liabilities;
    this.netAssets = assets - liabilities;
  }

  private async loadBillDerivedData(): Promise<void> {
    const monthGroups: BillGroup[] = await BillManager.getRecentBills(31);
    let income: number = 0;
    let expense: number = 0;
    monthGroups.forEach((group: BillGroup) => {
      income += group.totalIncome;
      expense += group.totalExpense;
    });
    this.monthChange = income - expense;
    this.trendValues = await this.loadSixMonthTrendValues();
    if (this.assetTrendReady) {
      this.drawAssetTrendLine();
    }
  }

  build() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Text('净资产')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)

          Row() {
            SymbolGlyph(this.hideAssetAmount ? $r('sys.symbol.eye_slash') : $r('sys.symbol.eye'))
              .fontSize(15)
              .fontColor([this.themeState.fontSecondary as ResourceColor])
          }
            .width(32)
            .height(24)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .borderRadius(12)
            .backgroundColor(this.themeState.compBackgroundNeutral)
            .border({ width: 1, color: this.themeState.compDivider })
            .onClick(() => {
              this.hideAssetAmount = !this.hideAssetAmount;
            })
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Center)

        Row({ space: 6 }) {
          Text('本月变化')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.fontSecondary)
          Text(this.getSignedAmountText(this.monthChange))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getMonthChangeColor())
            .width(92)
            .textAlign(TextAlign.End)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .width('100%')

      Row() {
        Column() {
          Text(this.getAmountText(this.netAssets))
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.fontPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: 18 }) {
            Text('总资产')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
              .width(56)
            Text(this.getAmountText(this.totalAssets))
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .margin({ top: 10 })

          Row({ space: 18 }) {
            Text('总负债')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
              .width(56)
            Text(this.getAmountText(this.totalLiabilities))
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.fontSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .margin({ top: 10 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        this.AssetTrendLine()
      }
      .width('100%')
      .margin({ top: 24 })

    }
    .width('100%')
    .height(204)
    .padding(18)
    .borderRadius(22)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .onClick(() => {
      this.onAssetClick();
    })
  }

  @Builder
  private AssetTrendLine() {
    Stack() {
      Canvas(this.assetTrendContext)
        .width('100%')
        .height(78)
        .onReady(() => {
          this.assetTrendReady = true;
          this.drawAssetTrendLine();
        })
    }
    .width(150)
    .height(92)
    .margin({ top: 2 })
  }

  private drawAssetTrendLine(): void {
    const values: number[] = this.getDrawableTrendValues();
    const points: number[][] = this.buildTrendPoints(values);
    this.assetTrendContext.clearRect(0, 0, 300, 156);
    this.assetTrendContext.strokeStyle = this.themeState.brand as string;
    this.assetTrendContext.lineWidth = 3;
    this.assetTrendContext.beginPath();
    points.forEach((point: number[], index: number) => {
      if (index === 0) {
        this.assetTrendContext.moveTo(point[0], point[1]);
      } else {
        this.assetTrendContext.lineTo(point[0], point[1]);
      }
    });
    this.assetTrendContext.stroke();

    points.forEach((point: number[]) => {
      this.assetTrendContext.beginPath();
      this.assetTrendContext.fillStyle = this.themeState.compBackgroundPrimary as string;
      this.assetTrendContext.arc(point[0], point[1], 3.5, 0, Math.PI * 2);
      this.assetTrendContext.fill();
      this.assetTrendContext.strokeStyle = this.themeState.brand as string;
      this.assetTrendContext.lineWidth = 2;
      this.assetTrendContext.stroke();
    });
  }

  private async loadSixMonthTrendValues(): Promise<number[]> {
    const monthStarts: Date[] = this.getRecentMonthStarts(6);
    const startTime: number = monthStarts[0].getTime();
    const endMonth: Date = monthStarts[monthStarts.length - 1];
    const endTime: number = new Date(endMonth.getFullYear(), endMonth.getMonth() + 1, 1).getTime();
    const bills: BillBean[] = await BillManager.getBillsByRange(startTime, endTime);
    const monthDeltas: number[] = [0, 0, 0, 0, 0, 0];

    bills.forEach((bill: BillBean) => {
      const monthIndex: number = this.getMonthIndex(monthStarts, bill.date);
      if (monthIndex < 0) {
        return;
      }
      if (bill.type === BillTypeEnum.INCOME) {
        monthDeltas[monthIndex] += bill.amount;
      } else if (bill.type === BillTypeEnum.EXPENSE) {
        monthDeltas[monthIndex] -= bill.amount;
      }
    });

    const values: number[] = [this.netAssets, this.netAssets, this.netAssets, this.netAssets, this.netAssets, this.netAssets];
    values[5] = this.netAssets;
    for (let index = 4; index >= 0; index--) {
      values[index] = values[index + 1] - monthDeltas[index + 1];
    }
    return values;
  }

  private getRecentMonthStarts(count: number): Date[] {
    const today: Date = new Date();
    const starts: Date[] = [];
    for (let index = count - 1; index >= 0; index--) {
      starts.push(new Date(today.getFullYear(), today.getMonth() - index, 1));
    }
    return starts;
  }

  private getMonthIndex(monthStarts: Date[], timestamp: number): number {
    const billDate: Date = new Date(timestamp);
    for (let index = 0; index < monthStarts.length; index++) {
      const monthStart: Date = monthStarts[index];
      if (billDate.getFullYear() === monthStart.getFullYear() && billDate.getMonth() === monthStart.getMonth()) {
        return index;
      }
    }
    return -1;
  }

  private getDrawableTrendValues(): number[] {
    if (this.trendValues.length >= 2) {
      return this.trendValues;
    }
    return [this.netAssets, this.netAssets, this.netAssets, this.netAssets, this.netAssets, this.netAssets];
  }

  private buildTrendPoints(values: number[]): number[][] {
    let minValue: number = values[0];
    let maxValue: number = values[0];
    values.forEach((value: number) => {
      minValue = Math.min(minValue, value);
      maxValue = Math.max(maxValue, value);
    });

    const actualRange: number = maxValue - minValue;
    const baseRange: number = Math.max(Math.max(Math.abs(maxValue), Math.abs(minValue)) * 0.08, 1);
    if (actualRange < 1) {
      const flatPoints: number[][] = [];
      const left: number = 2;
      const right: number = 148;
      const step: number = (right - left) / (values.length - 1);
      values.forEach((value: number, index: number) => {
        flatPoints.push([left + step * index, 39]);
      });
      return flatPoints;
    }

    const range: number = Math.max(actualRange, baseRange);
    const left: number = 2;
    const right: number = 148;
    const top: number = 8;
    const bottom: number = 70;
    const step: number = (right - left) / (values.length - 1);
    const points: number[][] = [];
    values.forEach((value: number, index: number) => {
      const x: number = left + step * index;
      const y: number = bottom - ((value - minValue) / range) * (bottom - top);
      points.push([x, y]);
    });
    return points;
  }

  private getMonthChangeColor(): ResourceColor {
    if (this.monthChange < 0) {
      return '#16A34A';
    }
    return '#EF4444';
  }

  private getAmountText(amount: number): string {
    return HomeAmountFormatter.getAmountText(amount, this.hideAssetAmount);
  }

  private getSignedAmountText(amount: number): string {
    return HomeAmountFormatter.getSignedAmountText(amount, this.hideAssetAmount);
  }
}
