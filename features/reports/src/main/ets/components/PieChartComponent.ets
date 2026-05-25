/**
 * Copyright (C), 2026-05-06
 * @author ZestBox
 * @date 2026/05/06
 * @version 1.0
 * @description: 饼图组件
 */

import { CategoryStatBean } from '../models/CategoryStatBean';

@ComponentV2
export struct PieChartComponent {
  @Param chartWidth: number = 300;
  @Param chartHeight: number = 250;
  @Param data: CategoryStatBean[] = [];
  @Param showLegend: boolean = true;
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  private readonly TEXT_COLOR: string = '#757575';
  
  private readonly COLORS: string[] = [
    '#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0',
    '#00BCD4', '#FFEB3B', '#795548', '#607D8B', '#E91E63'
  ];

  @Monitor('data')
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
    if (this.data.length === 0) {
      this.drawEmptyState();
      return;
    }
    
    this.context.clearRect(0, 0, this.chartWidth, this.chartHeight);
    this.context.fillStyle = '#FFFFFF';
    this.context.fillRect(0, 0, this.chartWidth, this.chartHeight);
    
    const centerX = this.chartWidth / 2;
    const centerY = this.chartHeight / 2 - 20;
    const radius = Math.min(this.chartWidth, this.chartHeight) / 3;
    
    this.drawPie(centerX, centerY, radius);
    
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
  
  private drawPie(centerX: number, centerY: number, radius: number): void {
    let startAngle = -Math.PI / 2;
    
    this.data.forEach((item, index) => {
      const color = item.categoryColor.length > 0 ? item.categoryColor : this.COLORS[index % this.COLORS.length];
      const angle = (item.ratio / 100) * 2 * Math.PI;
      const endAngle = startAngle + angle;
      
      this.context.beginPath();
      this.context.moveTo(centerX, centerY);
      this.context.arc(centerX, centerY, radius, startAngle, endAngle);
      this.context.closePath();
      this.context.fillStyle = color;
      this.context.fill();
      
      this.context.strokeStyle = '#FFFFFF';
      this.context.lineWidth = 2;
      this.context.stroke();
      
      if (item.ratio >= 5) {
        const labelAngle = startAngle + angle / 2;
        const labelX = centerX + (radius * 0.7) * Math.cos(labelAngle);
        const labelY = centerY + (radius * 0.7) * Math.sin(labelAngle);
        
        this.context.fillStyle = '#FFFFFF';
        this.context.font = 'bold 12px sans-serif';
        this.context.textAlign = 'center';
        this.context.textBaseline = 'middle';
        this.context.fillText(item.ratio.toFixed(1) + '%', labelX, labelY);
      }
      
      startAngle = endAngle;
    });
  }
  
  private drawLegend(): void {
    const legendStartY = this.chartHeight - 40;
    const legendStartX = 20;
    const legendItemWidth = 80;
    const itemsPerRow = Math.floor(this.chartWidth / legendItemWidth);
    
    this.data.forEach((item, index) => {
      const row = Math.floor(index / itemsPerRow);
      const col = index % itemsPerRow;
      
      if (row > 1) return;
      
      const x = legendStartX + col * legendItemWidth;
      const y = legendStartY + row * 18;
      
      const color = item.categoryColor.length > 0 ? item.categoryColor : this.COLORS[index % this.COLORS.length];
      this.context.fillStyle = color;
      this.context.fillRect(x, y, 12, 12);
      
      this.context.fillStyle = this.TEXT_COLOR;
      this.context.font = '11px sans-serif';
      this.context.textAlign = 'left';
      this.context.textBaseline = 'middle';
      
      let displayName = item.categoryName;
      if (displayName.length > 4) {
        displayName = displayName.substring(0, 4) + '..';
      }
      this.context.fillText(displayName, x + 15, y + 6);
    });
  }
}
