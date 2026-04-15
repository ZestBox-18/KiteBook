import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { GlobalContext, ImmersiveType, WindowUtil } from 'kite_utils';
import { dbManagerInit } from 'base';


const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  windowUtil?: WindowUtil;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    // 初始化数据库
    dbManagerInit(this.context);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    try {
      this.windowUtil = new WindowUtil(windowStage.getMainWindowSync());
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to get main window. Code: ${err.code}, message: ${err.message}`);
    }

    windowStage.loadContent('pages/Index', (err) => {
      try {
        GlobalContext.initContext(windowStage.getMainWindowSync().getUIContext())
      } catch (error) {
        hilog.error(DOMAIN, 'testTag', 'Failed to get the content. Cause: %{public}s', JSON.stringify(err));
      }
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      /**
       * 窗口管理类创建/设置沉浸式窗口
       */
      this.windowUtil!.setUIContext();
      this.windowUtil!.setImmersiveType(ImmersiveType.IMMERSIVE);
      this.windowUtil!.updateWindowInfo();
      AppStorageV2.connect(WindowUtil, 'winUtil', () => this.windowUtil)

    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}