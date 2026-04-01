import { UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AbilityConstant, common, StartOptions, Want } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { AppStorageV2 } from '@kit.ArkUI';

// 定义窗口沉浸模式枚举类型
export enum ImmersiveType {
  // 普通模式，显示系统装饰栏和状态栏
  NORMAL,
  // 沉浸模式，隐藏系统装饰但保留状态栏可见
  IMMERSIVE,
  // 全屏沉浸模式，完全隐藏所有系统UI元素
  FULLSCREEN_IMMERSIVE
}

// 窗口信息管理类，用于存储当前窗口的各种属性与状态
@ObservedV2
export class WindowInfo {
  // 当前窗口的状态类型（如最小化、最大化、全屏等）
  public windowStatusType: window.WindowStatusType = window.WindowStatusType.UNDEFINED;
  // 当前设置的沉浸模式类型
  public isImmersive: ImmersiveType = ImmersiveType.NORMAL;
  // 当前窗口的方向设置
  public orientation: window.Orientation = window.Orientation.UNSPECIFIED;
  // 当前窗口的实际尺寸
  public windowSize: window.Size = { width: 0, height: 0 };
  // 当前窗口宽度对应的断点等级
  @Trace widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_XS;
  // 当前窗口高度对应的断点等级
  @Trace heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
  // 需要避开的系统区域范围
  public AvoidSystem?: window.AvoidArea;
  // 导航指示器需要避开的区域
  public AvoidNavigationIndicator?: window.AvoidArea;
  // 刘海屏区域需要避开的部分
  public AvoidCutout?: window.AvoidArea;
  // 系统手势操作所需避开的区域
  public AvoidSystemGesture?: window.AvoidArea;
  // 软键盘弹出时需避开的区域
  public AvoidKeyboard?: window.AvoidArea;
}

// 窗口工具类，提供对ArkUI窗口对象的一系列封装操作
@ObservedV2
export class WindowUtil {
  // 主窗口实例，代表当前应用的主要显示窗口
  public mainWindow: window.Window;
  public uiContext: UIContext = new UIContext();
  // 存储主窗口相关信息的对象
  @Trace mainWindowInfo: WindowInfo = new WindowInfo();
  // 窗口状态变化回调函数
  public onStatusTypeChange: (statusType: window.WindowStatusType) => void = (statusType: window.WindowStatusType) => {
    this.mainWindowInfo.windowStatusType = statusType;
  }
  // 窗口尺寸变化回调函数
  public onWindowSizeChange = (windowSize: window.Size) => {
    const uiContext = this.mainWindow.getUIContext() // 获取当前窗口的getUIContext
    this.mainWindowInfo.windowSize = windowSize;
    this.mainWindowInfo.widthBp = uiContext!.getWindowWidthBreakpoint();
    this.mainWindowInfo.heightBp = uiContext!.getWindowHeightBreakpoint();
    console.log('this.mainWindowInfo.widthBp', this.mainWindowInfo.widthBp)
  };
  // 避免区域变化回调函数
  public onAvoidAreaChange: (avoidOptions: window.AvoidAreaOptions) => void =
    (avoidOptions: window.AvoidAreaOptions) => {
      if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM) {
        this.mainWindowInfo.AvoidSystem = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_CUTOUT) {
        this.mainWindowInfo.AvoidCutout = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM_GESTURE) {
        this.mainWindowInfo.AvoidSystemGesture = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_KEYBOARD) {
        this.mainWindowInfo.AvoidKeyboard = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        this.mainWindowInfo.AvoidNavigationIndicator = avoidOptions.area;
      }
    };

  // 构造函数，初始化主窗口实例
  constructor(mainWindow: window.Window) {
    this.mainWindow = mainWindow;
  }

  // 设置窗口沉浸模式类型
  setImmersiveType(type: ImmersiveType) {
    try {
      if (type === ImmersiveType.NORMAL) {
        // 普通模式设置
        this.mainWindow.setWindowLayoutFullScreen(false)
          .then(() => {
            hilog.info(0x0000, 'testLog', `Succeeded in setting immersive mode.`);
          })
          .catch((err: BusinessError) => {
            hilog.error(0x0000, 'testLog', `Failed to set immersive mode. Code: ${err.code}, message: ${err.message}`);
          });
        this.setSystemBarEnabled(true);
        this.mainWindow.setWindowDecorVisible(true);
        this.recover();
      } else if (type === ImmersiveType.IMMERSIVE) {
        // 沉浸模式设置
        this.mainWindow.setWindowLayoutFullScreen(true)
          .then(() => {
            hilog.info(0x0000, 'testLog', `Succeeded in setting immersive mode.`);
          })
          .catch((err: BusinessError) => {
            hilog.error(0x0000, 'testLog', `Failed to set immersive mode. Code: ${err.code}, message: ${err.message}`);
          });
        this.setSystemBarEnabled(true);
        this.mainWindow.setWindowDecorVisible(false);
        this.recover();
      } else if (type === ImmersiveType.FULLSCREEN_IMMERSIVE) {
        // 全屏沉浸模式设置
        this.mainWindow.setWindowLayoutFullScreen(true)
          .then(() => {
            hilog.info(0x0000, 'testLog', `Succeeded in setting immersive mode.`);
          })
          .catch((err: BusinessError) => {
            hilog.error(0x0000, 'testLog', `Failed to set immersive mode. Code: ${err.code}, message: ${err.message}`);
          });
        if (this.mainWindow.getWindowStatus() === window.WindowStatusType.MAXIMIZE ||
          (this.mainWindow.getWindowStatus() === window.WindowStatusType.FLOATING &&
            this.mainWindow.getWindowDecorHeight() !== 0)) {
          this.mainWindow.maximize()
            .then(() => {
              hilog.info(0x0000, 'testLog', `Succeeded in maximizing the window.`);
            })
            .catch((err: BusinessError) => {
              hilog.error(0x0000, 'testLog',
                `Failed to maximize the window. Code: ${err.code}, message: ${err.message}`);
            });
        }
        this.setSystemBarEnabled(false);
        this.mainWindow.setWindowDecorVisible(false);
      }
      this.mainWindowInfo.isImmersive = type;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to set immersive type. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // 设置系统状态栏是否可见
  setSystemBarEnabled(isVisible: boolean): void {
    this.mainWindow.setSpecificSystemBarEnabled('status', isVisible)
      .then(() => {
        hilog.info(0x0000, 'testLog', `Succeeded in setting status bar to be invisible.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testLog',
          `Failed to set status bar to be invisible. Code: ${err.code}, message: ${err.message}`);
      });
    this.mainWindow.setSpecificSystemBarEnabled('navigationIndicator', isVisible)
      .then(() => {
        hilog.info(0x0000, 'testLog', `Succeeded in setting navigation indicator to be invisible.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testLog',
          `Failed to set navigation indicator to be invisible. Code: ${err.code}, message: ${err.message}`);
      });
  }

  // 恢复窗口状态
  recover(): void {
    try {
      if (this.mainWindow.getWindowStatus() === window.WindowStatusType.FULL_SCREEN) {
        this.mainWindow.recover()
          .then(() => {
            hilog.info(0x0000, 'testLog', `Succeeded in revocering the window.`);
          })
          .catch((err: BusinessError) => {
            hilog.error(0x0000, 'testLog', `Failed to revocer the window. Code: ${err.code}, message: ${err.message}`);
          });
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to recover. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // 设置窗口方向
  setWindowOrientation(orientation: window.Orientation): void {
    this.mainWindow.setPreferredOrientation(orientation)
      .then(() => {
        hilog.info(0x0000, 'testLog', `Succeeded in setting window orientation.`);
        // 更新窗口方向信息
        this.mainWindowInfo.orientation = orientation;
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testLog', `Failed to set window orientation. Code: ${err.code}, message: ${err.message}`);
      });
  }

  // 更新窗口信息
  updateWindowInfo(): void {
    try {
      this.mainWindowInfo.windowStatusType = this.mainWindow.getWindowStatus();
      this.mainWindow.on('windowStatusChange', this.onStatusTypeChange);

      let width: number = this.mainWindow.getWindowProperties().windowRect.width;
      let height: number = this.mainWindow.getWindowProperties().windowRect.height;
      let windowSize: window.Size = {
        width: width,
        height: height
      }
      this.mainWindowInfo.windowSize = windowSize;

      this.mainWindowInfo.widthBp = this.uiContext!.getWindowWidthBreakpoint();
      this.mainWindowInfo.heightBp = this.uiContext!.getWindowHeightBreakpoint();

      this.mainWindow.on('windowSizeChange', this.onWindowSizeChange);
      this.mainWindowInfo.AvoidSystem = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.mainWindowInfo.AvoidNavigationIndicator =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.mainWindowInfo.AvoidCutout = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
      this.mainWindowInfo.AvoidSystemGesture =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM_GESTURE);
      this.mainWindowInfo.AvoidKeyboard = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD);
      this.mainWindow.on('avoidAreaChange', this.onAvoidAreaChange);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, `TestLog`, `Failed to update window info. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // 释放监听事件
  release(): void {
    try {
      this.mainWindow.off('windowStatusChange');
      this.mainWindow.off('windowSizeChange');
      this.mainWindow.off('avoidAreaChange');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to off. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // 设置分屏模式
  setSplitScreen(bundleName: string, abilityName: string, moduleName: string): void {
    let context = this.uiContext?.getHostContext() as common.UIAbilityContext;
    let option: StartOptions = { windowMode: AbilityConstant.WindowMode.WINDOW_MODE_SPLIT_PRIMARY };
    let want: Want = { bundleName: bundleName, abilityName: abilityName, moduleName: moduleName };
    context.startAbility(want, option).catch((err: BusinessError) => {
      hilog.error(0x0000, 'TestLog', `Failed to start ability. Code: ${err.code}, message: ${err.message}`);
    });
  }

  // 取消分屏模式
  cancelSplitScreen(): void {
    let context = this.uiContext?.getHostContext() as common.UIAbilityContext;
    context.terminateSelf().catch((err: BusinessError) => {
      hilog.error(0x0000, 'TestLog', `Failed to terminate self. Code: ${err.code}, message: ${err.message}`);
    });
  }

  // 设置窗口限制尺寸
  setWindowLimits(maxWidth: number, maxHeight: number, minWidth: number, minHeight: number): void {
    let windowLimits: window.WindowLimits = {
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      minWidth: minWidth,
      minHeight: minHeight
    }
    this.mainWindow.setWindowLimits(windowLimits).then((data: window.WindowLimits) => {
      hilog.info(0x0000, 'testLog', `Succeeded in changing the window limits. Cause: ${JSON.stringify(data)}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testLog',
        `Failed to change the window limits. Cause code: ${err.code}, message: ${err.message}`);
    });
  }

  // 调整窗口尺寸
  resize(width: number, height: number): void {
    this.mainWindow.resize(width, height, (err: BusinessError) => {
      const errCode: number = err.code;
      if (errCode) {
        hilog.error(0x0000, 'testLog',
          `Failed to change the window size. Cause code: ${err.code}, message: ${err.message}`);
        return;
      }
      hilog.info(0x0000, 'testLog', 'Succeeded in changing the window size.');
    });
  }

  // 通过资源管理器查询方向信息
  queryOrientationByResourceManager(): void {
    let info: resourceManager.Direction | undefined =
      this.uiContext?.getHostContext()?.resourceManager.getConfigurationSync().direction;
    hilog.info(0x0000, 'testLog', `The Orientation is ${info}`);
  }

  // 计算设备倾斜角度
  getCalDegree(x: number, y: number, z: number): number {
    let degree: number = 0;
    // 判断设备是否处于水平状态
    if ((x * x + y * y) * 3 < z * z) {
      return degree;
    }
    // 计算角度值
    degree = 90 - (Number)(Math.round(Math.atan2(y, -x) / Math.PI * 180));
    return degree >= 0 ? degree % 360 : degree % 360 + 360;
  }
  @Computed
  get topSafeHeight(): number {
    const pxHeight = this.mainWindowInfo.AvoidSystem?.topRect.height || 0;
    return this.uiContext.px2vp(pxHeight);
  }

  // 底部安全区 (vp) - 自动监听 AvoidNavigationIndicator 的变化并换算
  @Computed
  get bottomSafeHeight(): number {
    const pxHeight = this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height || 0;
    return this.uiContext.px2vp(pxHeight);
  }
}


