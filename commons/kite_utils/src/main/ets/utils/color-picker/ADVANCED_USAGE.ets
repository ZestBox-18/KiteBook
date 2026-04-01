import { HSBColorPicker, HSBColorPickerLayout } from "./components/ColorPicker"

@Builder
export function ColorPickerDemoBuilder(name: string, param: Object) {
  ColorPickerDemo()
}

@Extend(Text) function title() {
  .fontSize(18)
  .fontWeight(600)
  .padding({ top: 15, bottom: 12 })
}

@ComponentV2
struct ColorPickerDemo {
  router: NavPathStack = new NavPathStack()

  @Local color1: string = '#8b27f4'
  @Local color2: string = '#73f9fc'
  @Local color3: string = '#fffe55'
  @Local color4: string = '#f5cee3'
  @Local color5: string = '#eb4827'
  @Local color6: string = '#3e68f4'
  @Local color7: string = '#c5e6d3'

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Text('基础用法')
            .title()
          HSBColorPicker({
            color: this.color1,
          })
            .height(170)

          Text('选择透明度')
            .title()
          HSBColorPicker({
            color: this.color2,
            showAlpha: true
          })
            .height(200)

          Text('设置间距')
            .title()
          HSBColorPicker({
            color: this.color7,
            gutter: 0,
            showAlpha: true
          })
            .height(200)

          Text('设置圆角')
            .title()
          HSBColorPicker({
            color: this.color3,
            radius: 8,
            showAlpha: true
          })
            .height(200)

          Text('纵向布局')
            .title()
          HSBColorPicker({
            layout: HSBColorPickerLayout.COLUMN,
            color: this.color4,
            radius: 8,
            showAlpha: true
          })
            .height(200)

          Text('指定亮度范围')
            .title()
          HSBColorPicker({
            color: this.color5,
            radius: 8,
            b: [70, 100],
            showAlpha: true
          })
            .height(200)

          Text('预定义颜色')
            .title()
          HSBColorPicker({
            color: this.color6,
            radius: 8,
            showAlpha: true,
            predefine: ['#8b27f4', '#73f9fc', '#fffe55', '#f5cee3', '#eb4827', '#e93bf4', '#3e68f4', '#c5e6d3', '#e4e4e4', '#fa7105'],
            onChange: (value: string) => {
              this.color6 = value
            }
          })
            .height(270)
        }
        .justifyContent(FlexAlign.End)
        .width('100%')
      }
      .edgeEffect(EdgeEffect.Spring)
      .padding({ top: 30, bottom: 20, left: 15, right: 15 })
      .layoutWeight(1)
    }
    .title('颜色选择器')
    .onReady((ctx: NavDestinationContext) => {
      this.router = ctx.pathStack
    })
  }
}
