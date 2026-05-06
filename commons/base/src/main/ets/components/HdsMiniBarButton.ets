/**
 * Copyright (C), 2026-05-06
 * @author ZestBox
 * @date 2026-05-06 
 * @version 1.0
 * @description: 
 */

const TAG: string = '[HdsMiniBarButton]';



@ComponentV2
export struct HdsMiniBarButton {
  @Local pageInfos: NavPathStack = new NavPathStack()
  
  build() {
    NavDestination() {

    }    
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}


