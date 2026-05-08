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

export let gAppThemeGreen: CustomTheme = new AppTheme(
  '#2E7D32',
  'rgba(46, 125, 50, 0.08)',
  '#2E7D32',
  '#66BB6A',
  'rgba(46, 125, 50, 0.2)',
  'rgba(102, 187, 106, 0.35)',
  '#4CAF50',
  'rgba(76, 175, 80, 0.15)',
  '#4CAF50',
  '#81C784',
  'rgba(76, 175, 80, 0.3)',
  'rgba(129, 199, 132, 0.4)'
);

export let gAppThemeRed: CustomTheme = new AppTheme(
  '#C62828',
  'rgba(198, 40, 40, 0.08)',
  '#C62828',
  '#EF5350',
  'rgba(198, 40, 40, 0.2)',
  'rgba(239, 83, 80, 0.35)',
  '#EF5350',
  'rgba(239, 83, 80, 0.15)',
  '#EF5350',
  '#E57373',
  'rgba(239, 83, 80, 0.3)',
  'rgba(229, 115, 115, 0.4)'
);

export let gAppThemePurple: CustomTheme = new AppTheme(
  '#7B1FA2',
  'rgba(123, 31, 162, 0.08)',
  '#7B1FA2',
  '#BA68C8',
  'rgba(123, 31, 162, 0.2)',
  'rgba(186, 104, 200, 0.35)',
  '#AB47BC',
  'rgba(171, 71, 188, 0.15)',
  '#AB47BC',
  '#CE93D8',
  'rgba(171, 71, 188, 0.3)',
  'rgba(206, 147, 216, 0.4)'
);

export let gAppThemeOrange: CustomTheme = new AppTheme(
  '#EF6C00',
  'rgba(239, 108, 0, 0.08)',
  '#EF6C00',
  '#FFB74D',
  'rgba(239, 108, 0, 0.2)',
  'rgba(255, 183, 77, 0.35)',
  '#FF9800',
  'rgba(255, 152, 0, 0.15)',
  '#FF9800',
  '#FFCC80',
  'rgba(255, 152, 0, 0.3)',
  'rgba(255, 204, 128, 0.4)'
);

export let gAppThemeNeutral: CustomTheme = new AppTheme(
  '#546E7A',
  'rgba(84, 110, 122, 0.08)',
  '#546E7A',
  '#B0BEC5',
  'rgba(84, 110, 122, 0.2)',
  'rgba(176, 190, 197, 0.35)',
  '#78909C',
  'rgba(120, 144, 156, 0.15)',
  '#78909C',
  '#CFD8DC',
  'rgba(120, 144, 156, 0.3)',
  'rgba(207, 216, 220, 0.4)'
);

export let gAppThemeBlue: CustomTheme = new AppTheme(
  '#1565C0',
  'rgba(21, 101, 192, 0.08)',
  '#1565C0',
  '#64B5F6',
  'rgba(21, 101, 192, 0.2)',
  'rgba(100, 181, 246, 0.35)',
  '#42A5F5',
  'rgba(66, 165, 245, 0.15)',
  '#42A5F5',
  '#90CAF9',
  'rgba(66, 165, 245, 0.3)',
  'rgba(144, 202, 249, 0.4)'
);

export let gAppThemeYellow: CustomTheme = new AppTheme(
  '#FBC02D',
  'rgba(251, 192, 45, 0.08)',
  '#FBC02D',
  '#FFF176',
  'rgba(251, 192, 45, 0.2)',
  'rgba(255, 241, 118, 0.35)',
  '#FFEE58',
  'rgba(255, 238, 88, 0.15)',
  '#FFEE58',
  '#FFF9C4',
  'rgba(255, 238, 88, 0.3)',
  'rgba(255, 249, 196, 0.4)'
);

export let gAppThemeBrown: CustomTheme = new AppTheme(
  '#6D4C41',
  'rgba(109, 76, 65, 0.08)',
  '#6D4C41',
  '#A1887F',
  'rgba(109, 76, 65, 0.2)',
  'rgba(161, 136, 127, 0.35)',
  '#8D6E63',
  'rgba(141, 110, 99, 0.15)',
  '#8D6E63',
  '#BCAAA4',
  'rgba(141, 110, 99, 0.3)',
  'rgba(188, 170, 164, 0.4)'
);

export let gAppThemeDark: CustomTheme = new AppTheme(
  '#212121',
  'rgba(33, 33, 33, 0.08)',
  '#212121',
  '#BDBDBD',
  'rgba(33, 33, 33, 0.2)',
  'rgba(189, 189, 189, 0.35)',
  '#616161',
  'rgba(97, 97, 97, 0.15)',
  '#616161',
  '#E0E0E0',
  'rgba(97, 97, 97, 0.3)',
  'rgba(224, 224, 224, 0.4)'
);

export let gAppThemeTeal: CustomTheme = new AppTheme(
  '#00796B',
  'rgba(0, 121, 107, 0.08)',
  '#00796B',
  '#4DB6AC',
  'rgba(0, 121, 107, 0.2)',
  'rgba(77, 182, 172, 0.35)',
  '#26A69A',
  'rgba(38, 166, 154, 0.15)',
  '#26A69A',
  '#80CBC4',
  'rgba(38, 166, 154, 0.3)',
  'rgba(128, 203, 196, 0.4)'
);

export let gAppThemeIndigo: CustomTheme = new AppTheme(
  '#303F9F',
  'rgba(48, 63, 159, 0.08)',
  '#303F9F',
  '#7986CB',
  'rgba(48, 63, 159, 0.2)',
  'rgba(121, 134, 203, 0.35)',
  '#5C6BC0',
  'rgba(92, 107, 192, 0.15)',
  '#5C6BC0',
  '#9FA8DA',
  'rgba(92, 107, 192, 0.3)',
  'rgba(159, 168, 218, 0.4)'
);


export let gAppThemeCyan: CustomTheme = new AppTheme(
  '#00BCD4', // 按钮色：Material Cyan 600
  '#00bcd40c', // 一级文本：透明青色背景
  '#00BCD4', // 一级图标
  '#ff80deea', // 高亮图标：柔和青色高亮
  '#3300bcd4', // 一级背景
  '#9c80deea', // 高亮背景
  '#26C6DA', // 深色模式按钮色
  '#26c6da1a', // 深色模式一级文本
  '#26C6DA', // 深色模式一级图标
  '#ffB2EBF2', // 深色模式高亮图标
  '#4d26c6da', // 深色模式一级背景
  '#b3B2EBF2' // 深色模式高亮背景
);

export let gAppThemePink: CustomTheme = new AppTheme(
  '#E91E63', // 按钮色：Material Pink 600
  '#e91e630c', // 一级文本
  '#E91E63', // 一级图标
  '#ffff80ab', // 高亮图标：明亮粉色
  '#33e91e63', // 一级背景
  '#9cff80ab', // 高亮背景
  '#EC407A', // 深色模式按钮色
  '#ec407a1a', // 深色模式一级文本
  '#EC407A', // 深色模式一级图标
  '#ffff80c9', // 深色模式高亮图标
  '#4dec407a', // 深色模式一级背景
  '#b3ff80c9' // 深色模式高亮背景
);

export let gAppThemeLime: CustomTheme = new AppTheme(
  '#CDDC39', // 按钮色：Material Lime 600
  '#cddc390c', // 一级文本
  '#CDDC39', // 一级图标
  '#fffff59d', // 高亮图标：亮黄色调
  '#33cddc39', // 一级背景
  '#9cfff59d', // 高亮背景
  '#D4E157', // 深色模式按钮色
  '#d4e1571a', // 深色模式一级文本
  '#D4E157', // 深色模式一级图标
  '#fffff9c4', // 深色模式高亮图标
  '#4dd4e157', // 深色模式一级背景
  '#b3fff9c4' // 深色模式高亮背景
);

export let gAppThemeDeepOrange: CustomTheme = new AppTheme(
  '#FF5722', // 按钮色：Material Deep Orange 600
  '#ff57220c', // 一级文本
  '#FF5722', // 一级图标
  '#ffff8a65', // 高亮图标：柔和橙色
  '#33ff5722', // 一级背景
  '#9cff8a65', // 高亮背景
  '#FF7043', // 深色模式按钮色
  '#ff70431a', // 深色模式一级文本
  '#FF7043', // 深色模式一级图标
  '#ffffab91', // 深色模式高亮图标
  '#4dff7043', // 深色模式一级背景
  '#b3ffab91' // 深色模式高亮背景
);

export let gAppThemeAmber: CustomTheme = new AppTheme(
  '#FFC107', // 按钮色：Material Amber 600
  '#ffc1070c', // 一级文本
  '#FFC107', // 一级图标
  '#ffffd54f', // 高亮图标：明亮琥珀色
  '#33ffc107', // 一级背景
  '#9cffd54f', // 高亮背景
  '#FFCA28', // 深色模式按钮色
  '#ffca281a', // 深色模式一级文本
  '#FFCA28', // 深色模式一级图标
  '#ffffe082', // 深色模式高亮图标
  '#4dffca28', // 深色模式一级背景
  '#b3ffe082' // 深色模式高亮背景
);

export let gAppThemeTealLight: CustomTheme = new AppTheme(
  '#26A69A', // 按钮色：Material Teal Light 600
  '#26a69a0c', // 一级文本
  '#26A69A', // 一级图标
  '#ff80cbc4', // 高亮图标
  '#3326a69a', // 一级背景
  '#9c80cbc4', // 高亮背景
  '#4DB6AC', // 深色模式按钮色
  '#4db6ac1a', // 深色模式一级文本
  '#4DB6AC', // 深色模式一级图标
  '#ffB2DFDB', // 深色模式高亮图标
  '#4d4db6ac', // 深色模式一级背景
  '#b3B2DFDB' // 深色模式高亮背景
);

export let gAppThemeDeepIndigo: CustomTheme = new AppTheme(
  '#283593', // 按钮色：Material Deep Indigo 600
  '#2835930c', // 一级文本
  '#283593', // 一级图标
  '#ff7986cb', // 高亮图标
  '#33283593', // 一级背景
  '#9c7986cb', // 高亮背景
  '#3F51B5', // 深色模式按钮色
  '#3f51b51a', // 深色模式一级文本
  '#3F51B5', // 深色模式一级图标
  '#ff9FA8DA', // 深色模式高亮图标
  '#4d3f51b5', // 深色模式一级背景
  '#b39FA8DA' // 深色模式高亮背景
);

export let gAppThemeSlateBlue: CustomTheme = new AppTheme(
  '#6A5ACD', // 按钮色：Slate Blue 600
  '#6a5acd0c', // 一级文本
  '#6A5ACD', // 一级图标
  '#ffb0c4de', // 高亮图标
  '#336a5acd', // 一级背景
  '#9cb0c4de', // 高亮背景
  '#7E8CE0', // 深色模式按钮色
  '#7e8ce01a', // 深色模式一级文本
  '#7E8CE0', // 深色模式一级图标
  '#ffC5D0E6', // 深色模式高亮图标
  '#4d7e8ce0', // 深色模式一级背景
  '#b3C5D0E6' // 深色模式高亮背景
);

export let gAppThemeCoral: CustomTheme = new AppTheme(
  '#FF7F50', // 按钮色：Coral 600
  '#ff7f500c', // 一级文本
  '#FF7F50', // 一级图标
  '#ffffa07a', // 高亮图标
  '#33ff7f50', // 一级背景
  '#9cffa07a', // 高亮背景
  '#FF9A76', // 深色模式按钮色
  '#ff9a761a', // 深色模式一级文本
  '#FF9A76', // 深色模式一级图标
  '#ffffb997', // 深色模式高亮图标
  '#4dff9a76', // 深色模式一级背景
  '#b3ffb997' // 深色模式高亮背景
);

export let gAppThemeEmerald: CustomTheme = new AppTheme(
  '#50C878', // 按钮色：Emerald 600
  '#50c8780c', // 一级文本
  '#50C878', // 一级图标
  '#ff98fb98', // 高亮图标
  '#3350c878', // 一级背景
  '#9c98fb98', // 高亮背景
  '#69D995', // 深色模式按钮色
  '#69d9951a', // 深色模式一级文本
  '#69D995', // 深色模式一级图标
  '#ffB8F0B8', // 深色模式高亮图标
  '#4d69d995', // 深色模式一级背景
  '#b3B8F0B8' // 深色模式高亮背景
);


// 添加到主题数组
export let gAppThemes: CustomTheme[] = [
  gAppThemeGreen,
  gAppThemeRed,
  gAppThemeBlue,
  gAppThemePurple,
  gAppThemeOrange,
  gAppThemeNeutral,
  gAppThemeYellow,
  gAppThemeBrown,
  gAppThemeDark,
  gAppThemeTeal,
  gAppThemeIndigo,

  gAppThemeCyan,
  gAppThemePink,
  gAppThemeLime,
  gAppThemeDeepOrange,
  gAppThemeAmber,
  gAppThemeTealLight,
  gAppThemeDeepIndigo,
  gAppThemeSlateBlue,
  gAppThemeCoral,
  gAppThemeEmerald
];

// 添加到字典
export let gAppThemesDict: Map<string, CustomTheme> = new Map([
  ['绿色', gAppThemeGreen],
  ['红色', gAppThemeRed],
  ['蓝色', gAppThemeBlue],
  ['紫色', gAppThemePurple],
  ['橙色', gAppThemeOrange],
  ['中性灰', gAppThemeNeutral],
  ['黄色', gAppThemeYellow],
  ['棕色', gAppThemeBrown],
  ['暗色', gAppThemeDark],
  ['青色', gAppThemeTeal],
  ['靛蓝', gAppThemeIndigo],

  ['湖蓝', gAppThemeCyan],
  ['粉色', gAppThemePink],
  ['酸橙色', gAppThemeLime],
  ['深橙色', gAppThemeDeepOrange],
  ['琥珀色', gAppThemeAmber],
  ['浅青色', gAppThemeTealLight],
  ['深靛蓝', gAppThemeDeepIndigo],
  ['石板蓝', gAppThemeSlateBlue],
  ['珊瑚色', gAppThemeCoral],
  ['翡翠绿', gAppThemeEmerald]
]);


// 默认主题
export class DefaultAppColors implements CustomColors {
  iconEmphasize: string = '#a900aeff'; // 高亮图标
  iconSubEmphasize: string = '#8F9ED7F5'; // 高亮辅助图标
  compBackgroundNeutral: string = '#a900aeff'; // 多页面卡片边框
}

export class DefaultAppTheme implements CustomTheme {
  public colors: DefaultAppColors = new DefaultAppColors()
}

export let defaultAppTheme: CustomTheme = new DefaultAppTheme();


