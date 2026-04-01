/**
 * Copyright (C), 2026-04-01
 * @author ZestBox
 * @date 2026-04-01 
 * @version 1.0
 * @description: 
 */

const TAG: string = '[test]';



@ComponentV2
export struct test {
  @Local pageInfos: NavPathStack = new NavPathStack()
  
  build() {
    NavDestination() {

    }    
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}


