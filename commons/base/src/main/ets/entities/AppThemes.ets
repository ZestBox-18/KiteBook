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
  '#2B3A4A',
  'rgba(43, 58, 74, 0.08)',
  '#2B3A4A',
  '#5F7B8A',
  'rgba(43, 58, 74, 0.2)',
  'rgba(95, 123, 138, 0.35)',
  '#4A6070',
  'rgba(74, 96, 112, 0.15)',
  '#4A6070',
  '#8CA0AE',
  'rgba(74, 96, 112, 0.3)',
  'rgba(140, 160, 174, 0.4)'
);

export let gAppThemeDeepSea: CustomTheme = new AppTheme(
  '#1E4E79',
  'rgba(30, 78, 121, 0.08)',
  '#1E4E79',
  '#5B8DB8',
  'rgba(30, 78, 121, 0.2)',
  'rgba(91, 141, 184, 0.35)',
  '#3A6E8A',
  'rgba(58, 110, 138, 0.15)',
  '#3A6E8A',
  '#7FA8C4',
  'rgba(58, 110, 138, 0.3)',
  'rgba(127, 168, 196, 0.4)'
);

export let gAppThemeMysticCyan: CustomTheme = new AppTheme(
  '#2E6B6B',
  'rgba(46, 107, 107, 0.08)',
  '#2E6B6B',
  '#62A3A3',
  'rgba(46, 107, 107, 0.2)',
  'rgba(98, 163, 163, 0.35)',
  '#4A8E8E',
  'rgba(74, 142, 142, 0.15)',
  '#4A8E8E',
  '#8FBFBF',
  'rgba(74, 142, 142, 0.3)',
  'rgba(143, 191, 191, 0.4)'
);

export let gAppThemeSandGold: CustomTheme = new AppTheme(
  '#8A6B3D',
  'rgba(138, 107, 61, 0.08)',
  '#8A6B3D',
  '#C0A06B',
  'rgba(138, 107, 61, 0.2)',
  'rgba(192, 160, 107, 0.35)',
  '#A68850',
  'rgba(166, 136, 80, 0.15)',
  '#A68850',
  '#D4BA86',
  'rgba(166, 136, 80, 0.3)',
  'rgba(212, 186, 134, 0.4)'
);

export let gAppThemeTerracotta: CustomTheme = new AppTheme(
  '#9E5A3C',
  'rgba(158, 90, 60, 0.08)',
  '#9E5A3C',
  '#C88A6C',
  'rgba(158, 90, 60, 0.2)',
  'rgba(200, 138, 108, 0.35)',
  '#B87050',
  'rgba(184, 112, 80, 0.15)',
  '#B87050',
  '#D9A28A',
  'rgba(184, 112, 80, 0.3)',
  'rgba(217, 162, 138, 0.4)'
);

export let gAppThemeCloudGray: CustomTheme = new AppTheme(
  '#607080',
  'rgba(96, 112, 128, 0.08)',
  '#607080',
  '#92A0AE',
  'rgba(96, 112, 128, 0.2)',
  'rgba(146, 160, 174, 0.35)',
  '#7A8A98',
  'rgba(122, 138, 152, 0.15)',
  '#7A8A98',
  '#A8B6C2',
  'rgba(122, 138, 152, 0.3)',
  'rgba(168, 182, 194, 0.4)'
);

export let gAppThemeMoonWhite: CustomTheme = new AppTheme(
  '#5D8899',
  'rgba(93, 136, 153, 0.08)',
  '#5D8899',
  '#8FB4C4',
  'rgba(93, 136, 153, 0.2)',
  'rgba(143, 180, 196, 0.35)',
  '#7DA0B0',
  'rgba(125, 160, 176, 0.15)',
  '#7DA0B0',
  '#A8C5D0',
  'rgba(125, 160, 176, 0.3)',
  'rgba(168, 197, 208, 0.4)'
);

export let gAppThemeRock: CustomTheme = new AppTheme(
  '#6A5E55',
  'rgba(106, 94, 85, 0.08)',
  '#6A5E55',
  '#A09088',
  'rgba(106, 94, 85, 0.2)',
  'rgba(160, 144, 136, 0.35)',
  '#8A7C72',
  'rgba(138, 124, 114, 0.15)',
  '#8A7C72',
  '#B8AAA0',
  'rgba(138, 124, 114, 0.3)',
  'rgba(184, 170, 160, 0.4)'
);

export let gAppThemeDuskPurple: CustomTheme = new AppTheme(
  '#5C4D7A',
  'rgba(92, 77, 122, 0.08)',
  '#5C4D7A',
  '#8E7CB0',
  'rgba(92, 77, 122, 0.2)',
  'rgba(142, 124, 176, 0.35)',
  '#746494',
  'rgba(116, 100, 148, 0.15)',
  '#746494',
  '#A898C2',
  'rgba(116, 100, 148, 0.3)',
  'rgba(168, 152, 194, 0.4)'
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


