/**
 * Copyright (C), 2026-03-26
 * @author ZestBox
 * @date 2026-03-26 
 * @version 1.0
 * @description: 
 */


const TAG: string = '[GlobalContext]';


export class GlobalContext {
  private static context: UIContext;

  public static initContext(context: UIContext): void {
    GlobalContext.context = context;
  }

  public static getContext(): UIContext {
    return GlobalContext.context;
  }
}

