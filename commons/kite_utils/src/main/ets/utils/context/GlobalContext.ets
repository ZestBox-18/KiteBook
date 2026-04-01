/**
 * Copyright (C), 2026-03-26
 * @author ZestBox
 * @date 2026-03-26 
 * @version 1.0
 * @description: 
 */
import { common } from '@kit.AbilityKit';


const TAG: string = '[GlobalContext]';


export class GlobalContext {
  private static context: common.UIAbilityContext;

  public static initContext(context: common.UIAbilityContext): void {
    GlobalContext.context = context;
  }

  public static getContext(): common.UIAbilityContext {
    return GlobalContext.context;
  }
}

