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

  constructor(brand: string, fontPrimary: string, iconPrimary: string, iconEmphasize: string, backgroundPrimary: string,
    compBackgroundNeutral: string) {
    this.colors =
      new AppColors(brand, fontPrimary, iconPrimary, iconEmphasize, backgroundPrimary, compBackgroundNeutral);
  }
}

export let gAppThemeGreen: CustomTheme = new AppTheme(
  '#2E7D32',
  'rgba(46, 125, 50, 0.08)',
  '#2E7D32',
  '#66BB6A',
  'rgba(46, 125, 50, 0.2)',
  'rgba(102, 187, 106, 0.35)'
);

export let gAppThemeRed: CustomTheme = new AppTheme(
  '#C62828',
  'rgba(198, 40, 40, 0.08)',
  '#C62828',
  '#EF5350',
  'rgba(198, 40, 40, 0.2)',
  'rgba(239, 83, 80, 0.35)'
);

export let gAppThemePurple: CustomTheme = new AppTheme(
  '#7B1FA2',
  'rgba(123, 31, 162, 0.08)',
  '#7B1FA2',
  '#BA68C8',
  'rgba(123, 31, 162, 0.2)',
  'rgba(186, 104, 200, 0.35)'
);

export let gAppThemeOrange: CustomTheme = new AppTheme(
  '#EF6C00',
  'rgba(239, 108, 0, 0.08)',
  '#EF6C00',
  '#FFB74D',
  'rgba(239, 108, 0, 0.2)',
  'rgba(255, 183, 77, 0.35)'
);

export let gAppThemeNeutral: CustomTheme = new AppTheme(
  '#546E7A',
  'rgba(84, 110, 122, 0.08)',
  '#546E7A',
  '#B0BEC5',
  'rgba(84, 110, 122, 0.2)',
  'rgba(176, 190, 197, 0.35)'
);

export let gAppThemeBlue: CustomTheme = new AppTheme(
  '#1565C0',
  'rgba(21, 101, 192, 0.08)',
  '#1565C0',
  '#64B5F6',
  'rgba(21, 101, 192, 0.2)',
  'rgba(100, 181, 246, 0.35)'
);

export let gAppThemeYellow: CustomTheme = new AppTheme(
  '#FBC02D',
  'rgba(251, 192, 45, 0.08)',
  '#FBC02D',
  '#FFF176',
  'rgba(251, 192, 45, 0.2)',
  'rgba(255, 241, 118, 0.35)'
);

export let gAppThemeBrown: CustomTheme = new AppTheme(
  '#6D4C41',
  'rgba(109, 76, 65, 0.08)',
  '#6D4C41',
  '#A1887F',
  'rgba(109, 76, 65, 0.2)',
  'rgba(161, 136, 127, 0.35)'
);

export let gAppThemeDark: CustomTheme = new AppTheme(
  '#212121',
  'rgba(33, 33, 33, 0.08)',
  '#212121',
  '#BDBDBD',
  'rgba(33, 33, 33, 0.2)',
  'rgba(189, 189, 189, 0.35)'
);

export let gAppThemeTeal: CustomTheme = new AppTheme(
  '#00796B',
  'rgba(0, 121, 107, 0.08)',
  '#00796B',
  '#4DB6AC',
  'rgba(0, 121, 107, 0.2)',
  'rgba(77, 182, 172, 0.35)'
);

export let gAppThemeIndigo: CustomTheme = new AppTheme(
  '#303F9F',
  'rgba(48, 63, 159, 0.08)',
  '#303F9F',
  '#7986CB',
  'rgba(48, 63, 159, 0.2)',
  'rgba(121, 134, 203, 0.35)'
);


export let gAppThemeCyan: CustomTheme = new AppTheme(
  '#00BCD4', // 按钮色：Material Cyan 600
  '#00bcd40c', // 一级文本：透明青色背景
  '#00BCD4', // 一级图标
  '#ff80deea', // 高亮图标：柔和青色高亮
  '#3300bcd4', // 一级背景
  '#9c80deea'// 高亮背景
);

export let gAppThemePink: CustomTheme = new AppTheme(
  '#E91E63', // 按钮色：Material Pink 600
  '#e91e630c', // 一级文本
  '#E91E63', // 一级图标
  '#ffff80ab', // 高亮图标：明亮粉色
  '#33e91e63', // 一级背景
  '#9cff80ab'// 高亮背景
);

export let gAppThemeLime: CustomTheme = new AppTheme(
  '#CDDC39', // 按钮色：Material Lime 600
  '#cddc390c', // 一级文本
  '#CDDC39', // 一级图标
  '#fffff59d', // 高亮图标：亮黄色调
  '#33cddc39', // 一级背景
  '#9cfff59d'// 高亮背景
);

export let gAppThemeDeepOrange: CustomTheme = new AppTheme(
  '#FF5722', // 按钮色：Material Deep Orange 600
  '#ff57220c', // 一级文本
  '#FF5722', // 一级图标
  '#ffff8a65', // 高亮图标：柔和橙色
  '#33ff5722', // 一级背景
  '#9cff8a65'// 高亮背景
);

export let gAppThemeAmber: CustomTheme = new AppTheme(
  '#FFC107', // 按钮色：Material Amber 600
  '#ffc1070c', // 一级文本
  '#FFC107', // 一级图标
  '#ffffd54f', // 高亮图标：明亮琥珀色
  '#33ffc107', // 一级背景
  '#9cffd54f'// 高亮背景
);

export let gAppThemeTealLight: CustomTheme = new AppTheme(
  '#26A69A', // 按钮色：Material Teal Light 600
  '#26a69a0c', // 一级文本
  '#26A69A', // 一级图标
  '#ff80cbc4', // 高亮图标
  '#3326a69a', // 一级背景
  '#9c80cbc4'// 高亮背景
);

export let gAppThemeDeepIndigo: CustomTheme = new AppTheme(
  '#283593', // 按钮色：Material Deep Indigo 600
  '#2835930c', // 一级文本
  '#283593', // 一级图标
  '#ff7986cb', // 高亮图标
  '#33283593', // 一级背景
  '#9c7986cb'// 高亮背景
);

export let gAppThemeSlateBlue: CustomTheme = new AppTheme(
  '#6A5ACD', // 按钮色：Slate Blue 600
  '#6a5acd0c', // 一级文本
  '#6A5ACD', // 一级图标
  '#ffb0c4de', // 高亮图标
  '#336a5acd', // 一级背景
  '#9cb0c4de'// 高亮背景
);

export let gAppThemeCoral: CustomTheme = new AppTheme(
  '#FF7F50', // 按钮色：Coral 600
  '#ff7f500c', // 一级文本
  '#FF7F50', // 一级图标
  '#ffffa07a', // 高亮图标
  '#33ff7f50', // 一级背景
  '#9cffa07a'// 高亮背景
);

export let gAppThemeEmerald: CustomTheme = new AppTheme(
  '#50C878', // 按钮色：Emerald 600
  '#50c8780c', // 一级文本
  '#50C878', // 一级图标
  '#ff98fb98', // 高亮图标
  '#3350c878', // 一级背景
  '#9c98fb98'// 高亮背景
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


