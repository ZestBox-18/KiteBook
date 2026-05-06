/**
 * Copyright (C), 2026-04-01
 * @author ZestBox
 * @date 2026-04-01 
 * @version 1.0
 * @description:
 */
import { HdsNavDestination, HdsAnimationMode } from "@kit.UIDesignKit";
import { mainTabController } from 'base';

const TAG: string = '[Ordinary]';


@ComponentV2
export struct Ordinary {
  @Local pageInfos: NavPathStack = new NavPathStack()

  build() {
    HdsNavDestination() {
      Column() {
        Text("这里是日常消费录入｜编辑")
      }
    }
    .titleBar({
      avoidLayoutSafeArea: true
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .onBackPressed(() => {
      mainTabController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
      return false;
    })
  }
}


