/**
 * Copyright (C), 2026-05-06
 * @author ZestBox
 * @date 2026/05/06
 * @version 1.0
 * @description: 折线图组件
 */

import { IncomeExpenseBean } from '../models/IncomeExpenseBean';

@ComponentV2
export struct LineChartComponent {
  @Param chartWidth: number = 300;
  @Param chartHeight: number = 200;
  @Param incomeData: IncomeExpenseBean[] = [];
  @Param expenseData: IncomeExpenseBean[] = [];
  @Param showGrid: boolean = true;
  @Param showLegend: boolean = true;
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  private readonly PADDING_LEFT: number = 50;
  private readonly PADDING_RIGHT: number = 20;
  private readonly PADDING_TOP: number = 30;
  private readonly PADDING_BOTTOM: number = 40;
  
  private readonly INCOME_COLOR: string = '#4CAF50';
  private readonly EXPENSE_COLOR: string = '#F44336';
  private readonly GRID_COLOR: string = '#E0E0E0';
  private readonly TEXT_COLOR: string = '#757575';

  @Monitor('incomeData', 'expenseData')
  onChartDataChanged(): void {
    this.drawChart();
  }
  
  build() {
    Column() {
      Canvas(this.context)
        .width(this.chartWidth)
        .height(this.chartHeight)
        .onReady(() => {
          this.drawChart();
        });
    }
  }
  
  private drawChart(): void {
    if (!this.context) {
      return;
    }
    if (this.incomeData.length === 0 && this.expenseData.length === 0) {
      this.drawEmptyState();
      return;
    }
    
    this.context.clearRect(0, 0, this.chartWidth, this.chartHeight);
    this.context.fillStyle = '#FFFFFF';
    this.context.fillRect(0, 0, this.chartWidth, this.chartHeight);
    
    const chartWidth = this.chartWidth - this.PADDING_LEFT - this.PADDING_RIGHT;
    const chartHeight = this.chartHeight - this.PADDING_TOP - this.PADDING_BOTTOM;
    
    const allValues: number[] = [];
    this.incomeData.forEach(item => allValues.push(item.income));
    this.expenseData.forEach(item => allValues.push(item.expense));
    const maxValue = Math.max(...allValues, 1);
    
    if (this.showGrid) {
      this.drawGrid(chartWidth, chartHeight, maxValue);
    }
    
    if (this.incomeData.length > 0) {
      this.drawLine(this.incomeData, chartWidth, chartHeight, maxValue, this.INCOME_COLOR, 'income');
    }
    
    if (this.expenseData.length > 0) {
      this.drawLine(this.expenseData, chartWidth, chartHeight, maxValue, this.EXPENSE_COLOR, 'expense');
    }
    
    if (this.showLegend) {
      this.drawLegend();
    }
  }
  
  private drawEmptyState(): void {
    this.context.clearRect(0, 0, this.chartWidth, this.chartHeight);
    this.context.fillStyle = '#FFFFFF';
    this.context.fillRect(0, 0, this.chartWidth, this.chartHeight);
    this.context.fillStyle = this.TEXT_COLOR;
    this.context.font = '14px sans-serif';
    this.context.textAlign = 'center';
    this.context.fillText('暂无数据', this.chartWidth / 2, this.chartHeight / 2);
  }
  
  private drawGrid(chartWidth: number, chartHeight: number, maxValue: number): void {
    this.context.strokeStyle = this.GRID_COLOR;
    this.context.lineWidth = 1;
    
    const gridCount = 5;
    for (let i = 0; i <= gridCount; i++) {
      const y = this.PADDING_TOP + (chartHeight / gridCount) * i;
      this.context.beginPath();
      this.context.moveTo(this.PADDING_LEFT, y);
      this.context.lineTo(this.chartWidth - this.PADDING_RIGHT, y);
      this.context.stroke();
      
      const value = maxValue - (maxValue / gridCount) * i;
      this.context.fillStyle = this.TEXT_COLOR;
      this.context.font = '12px sans-serif';
      this.context.textAlign = 'right';
      this.context.fillText(this.formatValue(value), this.PADDING_LEFT - 5, y + 4);
    }
    
    const dataLength = Math.max(this.incomeData.length, this.expenseData.length);
    if (dataLength > 1) {
      for (let i = 0; i < dataLength; i++) {
        const x = this.PADDING_LEFT + (chartWidth / (dataLength - 1)) * i;
        this.context.beginPath();
        this.context.moveTo(x, this.PADDING_TOP);
        this.context.lineTo(x, this.chartHeight - this.PADDING_BOTTOM);
        this.context.stroke();
      }
    }
  }
  
  private drawLine(data: IncomeExpenseBean[], chartWidth: number, chartHeight: number, maxValue: number, color: string, type: string): void {
    if (data.length === 0) return;
    
    this.context.strokeStyle = color;
    this.context.lineWidth = 2;
    this.context.beginPath();
    
    const dataLength = data.length;
    const xStep = dataLength > 1 ? chartWidth / (dataLength - 1) : 0;
    
    data.forEach((item, index) => {
      const x = this.PADDING_LEFT + xStep * index;
      const value = type === 'income' ? item.income : item.expense;
      const y = this.PADDING_TOP + chartHeight * (1 - value / maxValue);
      
      if (index === 0) {
        this.context.moveTo(x, y);
      } else {
        this.context.lineTo(x, y);
      }
      
      this.context.fillStyle = color;
      this.context.beginPath();
      this.context.arc(x, y, 4, 0, 2 * Math.PI);
      this.context.fill();
      
      if (type === 'income' && index < dataLength) {
        this.context.fillStyle = this.TEXT_COLOR;
        this.context.font = '10px sans-serif';
        this.context.textAlign = 'center';
        const label = this.formatTimeLabel(item.timeLabel);
        this.context.fillText(label, x, this.chartHeight - this.PADDING_BOTTOM + 15);
      }
    });
    
    this.context.stroke();
  }
  
  private drawLegend(): void {
    const legendY = 10;
    const legendX = this.chartWidth - 120;
    
    this.context.fillStyle = this.INCOME_COLOR;
    this.context.fillRect(legendX, legendY, 15, 10);
    this.context.fillStyle = this.TEXT_COLOR;
    this.context.font = '12px sans-serif';
    this.context.textAlign = 'left';
    this.context.fillText('收入', legendX + 20, legendY + 9);
    
    this.context.fillStyle = this.EXPENSE_COLOR;
    this.context.fillRect(legendX + 60, legendY, 15, 10);
    this.context.fillStyle = this.TEXT_COLOR;
    this.context.fillText('支出', legendX + 80, legendY + 9);
  }
  
  private formatValue(value: number): string {
    if (value >= 10000) {
      return (value / 10000).toFixed(1) + '万';
    }
    return value.toFixed(0);
  }
  
  private formatTimeLabel(label: string): string {
    if (label.includes('-')) {
      const parts = label.split('-');
      if (parts.length === 3) {
        return parts[1] + '-' + parts[2];
      }
    }
    return label;
  }
}
