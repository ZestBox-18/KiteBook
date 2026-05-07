/**
 * Copyright (C), 2026-05-06
 * @author AI Assistant
 * @date 2026/05/06
 * @version 1.0
 * @description: 快捷记账卡片
 */

import { CategoryItem } from '../entities/CategoryItem';
import { QuickButton } from './QuickButton';

@ComponentV2
export struct QuickActionCard {
  @Param categories: CategoryItem[] = [];
  @Param onCategoryClick: (category: CategoryItem) => void = () => {};
  
  build() {
    Column() {
      Text('快捷记账')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .margin({ bottom: 16 })
      
      Row() {
        ForEach(this.categories, (category: CategoryItem) => {
          QuickButton({
            category: category,
            onClick: () => {
              this.onCategoryClick(category);
            }
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .flexWrap(FlexWrap.Wrap)
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding(20)
    .shadow({
      radius: 8,
      color: $r('sys.color.shadow_color'),
      offsetX: 0,
      offsetY: 2
    })
  }
}
