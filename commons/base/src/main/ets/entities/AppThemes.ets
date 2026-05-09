import { CustomColors, CustomTheme } from '@kit.ArkUI';

@ObservedV2
export class AppThemeState {
  // 品牌色：按钮、选中态、强调色
  @Trace brand: ResourceStr = '#4BB3FF'
  // 一级文本颜色
  @Trace fontPrimary: ResourceStr = '#1F2D3D'
  // 二级文本颜色
  @Trace fontSecondary: ResourceStr = '#5B6573'
  // 品牌色上的文字颜色
  @Trace fontOnPrimary: ResourceStr = '#FFFFFF'
  // 一级图标颜色
  @Trace iconPrimary: ResourceStr = '#5AB0E0'
  // 二级图标颜色
  @Trace iconSecondary: ResourceStr = '#7A8A98'
  // 强调态图标颜色
  @Trace iconEmphasize: ResourceStr = '#4BB3FF'
  // 品牌色上的图标颜色
  @Trace iconOnPrimary: ResourceStr = '#FFFFFF'
  // 页面主背景色
  @Trace backgroundPrimary: ResourceStr = '#F7FAFD'
  // 卡片/容器背景色
  @Trace compBackgroundPrimary: ResourceStr = '#FFFFFF'
  // 中性高亮背景色
  @Trace compBackgroundNeutral: ResourceStr = 'rgba(255,255,255,0.85)'
  // 分割线颜色
  @Trace compDivider: ResourceStr = 'rgba(31,45,61,0.08)'
}

export class AppColors implements CustomColors {
  // 品牌色：按钮、选中态、强调色
  brand: string
  // 一级文本颜色
  fontPrimary: string
  // 二级文本颜色
  fontSecondary: string
  // 品牌色上的文字颜色
  fontOnPrimary: string
  // 一级图标颜色
  iconPrimary: string
  // 二级图标颜色
  iconSecondary: string
  // 强调态图标颜色
  iconEmphasize: string
  // 品牌色上的图标颜色
  iconOnPrimary: string
  // 页面主背景色
  backgroundPrimary: string
  // 卡片/容器背景色
  compBackgroundPrimary: string
  // 中性高亮背景色
  compBackgroundNeutral: string
  // 分割线颜色
  compDivider: string

  constructor(
    brand: string,
    fontPrimary: string, fontSecondary: string, fontOnPrimary: string,
    iconPrimary: string, iconSecondary: string, iconEmphasize: string, iconOnPrimary: string,
    backgroundPrimary: string,
    compBackgroundPrimary: string, compBackgroundNeutral: string, compDivider: string
  ) {
    this.brand = brand
    this.fontPrimary = fontPrimary
    this.fontSecondary = fontSecondary
    this.fontOnPrimary = fontOnPrimary
    this.iconPrimary = iconPrimary
    this.iconSecondary = iconSecondary
    this.iconEmphasize = iconEmphasize
    this.iconOnPrimary = iconOnPrimary
    this.backgroundPrimary = backgroundPrimary
    this.compBackgroundPrimary = compBackgroundPrimary
    this.compBackgroundNeutral = compBackgroundNeutral
    this.compDivider = compDivider
  }
}

export class AppTheme implements CustomTheme {
  public colors: AppColors
  public darkColors?: AppColors

  constructor(
    brand: string,
    fontPrimary: string, fontSecondary: string, fontOnPrimary: string,
    iconPrimary: string, iconSecondary: string, iconEmphasize: string, iconOnPrimary: string,
    backgroundPrimary: string,
    compBackgroundPrimary: string, compBackgroundNeutral: string, compDivider: string,
    darkBrand?: string,
    darkFontPrimary?: string, darkFontSecondary?: string, darkFontOnPrimary?: string,
    darkIconPrimary?: string, darkIconSecondary?: string, darkIconEmphasize?: string, darkIconOnPrimary?: string,
    darkBackgroundPrimary?: string,
    darkCompBackgroundPrimary?: string, darkCompBackgroundNeutral?: string, darkCompDivider?: string
  ) {
    this.colors = new AppColors(
      brand,
      fontPrimary, fontSecondary, fontOnPrimary,
      iconPrimary, iconSecondary, iconEmphasize, iconOnPrimary,
      backgroundPrimary,
      compBackgroundPrimary, compBackgroundNeutral, compDivider
    )
    if (darkBrand) {
      this.darkColors = new AppColors(
        darkBrand,
        darkFontPrimary || fontPrimary,
        darkFontSecondary || fontSecondary,
        darkFontOnPrimary || fontOnPrimary,
        darkIconPrimary || iconPrimary,
        darkIconSecondary || iconSecondary,
        darkIconEmphasize || iconEmphasize,
        darkIconOnPrimary || iconOnPrimary,
        darkBackgroundPrimary || backgroundPrimary,
        darkCompBackgroundPrimary || compBackgroundPrimary,
        darkCompBackgroundNeutral || compBackgroundNeutral,
        darkCompDivider || compDivider
      )
    }
  }
}

// 纸鸢蓝
export let gThemeKiteBlue = new AppTheme(
  '#4BB3FF', '#1F2D3D', '#5B6573', '#FFFFFF', '#5AB0E0', '#7A8A98', '#4BB3FF', '#FFFFFF', '#F7FAFD', '#FFFFFF',
  'rgba(255,255,255,0.85)', 'rgba(31,45,61,0.08)',
  '#5AC0FF', '#E6F4FF', '#8091A1', '#FFFFFF', '#6CBFF0', '#8FA0B0', '#5AC0FF', '#FFFFFF', '#1E2835', '#1E2835',
  'rgba(30,40,50,0.85)', 'rgba(255,255,255,0.10)'
)

// 晴空蓝
export let gThemeSkyBlue = new AppTheme(
  '#5AC0FF', '#1F2D3D', '#5B6573', '#FFFFFF', '#4FADEC', '#7A8A98', '#5AC0FF', '#FFFFFF', '#F0F8FF', '#FFFFFF',
  'rgba(255,255,255,0.85)', 'rgba(31,45,61,0.08)',
  '#7AD4FF', '#E6F7FF', '#8091A1', '#FFFFFF', '#5BB7F0', '#8FA0B0', '#7AD4FF', '#FFFFFF', '#1A2633', '#1A2633',
  'rgba(30,40,50,0.85)', 'rgba(255,255,255,0.10)'
)

// 青柠绿
export let gThemeLimeGreen = new AppTheme(
  '#50D3A1', '#1F2D3D', '#5B6573', '#FFFFFF', '#3FC893', '#7A8A98', '#50D3A1', '#FFFFFF', '#F0FAF5', '#FFFFFF',
  'rgba(255,255,255,0.85)', 'rgba(31,45,61,0.08)',
  '#6DE0B8', '#E6FBF6', '#8091A1', '#FFFFFF', '#4BB38F', '#8FA0B0', '#6DE0B8', '#FFFFFF', '#112B23', '#112B23',
  'rgba(30,40,50,0.85)', 'rgba(255,255,255,0.10)'
)

// 柔沙金
export let gThemeSoftGold = new AppTheme(
  '#E1C67A', '#1F2D3D', '#5B6573', '#FFFFFF', '#CBB361', '#7A8A98', '#E1C67A', '#FFFFFF', '#FFF8F0', '#FFFFFF',
  'rgba(255,255,255,0.85)', 'rgba(31,45,61,0.08)',
  '#EEDD9A', '#FFF9EB', '#8091A1', '#FFFFFF', '#D4B860', '#8FA0B0', '#EEDD9A', '#FFFFFF', '#1A1410', '#1A1410',
  'rgba(30,20,16,0.85)', 'rgba(255,255,255,0.10)'
)

// 暮紫色
export let gThemeDuskPurple = new AppTheme(
  '#AA88D0', '#1F2D3D', '#5B6573', '#FFFFFF', '#9070B8', '#7A8A98', '#AA88D0', '#FFFFFF', '#F6F2FA', '#FFFFFF',
  'rgba(255,255,255,0.85)', 'rgba(31,45,61,0.08)',
  '#B99AD8', '#F0E9F7', '#8091A1', '#FFFFFF', '#9970C0', '#8FA0B0', '#B99AD8', '#FFFFFF', '#1A1122', '#1A1122',
  'rgba(30,20,35,0.85)', 'rgba(255,255,255,0.10)'
)

// 云雾灰
export let gThemeCloudGray = new AppTheme(
  '#7A8A98', '#1F2D3D', '#5B6573', '#FFFFFF', '#5F6E7A', '#7A8A98', '#7A8A98', '#FFFFFF', '#F5F5F8', '#FFFFFF',
  'rgba(255,255,255,0.85)', 'rgba(31,45,61,0.08)',
  '#8DA0B0', '#ECEFF2', '#8091A1', '#FFFFFF', '#6F7F8F', '#8FA0B0', '#8DA0B0', '#FFFFFF', '#14171F', '#14171F',
  'rgba(30,30,40,0.85)', 'rgba(255,255,255,0.10)'
)

// 月白色
export let gThemeMoonWhite = new AppTheme(
  '#8EC1D6', '#1F2D3D', '#5B6573', '#FFFFFF', '#6DAEC0', '#7A8A98', '#8EC1D6', '#FFFFFF', '#F6FAFD', '#FFFFFF',
  'rgba(255,255,255,0.85)', 'rgba(31,45,61,0.08)',
  '#AAD6E8', '#EAF4F8', '#8091A1', '#FFFFFF', '#6BA8C8', '#8FA0B0', '#AAD6E8', '#FFFFFF', '#111F28', '#111F28',
  'rgba(30,40,50,0.85)', 'rgba(255,255,255,0.10)'
)

// 岩石棕
export let gThemeRockBrown = new AppTheme(
  '#A38670', '#1F2D3D', '#5B6573', '#FFFFFF', '#876750', '#7A8A98', '#A38670', '#FFFFFF', '#F5F3F0', '#FFFFFF',
  'rgba(255,255,255,0.85)', 'rgba(31,45,61,0.08)',
  '#B39880', '#EAE7E3', '#8091A1', '#FFFFFF', '#8F7150', '#8FA0B0', '#B39880', '#FFFFFF', '#1A1512', '#1A1512',
  'rgba(30,20,25,0.85)', 'rgba(255,255,255,0.10)'
)

// 夕阳橙
export let gThemeSunsetOrange = new AppTheme(
  '#FF9966', '#1F2D3D', '#5B6573', '#FFFFFF', '#FF7A44', '#7A8A98', '#FF9966', '#FFFFFF', '#FFF5F2', '#FFFFFF',
  'rgba(255,255,255,0.85)', 'rgba(31,45,61,0.08)',
  '#FFB27A', '#FFEBE4', '#8091A1', '#FFFFFF', '#FF884D', '#8FA0B0', '#FFB27A', '#FFFFFF', '#1B110D', '#1B110D',
  'rgba(30,20,23,0.85)', 'rgba(255,255,255,0.10)'
)


export let gAppThemes: CustomTheme[] = [
  gThemeKiteBlue,
  gThemeSkyBlue,
  gThemeLimeGreen,
  gThemeSoftGold,
  gThemeDuskPurple,
  gThemeCloudGray,
  gThemeMoonWhite,
  gThemeRockBrown,
  gThemeSunsetOrange
]

export let gAppThemeNames: string[] = [
  '纸鸢蓝', '晴空蓝', '青柠绿', '柔沙金', '暮紫色',
  '云雾灰', '月白色', '岩石棕', '夕阳橙'
]

export let defaultAppTheme: CustomTheme = gAppThemes[0]
