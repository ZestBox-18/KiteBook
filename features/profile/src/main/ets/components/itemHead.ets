/**
 * Copyright (C), 2025-10-13
 * @author ZestBox
 * @date 2025/10/13 
 * @version 1.0
 * @description: 设置表头
 */

const TAG: string = '[itemHead]';

@Builder
export function itemHead(text: string) {
  Text(text)
    .fontSize(12)
    .width('100%')
    .padding(5)
}

