/**
 * Copyright (C), 2026-02-05
 * @author ZestBox
 * @date 2026/02/05
 * @version 1.0
 * @description: 通用常量
 */

export class CommonConstants {
  /**
   * 包名
   */
  static readonly BUNDLE_NAME: string = "com.zestbox.kitebook";
  /**
   * 安全区避让高度
   */
  static readonly AVOID_RECT_HEIGHT_TOP: string = "topRectHeight";
  static readonly AVOID_RECT_HEIGHT_BOTTOM: string = "bottomRectHeight";
  /**
   * 页面
   */
  static readonly PAGE_INFOS: string = "pagesInfos";
  /**
   * 百分百
   */
  static readonly FULL_WIN: string = "100%";
  /**
   * 标题FREE高度
   */
  static readonly TITLE_BAR_HEIGHT_FREE: number = 138;
  /**
   * Tabs的高度
   */
  static readonly TAB_HEIGHT: number = 56;
  /**
   * HdsNavDestination 标题栏高度
   * HdsNavDestinationTitleMode.MINI: 标题栏高度 56vp
   */
  static readonly TITLE_BAR_HEIGHT_MINI: number = 56;
  /**
   * HdsNavDestination 半模态模式
   * HdsNavDestinationTitleMode.MODAL: 背板高度 64vp，标题栏高度 56vp，上 padding 8vp
   */
  static readonly TITLE_BAR_HEIGHT_MODAL: number = 56;
  static readonly TITLE_BAR_BACKPLATE_HEIGHT_MODAL: number = 64;
  static readonly TITLE_BAR_PADDING_TOP_MODAL: number = 8;
}
