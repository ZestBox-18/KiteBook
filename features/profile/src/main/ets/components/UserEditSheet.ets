/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 用户编辑弹窗组件
 */

import { UserProfile } from '../entities/UserProfile';
import { authentication } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { curves } from '@kit.ArkUI';

const TAG = '[UserEditSheet]';

@ComponentV2
export struct UserEditSheet {
  @Param profile: UserProfile = new UserProfile()
  @Param onClose: () => void = () => {}
  @Param context: UIContext | undefined = undefined
  @Local isLoggingIn: boolean = false
  @Local ringScale: number = 0.8
  @Local ringOpacity: number = 0
  @Local avatarRotateY: number = 0
  @Local currentAvatar: string = ''
  @Local currentNickname: string = ''
  // 是否登录成功
  @Local loginSuccess: boolean = false
  // 按钮区域高度（用于动画）
  @Local buttonAreaHeight: number = 0

  aboutToAppear() {
    if (this.profile.isLoggedIn) {
      this.currentAvatar = this.profile.avatar;
      this.currentNickname = this.profile.nickname;
      this.loginSuccess = true;
      this.buttonAreaHeight = 100; // 两个按钮的高度
    }
  }

  private async updateUserInfo(): Promise<void> {
    if (!this.context || this.isLoggingIn) {
      return;
    }

    this.isLoggingIn = true;

    let angle = 0;
    let avatarSwitched = false;
    let shouldStop = false;
    let newAvatar = '';
    let newNickname = '';

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

    try {
      const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
      authRequest.scopes = ['profile'];
      authRequest.forceAuthorization = true;

      const controller = new authentication.AuthenticationController(this.context.getHostContext()!);
      const data = await controller.executeRequest(authRequest);
      const response = data as authentication.AuthorizationWithHuaweiIDResponse;
      const credential = response.data!;

      newAvatar = credential.avatarUri || '';
      newNickname = credential.nickName || '用户';
      
      this.profile.nickname = newNickname;
      this.profile.avatar = newAvatar;
      this.profile.openId = credential.openID || '';
      this.profile.unionId = credential.unionID || '';
      this.profile.userId = credential.openID || '';
      this.profile.isLoggedIn = true;

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

      await waitForStop();

      // 登录成功，展开按钮区域
      this.loginSuccess = true;
      animateTo({ curve: curves.springMotion(0.5, 0.8), duration: 500 }, () => {
        this.buttonAreaHeight = 100; // 两个按钮的高度
      });

      // 光圈扩散
      setTimeout(() => {
        animateTo({ curve: curves.springMotion(0.5, 0.8), duration: 500 }, () => {
          this.ringOpacity = 0.6;
          this.ringScale = 1.2;
        });
      }, 100);
      
      setTimeout(() => {
        animateTo({ curve: Curve.EaseOut, duration: 400 }, () => {
          this.ringOpacity = 0;
          this.ringScale = 1.5;
        });
      }, 600);
      
      setTimeout(() => {
        this.isLoggingIn = false;
        this.ringScale = 0.8;
      }, 1000);

      hilog.info(0x0000, TAG, 'Login success');
    } catch (error) {
      clearInterval(rotateInterval);
      this.avatarRotateY = 0;
      const err = error as BusinessError;
      hilog.error(0x0000, TAG, 'Login failed: %{public}d', err.code);
      this.isLoggingIn = false;
    }
  }

  build() {
    Column() {
      // 头像区域
      Stack({ alignContent: Alignment.Center }) {
        // 光圈
        Column()
          .width(100)
          .height(100)
          .borderRadius(50)
          .border({ width: 2, color: $r('app.color.brand') })
          .opacity(this.ringOpacity)
          .scale({ x: this.ringScale, y: this.ringScale })
          .animation({ curve: curves.springMotion(0.5, 0.8) })

        // 头像
        if (this.currentAvatar) {
          Image(this.currentAvatar)
            .width(80)
            .height(80)
            .borderRadius(40)
        } else {
          Image($r("app.media.default_avatar"))
            .width(80)
            .height(80)
            .borderRadius(40)
        }
      }
      .width(100)
      .height(100)
      .margin({ top: 32 })
      .rotate({ y: 1, angle: this.avatarRotateY })

      // 昵称/提示文字
      Text(this.currentNickname || '请通过华为账号登录')
        .fontSize(16)
        .fontWeight(this.loginSuccess ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.loginSuccess ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
        .margin({ top: 16 })

      // 按钮区域（高度动画）
      Column({ space: 12 }) {
        if (this.loginSuccess) {
          // 已登录：显示更新和退出按钮
          Button() {
            Row({ space: 8 }) {
              SymbolGlyph($r('sys.symbol.arrow_clockwise'))
                .fontSize(18)
                .fontColor([Color.White])
              Text('更新头像和昵称')
                .fontSize(15)
                .fontColor(Color.White)
            }
          }
          .width('100%')
          .height(44)
          .backgroundColor($r('app.color.brand'))
          .borderRadius(22)
          .enabled(!this.isLoggingIn)
          .onClick(() => this.updateUserInfo())

          Button() {
            Row({ space: 6 }) {
              SymbolGlyph($r('sys.symbol.arrow_right_circle'))
                .fontSize(18)
                .fontColor([$r('app.color.text_secondary')])
              Text('退出登录')
                .fontSize(15)
                .fontColor($r('app.color.text_secondary'))
            }
          }
          .width('100%')
          .height(44)
          .backgroundColor($r('app.color.action_bg'))
          .borderRadius(22)
          .onClick(() => {
            this.profile.reset();
            this.currentAvatar = '';
            this.currentNickname = '';
            this.loginSuccess = false;
            this.buttonAreaHeight = 0;
            this.onClose();
          })
        } else {
          // 未登录：显示华为登录按钮
          Button() {
            Row({ space: 8 }) {
              SymbolGlyph($r('sys.symbol.person'))
                .fontSize(20)
                .fontColor([Color.White])
              Text('华为账号登录')
                .fontSize(16)
                .fontColor(Color.White)
            }
          }
          .width('100%')
          .height(44)
          .backgroundColor('#C7000B')
          .borderRadius(22)
          .enabled(!this.isLoggingIn)
          .opacity(this.isLoggingIn ? 0 : 1)
          .animation({ curve: Curve.EaseOut })
          .onClick(() => this.updateUserInfo())
        }
      }
      .width('100%')
      .height(this.buttonAreaHeight + 44) // 初始高度44（一个按钮），登录成功后增加
      .margin({ top: 20 })
      .padding({ left: 20, right: 20 })
      .clip(true)
      .animation({ curve: curves.springMotion(0.5, 0.8), duration: 500 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }
}
