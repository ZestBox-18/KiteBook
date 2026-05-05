/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 用户信息卡片组件
 */

import { UserProfile } from '../entities/UserProfile';

@ComponentV2
export struct UserCard {
  // 用户信息
  @Param profile: UserProfile = new UserProfile()
  // 点击回调
  @Param onEdit: () => void = () => {
  }

  build() {
    Row() {
      // 头像
      if (this.profile.isLoggedIn && this.profile.avatar) {
        Image(this.profile.avatar)
          .width(52)
          .height(52)
          .borderRadius(26)
      } else {
        Image($r("app.media.default_avatar"))
          .width(52)
          .height(52)
          .borderRadius(26)
      }

      // 昵称和提示
      Column() {
        if (this.profile.isLoggedIn) {
          Text(this.profile.nickname)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text('账号管理')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 2 })
        } else {
          Text('点击登录')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text('账号管理')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      // 箭头
      SymbolGlyph($r("sys.symbol.chevron_right"))
        .fontSize(18)
        .fontColor([$r('app.color.text_secondary')])
    }
    .width('100%')
    .padding(16)
    .borderRadius(12)
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
    .onClick(() => {
      this.onEdit()
    })
  }
}
