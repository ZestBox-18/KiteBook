/**
 * Copyright (C), 2026-04-01
 * @author ZestBox
 * @date 2026-04-01 
 * @version 1.0
 * @description:
 */
import { HdsAnimationMode } from "@kit.UIDesignKit";
import { mainTabController } from 'base';

const TAG: string = '[Assets]';


@ComponentV2
export struct Assets {
  @Local pageInfos: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        Text("这里是资产录入｜编辑")
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .hideTitleBar(true)
    .hideBackButton(true)
    .onBackPressed(() => {
      mainTabController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
      return false;
    })
  }
}


