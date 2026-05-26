/**
 * Copyright (C), 2026-04-21
 * @author ZestBox
 * @date 2026/04/21
 * @version 1.0
 * @description: 用户信息实体类
 */

import { PersistenceV2 } from '@ohos.arkui.StateManagement';

const TAG: string = '[UserProfile]';

@ObservedV2
export class UserProfile {
  // 用户昵称
  @Trace nickname: string = '用户昵称'
  // 头像路径
  @Trace avatar: string = ''
  // 用户ID
  @Trace userId: string = ''
  // 华为 openId
  @Trace openId: string = ''
  // 华为 unionId
  @Trace unionId: string = ''
  // 登录状态
  @Trace isLoggedIn: boolean = false

  @Monitor('nickname', 'avatar', 'userId', 'openId', 'unionId', 'isLoggedIn')
  onDataChange(monitor: IMonitor) {
    PersistenceV2.save('UserProfile')
  }

  /**
   * 重置用户信息（退出登录）
   */
  reset(): void {
    this.nickname = '用户昵称'
    this.avatar = ''
    this.userId = ''
    this.openId = ''
    this.unionId = ''
    this.isLoggedIn = false
  }

  /**
   * 从华为账号信息更新
   */
  updateFromHuaweiAccount(displayName: string, photoUrl: string, openId: string, unionId: string): void {
    this.nickname = displayName || '用户'
    this.avatar = photoUrl || ''
    this.openId = openId || ''
    this.unionId = unionId || ''
    this.userId = openId || ''
    this.isLoggedIn = true
  }

  /**
   * 从另一个用户档案对象同步数据。
   */
  updateFromData(data: UserProfile): void {
    this.nickname = data.nickname
    this.avatar = data.avatar
    this.userId = data.userId
    this.openId = data.openId
    this.unionId = data.unionId
    this.isLoggedIn = data.isLoggedIn
  }
}
