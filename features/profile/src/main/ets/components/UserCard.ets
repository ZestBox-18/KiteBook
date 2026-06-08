/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 用户信息卡片组件
 */

import { UserProfile } from '../entities/UserProfile';
import { SystemOptions } from 'base';
import { curves } from '@kit.ArkUI';
import { PersistenceV2 } from '@ohos.arkui.StateManagement';

@ComponentV2
export struct UserCard {
  // 用户信息
  @Param profile: UserProfile = new UserProfile()
  // 点击回调
  @Param onEdit: () => void = () => {
  }
  // UI上下文
  @Param uiContext: UIContext | undefined = undefined
  // 系统设置
  @Local optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!
  // 登录成功动画触发器（每次变化时触发动画）
  @Param loginAnimationTrigger: number = 0
  // 退出登录动画触发器
  @Param logoutAnimationTrigger: number = 0
  // 登录失败动画触发器
  @Param loginFailedTrigger: number = 0
  // 动画状态
  @Local avatarRotateY: number = 0
  @Local currentAvatar: string = ''
  @Local currentNickname: string = ''
  @Local isAnimating: boolean = false
  @Local isWaitingForLogin: boolean = false // 是否在等待登录成功
  // 用户名动画状态
  @Local oldTextOpacity: number = 1
  @Local oldTextTranslateX: number = 0
  @Local newTextOpacity: number = 0
  @Local newTextTranslateX: number = 30
  // 动画控制变量
  private rotateInterval: number = 0
  private angle: number = 0
  private shouldStop: boolean = false
  private avatarSwitched: boolean = false

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
      // 登录成功，切换头像并完成动画
      this.onLoginSuccess();
    } else if (!this.isAnimating) {
      // 开始旋转动画（等待登录）
      this.startRotateAnimation();
    }
  }

  // 监听退出触发器变化
  @Monitor('logoutAnimationTrigger')
  onLogoutTriggerChanged(): void {
    if (!this.profile.isLoggedIn && !this.isAnimating) {
      this.playLogoutAnimation();
    }
  }

  // 监听登录失败触发器变化
  @Monitor('loginFailedTrigger')
  onLoginFailedTriggerChanged(): void {
    this.stopRotationAndReset();
  }

  // 停止旋转动画并重置状态
  private stopRotationAndReset(): void {
    if (this.rotateInterval) {
      clearInterval(this.rotateInterval);
      this.rotateInterval = 0;
    }
    this.shouldStop = true;
    this.avatarRotateY = 0;
    this.angle = 0;
    this.avatarSwitched = false;
    this.isAnimating = false;
    this.isWaitingForLogin = false;
  }

  // 开始旋转动画（等待登录成功）
  private startRotateAnimation(): void {
    this.isAnimating = true;
    this.isWaitingForLogin = true;
    this.angle = 0;
    this.shouldStop = false;
    this.avatarSwitched = false;

    const rotateSpeed = 8;
    const updateRotate = () => {
      if (this.shouldStop) {
        return;
      }

      this.angle += rotateSpeed;
      if (this.angle >= 360) {
        this.angle = this.angle - 360;
      }
      this.avatarRotateY = this.angle;

      // 在 90 度时切换头像（如果已经登录成功）
      if (!this.avatarSwitched && this.angle >= 85 && this.angle <= 95 && this.profile.isLoggedIn) {
        this.currentAvatar = this.profile.avatar;
        this.currentNickname = this.profile.nickname;
        this.avatarSwitched = true;
      }

      // 如果已经切换头像，旋转到正面就停止
      if (this.avatarSwitched && (this.angle >= 350 || this.angle <= 10)) {
        this.shouldStop = true;
        clearInterval(this.rotateInterval);
        this.avatarRotateY = 0;
        this.finishLoginAnimation();
      }
    };

    this.rotateInterval = setInterval(updateRotate, 16);
  }

  // 登录成功，切换头像
  private onLoginSuccess(): void {
    this.isWaitingForLogin = false;
    // 如果动画正在进行，等待在 90 度时切换头像
    // 如果动画还没开始，直接播放完整动画
    if (!this.isAnimating) {
      this.playLoginAnimation();
    }
  }

  // 完成登录动画（用户名滑动）
  private finishLoginAnimation(): void {
    // 用户名动画：左右滑动
    this.uiContext?.animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
      this.oldTextOpacity = 0;
      this.oldTextTranslateX = -30;
    });

    this.uiContext?.animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
      this.newTextOpacity = 1;
      this.newTextTranslateX = 0;
    });

    setTimeout(() => {
      this.isAnimating = false;
    }, 500);
  }

  // 播放登录动画（完整动画，从头开始）
  playLoginAnimation(): void {
    this.isAnimating = true;
    this.angle = 0;
    this.shouldStop = false;
    this.avatarSwitched = false;

    const rotateSpeed = 8;
    const updateRotate = () => {
      if (this.shouldStop) {
        return;
      }

      this.angle += rotateSpeed;
      if (this.angle >= 360) {
        this.angle = this.angle - 360;
      }
      this.avatarRotateY = this.angle;

      if (!this.avatarSwitched && this.angle >= 85 && this.angle <= 95 && this.profile.avatar) {
        this.currentAvatar = this.profile.avatar;
        this.currentNickname = this.profile.nickname;
        this.avatarSwitched = true;
      }
    };

    this.rotateInterval = setInterval(updateRotate, 16);

    // 等待旋转到正面
    const waitForStop = () => {
      return new Promise<void>(resolve => {
        const checkStop = setInterval(() => {
          if (this.avatarSwitched && (this.angle >= 350 || this.angle <= 10)) {
            clearInterval(checkStop);
            this.shouldStop = true;
            clearInterval(this.rotateInterval);
            this.avatarRotateY = 0;
            resolve();
          }
        }, 16);
      });
    };

    waitForStop().then(() => {
      this.finishLoginAnimation();
    });
  }

  // 播放退出动画
  playLogoutAnimation(): void {
    this.isAnimating = true;

    // 停止旋转动画
    if (this.rotateInterval) {
      clearInterval(this.rotateInterval);
    }

    // 头像旋转动画：旋转到 90 度切换为默认头像，然后继续旋转到正面
    this.angle = 0;
    this.shouldStop = false;
    this.avatarSwitched = false;

    const rotateSpeed = 8;
    const updateRotate = () => {
      if (this.shouldStop) {
        return;
      }

      this.angle += rotateSpeed;
      if (this.angle >= 360) {
        this.angle = this.angle - 360;
      }
      this.avatarRotateY = this.angle;

      // 在 90 度时切换为默认头像（清空当前头像）
      if (!this.avatarSwitched && this.angle >= 85 && this.angle <= 95) {
        this.currentAvatar = '';
        this.currentNickname = '';
        this.avatarSwitched = true;
      }

      // 如果已经切换头像，旋转到正面就停止
      if (this.avatarSwitched && (this.angle >= 350 || this.angle <= 10)) {
        this.shouldStop = true;
        clearInterval(this.rotateInterval);
        this.avatarRotateY = 0;
        this.finishLogoutAnimation();
      }
    };

    this.rotateInterval = setInterval(updateRotate, 16);
  }

  // 完成退出动画（用户名滑动）
  private finishLogoutAnimation(): void {
    // 重置状态
    this.uiContext?.animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
      this.oldTextOpacity = 1;
      this.oldTextTranslateX = 0;
    });

    this.uiContext?.animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
      this.newTextOpacity = 0;
      this.newTextTranslateX = 30;
    });

    setTimeout(() => {
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
            .fontWeight(this.optionSystem.fontThickness)
            .fontColor($r('[shared_assets].color.text_primary'))
            .opacity(this.oldTextOpacity)
            .translate({ x: this.oldTextTranslateX })
            .animation({ curve: curves.springMotion(0.6, 0.9) })

          // 新文字：用户名
          if (this.currentNickname) {
            Text(this.currentNickname)
              .fontSize(16)
              .fontWeight(this.optionSystem.fontThickness)
              .fontColor($r('[shared_assets].color.text_primary'))
              .opacity(this.newTextOpacity)
              .translate({ x: this.newTextTranslateX })
              .animation({ curve: curves.springMotion(0.6, 0.9) })
          }
        }
        .width('100%')
        .height(22)

        Text('账号管理')
          .fontSize(12)
          .fontColor($r('[shared_assets].color.text_secondary'))
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      // 箭头
      SymbolGlyph($r("sys.symbol.chevron_right"))
        .fontSize(18)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([$r('[shared_assets].color.text_secondary')])
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
