/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 首页资产账户列表区组件
 */

import { AppThemeState } from 'base';
import { curves } from '@kit.ArkUI';
import { AssetAccountBean } from '../viewmodels/HomeViewModels';
import { EmptyStateComponent } from './EmptyStateComponent';

const GRADIENT_DELAY: number = 80;

@ComponentV2
export struct AssetAccountListSectionComponent {
  @Param themeState: AppThemeState = new AppThemeState();
  @Param assetAccounts: AssetAccountBean[] = [];
  @Param hideAssetAmount: boolean = false;
  @Param getAssetSignText: (isLiability: boolean) => string = (_isLiability: boolean): string => {
    return '';
  };
  @Param getAmountText: (amount: number, hidden: boolean) => string = (_amount: number, _hidden: boolean): string => {
    return '';
  };
  @Param getAssetAmountColor: (isLiability: boolean) => ResourceColor = (_isLiability: boolean): ResourceColor => {
    return '#000000';
  };

  /**
   * 构建资产账户列表区，负责空状态和账户卡片列表切换。
   */
  build() {
    if (this.assetAccounts.length === 0) {
      ListItem() {
        EmptyStateComponent({ text: '暂无资产账户数据', themeState: this.themeState })
      }
    } else {
      ListItemGroup({
        header: this.AssetListHeader(),
        style: ListItemGroupStyle.CARD
      }) {
        ForEach(this.assetAccounts, (item: AssetAccountBean, index: number) => {
          ListItem() {
            this.AssetAccountItem(item)
          }
          .opacity(1)
          .translate({ x: 0 })
          .animation({
            duration: 300,
            delay: index * GRADIENT_DELAY,
            curve: curves.springMotion(0.6, 0.9)
          })
        }, (item: AssetAccountBean) => item.name)
      }
      .divider({
        strokeWidth: 0.5,
        color: this.themeState.compDivider,
        startMargin: 52,
        endMargin: 16
      })
    }
  }

  @Builder
  /**
   * 构建资产账户列表头部，展示标题与账户数量。
   */
  private AssetListHeader() {
    Row() {
      Text('账户列表')
        .fontSize(13)
        .fontColor(this.themeState.fontSecondary)
      Text(`${this.assetAccounts.length} 个账户`)
        .fontSize(12)
        .fontColor(this.themeState.brand)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
  }

  @Builder
  /**
   * 构建单个资产账户列表项。
   */
  private AssetAccountItem(item: AssetAccountBean) {
    Row() {
      SymbolGlyph(item.icon)
        .fontSize(20)
        .fontColor([item.isLiability ? '#F97316' : this.themeState.brand as ResourceColor])
        .width(36)
        .height(36)
        .borderRadius(8)
        .backgroundColor(item.isLiability ? '#FFF7ED' : '#EEF6FF')
        .padding(8)

      Column() {
        Text(item.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
        Text(`${this.getAssetSignText(item.isLiability)} · ${item.subtitle}`)
          .fontSize(13)
          .fontColor(this.themeState.fontSecondary)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      Text(this.getAmountText(item.amount, this.hideAssetAmount))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getAssetAmountColor(item.isLiability))
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.compBackgroundPrimary)
  }
}
