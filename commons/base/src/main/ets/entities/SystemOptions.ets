/**
 * Copyright (C), 2025-09-26
 * @author ZestBox
 * @date 2025/09/26 
 * @version 1.0
 * @description: 系统设置项
 */

@ObservedV2
export class SystemOptions {
  // 首次运行
  @Trace firstStart: boolean = true
  // 主题索引
  @Trace themeIndex: number = 0
  // 字体粗细值：100=较细, 500=正常, 900=较粗
  @Trace fontThickness: number = 500
  // 图标粗细值：100=较细, 500=正常, 900=较粗
  @Trace iconThickness: number = 500
  // 通知开关
  @Trace notificationEnabled: boolean = true
  // 账单提醒
  @Trace billReminderEnabled: boolean = true
  // 预算预警
  @Trace budgetAlertEnabled: boolean = true
  // 每日记账提醒
  @Trace dailyReminderEnabled: boolean = false
  // 周报月报提醒
  @Trace weeklyMonthlyReportEnabled: boolean = true
  // 深色模式：auto, light, dark
  @Trace darkMode: string = 'auto'
  // 本地日志记录
  @Trace logRecording: boolean = false

  /**
   * 从另一个 SystemOptions 对象更新当前实例的所有属性。
   * 逐一赋值可以触发 @Trace 关联的 PersistenceV2 持久化更新。
   * @param data 源 SystemOptions 对象
   */
  updateFromData(data: SystemOptions): void {
    this.firstStart = data.firstStart
    this.themeIndex = data.themeIndex
    this.fontThickness = data.fontThickness
    this.iconThickness = data.iconThickness
    this.notificationEnabled = data.notificationEnabled
    this.billReminderEnabled = data.billReminderEnabled
    this.budgetAlertEnabled = data.budgetAlertEnabled
    this.dailyReminderEnabled = data.dailyReminderEnabled
    this.weeklyMonthlyReportEnabled = data.weeklyMonthlyReportEnabled
    this.darkMode = data.darkMode
    this.logRecording = data.logRecording
  }
}
