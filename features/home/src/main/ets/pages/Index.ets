import { HdsNavigation } from "@kit.UIDesignKit";
import { CommonConstants, HdsMiniBarButton, RouterUrlConstants } from "base";
import { Assets, Ordinary } from "record";
import { test } from "./view/test";

@Entry
@ComponentV2
export struct Index {
  // 页面路由栈
  @Local pageInfos: NavPathStack = new NavPathStack();

  /**
   * 页面路由表
   * @param name 路由名
   * @param param 携带方法体
   */
  @Builder
  PagesMap(name: string, param?: object) {
    if (name === RouterUrlConstants.ORDINARY) {
      Ordinary()
    }
    if (name === RouterUrlConstants.ASSETS) {
      Assets()
    }
    if (name === 'test') {
      test()
    }
  }

  aboutToAppear() {
  }

  build() {
    HdsNavigation(this.pageInfos) {
      Column() {
        HdsMiniBarButton({
          iconResource: $r('sys.symbol.plus_circle'),
          iconColor: [Color.Blue],
          iconSize: 24,
          onButtonClick: () => {
            // 点击去新增记账记录
            this.pageInfos.pushPath({name:RouterUrlConstants.ORDINARY})
          }
        })
        HdsMiniBarButton({
          iconResource: $r('sys.symbol.plus_circle'),
          iconColor: [Color.Blue],
          iconSize: 24,
          onButtonClick: () => {
            // 点击去到测试页面
            this.pageInfos.pushPath({name:'test'})
          }
        })
      }
    }
    .width(CommonConstants.FULL_WIN)
    .height(CommonConstants.FULL_WIN)
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
    .hideNavBar(true)
  }
}

