/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 用户信息卡片组件
 */

import { UserProfile } from '../entities/UserProfile';
import { curves } from '@kit.ArkUI';

@ComponentV2
export struct UserCard {
  // 用户信息
  @Param profile: UserProfile = new UserProfile()
  // 点击回调
  @Param onEdit: () => void = () => {
  }
  // 登录成功动画触发器（每次变化时触发动画）
  @Param loginAnimationTrigger: number = 0
  // 退出登录动画触发器
  @Param logoutAnimationTrigger: number = 0

  // 动画状态
  @Local avatarRotateY: number = 0
  @Local currentAvatar: string = ''
  @Local currentNickname: string = ''
  @Local isAnimating: boolean = false

  // 用户名动画状态
  @Local oldTextOpacity: number = 1
  @Local oldTextTranslateX: number = 0
  @Local newTextOpacity: number = 0
  @Local newTextTranslateX: number = 30

  aboutToAppear(): void {
    // 初始化当前显示的头像和昵称
    if (this.profile.isLoggedIn) {
      this.currentAvatar = this.profile.avatar;
      this.currentNickname = this.profile.nickname;
      // 已登录状态，直接显示最终状态
      this.oldTextOpacity = 0;
      this.newTextOpacity = 1;
      this.newTextTranslateX = 0;
    }
  }

  // 监听登录触发器变化
  @Monitor('loginAnimationTrigger')
  onLoginTriggerChanged(): void {
    if (this.profile.isLoggedIn && !this.isAnimating) {
      this.playLoginAnimation();
    }
  }

  // 监听退出触发器变化
  @Monitor('logoutAnimationTrigger')
  onLogoutTriggerChanged(): void {
    if (!this.profile.isLoggedIn && !this.isAnimating) {
      this.playLogoutAnimation();
    }
  }

  // 播放登录动画
  playLoginAnimation(): void {
    this.isAnimating = true;

    let angle = 0;
    let avatarSwitched = false;
    let shouldStop = false;
    const newAvatar = this.profile.avatar;
    const newNickname = this.profile.nickname;

    const rotateSpeed = 8;
    const updateRotate = () => {
      if (shouldStop) return;

      angle += rotateSpeed;
      if (angle >= 360) {
        angle = angle - 360;
      }
      this.avatarRotateY = angle;

      if (!avatarSwitched && angle >= 85 && angle <= 95 && newAvatar) {
        this.currentAvatar = newAvatar;
        this.currentNickname = newNickname;
        avatarSwitched = true;
      }
    };

    const rotateInterval = setInterval(updateRotate, 16);

    // 等待旋转到正面
    const waitForStop = () => {
      return new Promise<void>(resolve => {
        const checkStop = setInterval(() => {
          if (avatarSwitched && (angle >= 350 || angle <= 10)) {
            clearInterval(checkStop);
            shouldStop = true;
            clearInterval(rotateInterval);
            this.avatarRotateY = 0;
            resolve();
          }
        }, 16);
      });
    };

    waitForStop().then(() => {
      // 用户名动画：左右滑动
      animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
        this.oldTextOpacity = 0;
        this.oldTextTranslateX = -30;
      });

      animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
        this.newTextOpacity = 1;
        this.newTextTranslateX = 0;
      });

      setTimeout(() => {
        this.isAnimating = false;
      }, 500);
    });
  }

  // 播放退出动画
  playLogoutAnimation(): void {
    this.isAnimating = true;

    // 重置状态
    animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
      this.oldTextOpacity = 1;
      this.oldTextTranslateX = 0;
    });

    animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
      this.newTextOpacity = 0;
      this.newTextTranslateX = 30;
    });

    setTimeout(() => {
      this.currentAvatar = '';
      this.currentNickname = '';
      this.isAnimating = false;
    }, 500);
  }

  build() {
    Row() {
      // 头像（带旋转动画）
      Stack() {
        if (this.currentAvatar) {
          Image(this.currentAvatar)
            .width(52)
            .height(52)
            .borderRadius(26)
        } else {
          Image($r("app.media.default_avatar"))
            .width(52)
            .height(52)
            .borderRadius(26)
        }
      }
      .width(52)
      .height(52)
      .rotate({ y: 1, angle: this.avatarRotateY })

      // 昵称和提示（带滑动动画）
      Column() {
        // 使用 Stack 实现文字切换动画
        Stack({ alignContent: Alignment.Start }) {
          // 旧文字："点击登录"
          Text('点击登录')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .opacity(this.oldTextOpacity)
            .translate({ x: this.oldTextTranslateX })
            .animation({ curve: curves.springMotion(0.6, 0.9) })

          // 新文字：用户名
          if (this.currentNickname) {
            Text(this.currentNickname)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .opacity(this.newTextOpacity)
              .translate({ x: this.newTextTranslateX })
              .animation({ curve: curves.springMotion(0.6, 0.9) })
          }
        }
        .width('100%')
        .height(22)

        Text('账号管理')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 2 })
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
