/**
 * 断点模块
 *
 * @ author ZestBox
 * @ since 2025-09-10
 */

interface BreakPointOption<T> {
  xs?: T,
  sm?: T,
  md?: T,
  lg?: T
}


export class BreakPoint<T> {
  private option: BreakPointOption<T>

  constructor(option: BreakPointOption<T>) {
    this.option = option
  }

  public getValue(currentBreakPoint: string) {
    if (currentBreakPoint === 'xs') {
      return this.option.xs
    } else if (currentBreakPoint === 'sm') {
      return this.option.sm
    } else if (currentBreakPoint === 'md') {
      return this.option.md
    } else if (currentBreakPoint === 'lg') {
      return this.option.lg
    } else {
      return this.option.xs
    }
  }
}