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

  // 用户名动画状态
  @Local oldTextOpacity: number = 1
  @Local oldTextTranslateX: number = 0
  @Local newTextOpacity: number = 0
  @Local newTextTranslateX: number = 30

  // 按钮动画状态
  @Local loginBtnOpacity: number = 1      // 华为登录按钮透明度
  @Local loginBtnScale: number = 1        // 华为登录按钮缩放
  @Local updateBtnOpacity: number = 0     // 更新按钮透明度
  @Local updateBtnScale: number = 0.5     // 更新按钮缩放（从中心聚合）
  @Local logoutBtnOpacity: number = 0     // 退出按钮透明度
  @Local logoutBtnScale: number = 0.5     // 退出按钮缩放（从中心聚合）

  aboutToAppear() {
    if (this.profile.isLoggedIn) {
      this.currentAvatar = this.profile.avatar;
      this.currentNickname = this.profile.nickname;
      this.loginSuccess = true;
      // 已登录状态，直接显示最终状态
      this.oldTextOpacity = 0;
      this.newTextOpacity = 1;
      this.newTextTranslateX = 0;
      this.loginBtnOpacity = 0;
      this.loginBtnScale = 1.5;
      this.updateBtnOpacity = 1;
      this.updateBtnScale = 1;
      this.logoutBtnOpacity = 1;
      this.logoutBtnScale = 1;
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

      // 登录成功
      this.loginSuccess = true;

      // 用户名动画：左右滑动
      animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
        this.oldTextOpacity = 0;
        this.oldTextTranslateX = -30;
      });

      animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
        this.newTextOpacity = 1;
        this.newTextTranslateX = 0;
      });

      // 华为登录按钮：放大虚化消失
      animateTo({ curve: curves.springMotion(0.6, 0.85), duration: 350 }, () => {
        this.loginBtnOpacity = 0;
        this.loginBtnScale = 1.5;
      });

      // 更新按钮：弹性曲线出现（类似光圈效果）
      setTimeout(() => {
        // 先放大超过目标
        animateTo({ curve: curves.springMotion(0.5, 0.7), duration: 300 }, () => {
          this.updateBtnOpacity = 1;
          this.updateBtnScale = 1.15;
        });
        // 然后弹回目标大小
        setTimeout(() => {
          animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 200 }, () => {
            this.updateBtnScale = 1;
          });
        }, 250);
      }, 150);

      // 退出按钮：弹性曲线出现（类似光圈效果）
      setTimeout(() => {
        // 先放大超过目标
        animateTo({ curve: curves.springMotion(0.5, 0.7), duration: 300 }, () => {
          this.logoutBtnOpacity = 1;
          this.logoutBtnScale = 1.15;
        });
        // 然后弹回目标大小
        setTimeout(() => {
          animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 200 }, () => {
            this.logoutBtnScale = 1;
          });
        }, 250);
      }, 250);

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

      // 昵称/提示文字区域（使用Stack实现文字切换动画）
      Stack() {
        // 旧文字："请通过华为账号登录"
        Text('请通过华为账号登录')
          .fontSize(16)
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.text_secondary'))
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
      .height(24)
      .margin({ top: 16 })

      // 按钮区域
      Column({ space: 12 }) {
        // 第一行：华为登录按钮和更新按钮叠加
        Stack() {
          // 华为登录按钮（放大虚化消失）
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
          .opacity(this.loginBtnOpacity)
          .scale({ x: this.loginBtnScale, y: this.loginBtnScale })
          .onClick(() => this.updateUserInfo())

          // 更新按钮（聚合实化出现，主题色）
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
          .opacity(this.updateBtnOpacity)
          .scale({ x: this.updateBtnScale, y: this.updateBtnScale })
          .onClick(() => this.updateUserInfo())
        }
        .width('100%')
        .height(44)

        // 第二行：退出登录按钮（聚合实化出现，灰色背景）
        if (this.loginSuccess) {
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
          .opacity(this.logoutBtnOpacity)
          .scale({ x: this.logoutBtnScale, y: this.logoutBtnScale })
          .onClick(() => {
            this.profile.reset();
            this.currentAvatar = '';
            this.currentNickname = '';
            this.loginSuccess = false;
            // 重置动画状态
            this.oldTextOpacity = 1;
            this.oldTextTranslateX = 0;
            this.newTextOpacity = 0;
            this.newTextTranslateX = 30;
            this.loginBtnOpacity = 1;
            this.loginBtnScale = 1;
            this.updateBtnOpacity = 0;
            this.updateBtnScale = 0.5;
            this.logoutBtnOpacity = 0;
            this.logoutBtnScale = 0.5;
            this.onClose();
          })
        }
      }
      .width('100%')
      .margin({ top: 20 })
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }
}
