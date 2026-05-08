import { CustomColors, CustomTheme } from '@kit.ArkUI';

export class AppColors implements CustomColors {
  // 品牌色
  brand: string // 按钮色
  // // 文本颜色
  fontPrimary: string // 一级文本 // 部分文本颜色
  // 图标颜色
  iconPrimary: string // 一级图标 // 所有图标颜色
  iconEmphasize: string // 高亮图标 // 悦览主页设置点击后的颜色
  // // 背景颜色
  backgroundPrimary: string // 一级背景（实色/不透明色）
  // // 组件颜色
  compBackgroundNeutral: string // 黑色中性高亮背景 多页面卡片边框

  constructor(brand: string, fontPrimary: string, iconPrimary: string, iconEmphasize: string, backgroundPrimary: string,
    compBackgroundNeutral: string) {
    this.brand = brand
    this.fontPrimary = fontPrimary
    this.iconPrimary = iconPrimary
    this.iconEmphasize = iconEmphasize
    this.backgroundPrimary = backgroundPrimary
    this.compBackgroundNeutral = compBackgroundNeutral
  }
}

export class AppTheme implements CustomTheme {
  public colors: AppColors;
  public darkColors?: AppColors;

  constructor(brand: string, fontPrimary: string, iconPrimary: string, iconEmphasize: string, backgroundPrimary: string,
    compBackgroundNeutral: string, darkBrand?: string, darkFontPrimary?: string, darkIconPrimary?: string,
    darkIconEmphasize?: string, darkBackgroundPrimary?: string, darkCompBackgroundNeutral?: string) {
    this.colors =
      new AppColors(brand, fontPrimary, iconPrimary, iconEmphasize, backgroundPrimary, compBackgroundNeutral);

    if (darkBrand !== undefined) {
      this.darkColors =
        new AppColors(darkBrand, darkFontPrimary || fontPrimary, darkIconPrimary || iconPrimary,
          darkIconEmphasize || iconEmphasize, darkBackgroundPrimary || backgroundPrimary,
          darkCompBackgroundNeutral || compBackgroundNeutral);
    }
  }
}

export let gAppThemePineInk: CustomTheme = new AppTheme(
  '#5A7A8A',
  'rgba(90, 122, 138, 0.08)',
  '#5A7A8A',
  '#7A9AA8',
  'rgba(90, 122, 138, 0.2)',
  'rgba(122, 154, 168, 0.35)',
  '#6A8A9A',
  'rgba(106, 138, 154, 0.15)',
  '#6A8A9A',
  '#8AAABA',
  'rgba(106, 138, 154, 0.3)',
  'rgba(138, 170, 186, 0.4)'
);

export let gAppThemeDeepSea: CustomTheme = new AppTheme(
  '#4A7EA8',
  'rgba(74, 126, 168, 0.08)',
  '#4A7EA8',
  '#6A9EC8',
  'rgba(74, 126, 168, 0.2)',
  'rgba(106, 158, 200, 0.35)',
  '#5A8EB8',
  'rgba(90, 142, 184, 0.15)',
  '#5A8EB8',
  '#7AAED8',
  'rgba(90, 142, 184, 0.3)',
  'rgba(122, 174, 216, 0.4)'
);

export let gAppThemeMysticCyan: CustomTheme = new AppTheme(
  '#5A9A9A',
  'rgba(90, 154, 154, 0.08)',
  '#5A9A9A',
  '#7ABABA',
  'rgba(90, 154, 154, 0.2)',
  'rgba(122, 186, 186, 0.35)',
  '#6AAAAA',
  'rgba(106, 170, 170, 0.15)',
  '#6AAAAA',
  '#8ACACA',
  'rgba(106, 170, 170, 0.3)',
  'rgba(138, 202, 202, 0.4)'
);

export let gAppThemeSandGold: CustomTheme = new AppTheme(
  '#A89060',
  'rgba(168, 144, 96, 0.08)',
  '#A89060',
  '#C8B080',
  'rgba(168, 144, 96, 0.2)',
  'rgba(200, 176, 128, 0.35)',
  '#B8A070',
  'rgba(184, 160, 112, 0.15)',
  '#B8A070',
  '#D8C090',
  'rgba(184, 160, 112, 0.3)',
  'rgba(216, 192, 144, 0.4)'
);

export let gAppThemeTerracotta: CustomTheme = new AppTheme(
  '#B87860',
  'rgba(184, 120, 96, 0.08)',
  '#B87860',
  '#D89880',
  'rgba(184, 120, 96, 0.2)',
  'rgba(216, 152, 128, 0.35)',
  '#C88870',
  'rgba(200, 136, 112, 0.15)',
  '#C88870',
  '#E8A890',
  'rgba(200, 136, 112, 0.3)',
  'rgba(232, 168, 144, 0.4)'
);

export let gAppThemeCloudGray: CustomTheme = new AppTheme(
  '#7A8A98',
  'rgba(122, 138, 152, 0.08)',
  '#7A8A98',
  '#9AAAB8',
  'rgba(122, 138, 152, 0.2)',
  'rgba(154, 170, 184, 0.35)',
  '#8A9AA8',
  'rgba(138, 154, 168, 0.15)',
  '#8A9AA8',
  '#AABAC8',
  'rgba(138, 154, 168, 0.3)',
  'rgba(170, 186, 200, 0.4)'
);

export let gAppThemeMoonWhite: CustomTheme = new AppTheme(
  '#7AA0B0',
  'rgba(122, 160, 176, 0.08)',
  '#7AA0B0',
  '#9AC0D0',
  'rgba(122, 160, 176, 0.2)',
  'rgba(154, 192, 208, 0.35)',
  '#8AB0C0',
  'rgba(138, 176, 192, 0.15)',
  '#8AB0C0',
  '#AAD0E0',
  'rgba(138, 176, 192, 0.3)',
  'rgba(170, 208, 224, 0.4)'
);

export let gAppThemeRock: CustomTheme = new AppTheme(
  '#8A7A70',
  'rgba(138, 122, 112, 0.08)',
  '#8A7A70',
  '#AA9A90',
  'rgba(138, 122, 112, 0.2)',
  'rgba(170, 154, 144, 0.35)',
  '#9A8A80',
  'rgba(154, 138, 128, 0.15)',
  '#9A8A80',
  '#BAAAA0',
  'rgba(154, 138, 128, 0.3)',
  'rgba(186, 170, 160, 0.4)'
);

export let gAppThemeDuskPurple: CustomTheme = new AppTheme(
  '#8A70A0',
  'rgba(138, 112, 160, 0.08)',
  '#8A70A0',
  '#AA90C0',
  'rgba(138, 112, 160, 0.2)',
  'rgba(170, 144, 192, 0.35)',
  '#9A80B0',
  'rgba(154, 128, 176, 0.15)',
  '#9A80B0',
  '#BAA0D0',
  'rgba(154, 128, 176, 0.3)',
  'rgba(186, 160, 208, 0.4)'
);


export let gAppThemes: CustomTheme[] = [
  gAppThemePineInk,
  gAppThemeDeepSea,
  gAppThemeMysticCyan,
  gAppThemeSandGold,
  gAppThemeTerracotta,
  gAppThemeCloudGray,
  gAppThemeMoonWhite,
  gAppThemeRock,
  gAppThemeDuskPurple
];

export let gAppThemesDict: Map<string, CustomTheme> = new Map([
  ['松墨', gAppThemePineInk],
  ['深海', gAppThemeDeepSea],
  ['玄青', gAppThemeMysticCyan],
  ['砂金', gAppThemeSandGold],
  ['赤陶', gAppThemeTerracotta],
  ['云雾灰', gAppThemeCloudGray],
  ['月白', gAppThemeMoonWhite],
  ['岩石', gAppThemeRock],
  ['暮紫', gAppThemeDuskPurple]
]);


export let defaultAppTheme: CustomTheme = gAppThemes[0];


