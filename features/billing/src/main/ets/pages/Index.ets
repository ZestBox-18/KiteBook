import { hdsEffect } from '@kit.UIDesignKit';

@Entry
@ComponentV2
export struct Index {
  @Local bloomValue: number = 0;
  @Local index: number = 0;
  @Local illuminatedType: hdsEffect.PointLightIlluminatedType = hdsEffect.PointLightIlluminatedType.NONE;
  @Local button_gradient_state: hdsEffect.PressShadowType = hdsEffect.PressShadowType.NONE;
  @Local lightIntensity: number = 1;
  @Local types: hdsEffect.PointLightIlluminatedType[] =
    [hdsEffect.PointLightIlluminatedType.NONE, hdsEffect.PointLightIlluminatedType.BORDER,
      hdsEffect.PointLightIlluminatedType.CONTENT, hdsEffect.PointLightIlluminatedType.BORDER_CONTENT,
      hdsEffect.PointLightIlluminatedType.DEFAULT_FEATHERING_BORDER];

  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center,
    }) {
      // 纵向循环
      ForEach(Array<number>(4).fill(0), (row: number) => {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center,
        }) {
          // 横向循环
          ForEach(Array<number>(4).fill(0), (col: number) => {
            Flex()
              .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
                illuminatedType: this.illuminatedType,
              }).buildEffect())
              .backgroundColor(0x808080)
              .size({ width: 60, height: 60 })
              .borderRadius(50)
              .margin({ top: 20, right: 10, left: 10 }) // 添加间距
          })
        }
        .width('100%') // 设置 Row 组件的宽度为 100%
      })

      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Center, // 使用 SpaceBetween 来均匀分布间距
        alignItems: ItemAlign.Center,
      }) {
        Flex()
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            illuminatedType: this.illuminatedType,
          }).buildEffect())
          .backgroundColor(0x808080)
          .size({ width: 60, height: 60 })
          .borderRadius(50)
          .margin({ top: 20, right: 10, left: 10 })

        Button('点击发光')
          .size({ width: 140, height: 60 })
          .backgroundColor(0x808080)
          .fontColor(0xADD8E6)
          .visualEffect(new hdsEffect.HdsEffectBuilder()
            .pressShadow(this.button_gradient_state)
            .pointLight({
              options: {
                color: Color.White,
                intensity: this.lightIntensity,
                height: 150,
                bloom: 20
              },
              sourceType: hdsEffect.PointLightSourceType.BRIGHT,
              illuminatedType: hdsEffect.PointLightIlluminatedType.DEFAULT_FEATHERING_BORDER
            })
            .pressShadow(this.button_gradient_state)
            .buildEffect())
          .onClick(() => {
            if (this.index <= 3) {
              this.index++;
              this.illuminatedType = this.types[this.index];
              this.button_gradient_state = hdsEffect.PressShadowType.BLEND_GRADIENT;
            }
            let message = 'NONE';
            if (this.illuminatedType == 1) {
              message = 'BORDER';
            } else if (this.illuminatedType == 2) {
              message = 'CONTENT';
            } else if (this.illuminatedType == 3) {
              message = 'BORDER_CONTENT';
            } else {
              message = 'DEFAULT_FEATHERING_BORDER';
            }
            this.getUIContext().getPromptAction().showToast({
              message: message,
              duration: 2000,
              bottom: '80%'
            });
          })
          .margin({ top: 20, right: 10, left: 10 })

        Flex()
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            illuminatedType: this.illuminatedType,
          }).buildEffect())
          .backgroundColor(0x808080)
          .size({ width: 60, height: 60 })
          .borderRadius(50)
          .margin({ top: 20, right: 10, left: 10 })
      }
      .width('100%') // 设置 Row 组件的宽度为 100%

      ForEach(Array<number>(4).fill(0), (row: number) => {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center,
        }) {
          // 横向循环
          ForEach(Array<number>(4).fill(0), (col: number) => {
            Flex()
              .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
                illuminatedType: this.illuminatedType,
              }).buildEffect())
              .backgroundColor(0x808080)
              .size({ width: 60, height: 60 })
              .borderRadius(50)
              .margin({ top: 20, right: 10, left: 10 })
          })
        }
        .width('100%') // 设置 Row 组件的宽度为 100%
      })
    }
    .backgroundColor(Color.Black)

  }
}