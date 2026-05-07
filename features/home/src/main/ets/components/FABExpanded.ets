/**
 * Copyright (C), 2026-05-07
 * @author AI Assistant
 * @date 2026/05/07
 * @version 1.0
 * @description: 浮动按钮展开状态组件
 */

import { CategoryItem } from '../entities/CategoryItem';
import { CategoryButton } from './CategoryButton';

@ComponentV2
export struct FABExpanded {
  @Param categories: CategoryItem[] = [];
  @Param onCategoryClick: (category: CategoryItem) => void = () => {};
  @Param onClose: () => void = () => {};

  build() {
    Column() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .onClick(() => {
          this.onClose();
        })

      // 分类按钮列表
      Column() {
        ForEach(this.categories, (category: CategoryItem, index: number) => {
          CategoryButton({
            category: category,
            onButtonClick: () => {
              this.onCategoryClick(category);
            },
            index: index
          })
          .margin({ bottom: 12 })
        })

        // 关闭按钮
        Button() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(20)
            .fontColor([$r('sys.color.font_on_primary')])
        }
        .width(56)
        .height(56)
        .backgroundColor($r('sys.color.background_secondary'))
        .borderRadius(28)
        .onClick(() => {
          this.onClose();
        })
      }
      .position({ x: 'calc(100% - 80px)', y: 'calc(100% - 500px)' })
    }
    .width('100%')
    .height('100%')
  }
}
