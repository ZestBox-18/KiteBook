/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 浮动记账按钮组件
 */

import { CategoryItem } from '../entities/CategoryItem';
import { FABDefault } from './FABDefault';
import { FABExpanded } from './FABExpanded';

@ComponentV2
export struct FloatingActionButton {
  @Param categories: CategoryItem[] = [];
  @Param onCategoryClick: (category: CategoryItem) => void = () => {};

  @Local isExpanded: boolean = false;

  build() {
    Stack() {
      if (this.isExpanded) {
        FABExpanded({
          categories: this.categories,
          onCategoryClick: (category: CategoryItem) => {
            this.onCategoryClick(category);
            this.isExpanded = false;
          },
          onClose: () => {
            this.isExpanded = false;
          }
        })
      } else {
        FABDefault({
          onFABClick: () => {
            this.isExpanded = true;
          }
        })
        .position({ x: 'calc(100% - 80px)', y: 'calc(100% - 80px)' })
      }
    }
    .width('100%')
    .height('100%')
  }
}
