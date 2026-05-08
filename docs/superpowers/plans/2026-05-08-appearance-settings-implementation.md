# 外观设置合并与颜色优化实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将主题设置、字体设置、深色模式合并为统一的"外观设置"页面，并优化主题颜色为清新商务风格。

**Architecture:** 创建新的 AppearanceSettings 页面，采用单页三段式布局；优化 9 个主题色为浅灰蓝调；在 SystemOptions 中新增 fontWeight 和 iconWeight 字段；调整路由和个人中心菜单。

**Tech Stack:** ArkTS, ArkUI, PersistenceV2

---

## 文件结构

### 新增文件
- `features/profile/src/main/ets/pages/AppearanceSettings.ets` - 外观设置统一页面

### 修改文件
- `commons/base/src/main/ets/entities/SystemOptions.ets` - 新增 fontWeight、iconWeight 字段
- `commons/base/src/main/ets/entities/AppThemes.ets` - 更新 9 个主题颜色
- `commons/base/src/main/ets/constants/RouterUrlConstants.ets` - 新增 APPEARANCE_SETTINGS 常量
- `features/profile/src/main/ets/pages/Index.ets` - 合并菜单项，更新 PagesMap
- `features/profile/Index.ets` - 导出 AppearanceSettings

### 删除文件
- `features/profile/src/main/ets/pages/FontSettings.ets` - 不再需要独立页面

---

## 任务分解

### Task 1: 更新 SystemOptions 数据结构

**Files:**
- Modify: `commons/base/src/main/ets/entities/SystemOptions.ets`

- [ ] **Step 1: 新增 fontWeight 和 iconWeight 字段**

在 SystemOptions 类中新增两个字段，并更新 @Monitor 装饰器：

```typescript
@ObservedV2
export class SystemOptions {
  // 首次运行
  @Trace firstStart: boolean = true
  // 主题索引
  @Trace themeIndex: number = 0
  // 字体粗细：0=细体, 1=常规, 2=中等, 3=粗体
  @Trace fontWeight: number = 1
  // 图标粗细：0=细线, 1=常规, 2=粗线
  @Trace iconWeight: number = 1
  // 通知开关
  @Trace notificationEnabled: boolean = true
  // 深色模式：auto, light, dark
  @Trace darkMode: string = 'auto'

  updateFromData(data: SystemOptions): void {
    this.firstStart = data.firstStart
    this.themeIndex = data.themeIndex
    this.fontWeight = data.fontWeight
    this.iconWeight = data.iconWeight
    this.notificationEnabled = data.notificationEnabled
    this.darkMode = data.darkMode
  }

  @Monitor('firstStart', 'themeIndex', 'fontWeight', 'iconWeight', 'notificationEnabled', 'darkMode')
  onDataChange(monitor: IMonitor) {
    DebounceManager.getInstance().execute('SystemOptions', () => {
      PersistenceV2.save('SystemOptions')
    }, 300)
  }
}
```

- [ ] **Step 2: 提交更改**

```bash
git add commons/base/src/main/ets/entities/SystemOptions.ets
git commit -m "feat: 在 SystemOptions 中新增字体粗细和图标粗细字段"
```

---

### Task 2: 优化 AppThemes 颜色方案

**Files:**
- Modify: `commons/base/src/main/ets/entities/AppThemes.ets`

- [ ] **Step 1: 更新 9 个主题的 brand 颜色**

将每个主题的 brand 色更新为清新商务风格：

**松墨 (PineInk):**
```typescript
export let gAppThemePineInk: CustomTheme = new AppTheme(
  '#5A7A8A',
  'rgba(90, 122, 138, 0.08)',
  '#5A7A8A',
  '#7A9AAA',
  'rgba(90, 122, 138, 0.2)',
  'rgba(122, 154, 170, 0.35)',
  '#6A8A9A',
  'rgba(106, 138, 154, 0.15)',
  '#6A8A9A',
  '#8AAABA',
  'rgba(106, 138, 154, 0.3)',
  'rgba(138, 170, 186, 0.4)'
);
```

**深海 (DeepSea):**
```typescript
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
```

**玄青 (MysticCyan):**
```typescript
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
```

**砂金 (SandGold):**
```typescript
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
```

**赤陶 (Terracotta):**
```typescript
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
```

**云雾灰 (CloudGray):**
```typescript
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
```

**月白 (MoonWhite):**
```typescript
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
```

**岩石 (Rock):**
```typescript
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
  '#BAAAB0',
  'rgba(154, 138, 128, 0.3)',
  'rgba(186, 170, 176, 0.4)'
);
```

**暮紫 (DuskPurple):**
```typescript
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
```

- [ ] **Step 2: 更新 ThemeSettings 的默认颜色**

将 ThemeSettings.ets 中的默认颜色从 `#2B3A4A` 改为 `#5A7A8A`：

```typescript
return '#5A7A8A'
```

- [ ] **Step 3: 提交更改**

```bash
git add commons/base/src/main/ets/entities/AppThemes.ets features/profile/src/main/ets/pages/ThemeSettings.ets
git commit -m "feat: 优化主题颜色为清新商务风格"
```

---

### Task 3: 更新路由常量

**Files:**
- Modify: `commons/base/src/main/ets/constants/RouterUrlConstants.ets`

- [ ] **Step 1: 新增 APPEARANCE_SETTINGS 路由常量**

在 RouterUrlConstants 类中新增：

```typescript
/**
 * 外观设置
 */
static readonly APPEARANCE_SETTINGS: string = 'AppearanceSettings';
```

- [ ] **Step 2: 提交更改**

```bash
git add commons/base/src/main/ets/constants/RouterUrlConstants.ets
git commit -m "feat: 新增外观设置路由常量"
```

---

### Task 4: 创建 AppearanceSettings 页面

**Files:**
- Create: `features/profile/src/main/ets/pages/AppearanceSettings.ets`

- [ ] **Step 1: 创建外观设置页面**

创建新文件 `features/profile/src/main/ets/pages/AppearanceSettings.ets`，包含四个部分：主题选择、字体粗细、图标粗细、深色模式。

页面结构：
- 使用 HdsNavDestination 作为容器
- 标题："外观设置"
- 内容区使用 Column 包含四个卡片分组
- 主题选择：4 列 Grid，9 个色块
- 字体粗细：4 个选项卡片（细体/常规/中等/粗体）
- 图标粗细：3 个选项卡片（细线/常规/粗线）
- 深色模式：3 个选项卡片（跟随系统/浅色模式/深色模式）

- [ ] **Step 2: 提交更改**

```bash
git add features/profile/src/main/ets/pages/AppearanceSettings.ets
git commit -m "feat: 创建外观设置统一页面"
```

---

### Task 5: 调整个人中心菜单和 PagesMap

**Files:**
- Modify: `features/profile/src/main/ets/pages/Index.ets`

- [ ] **Step 1: 更新 PagesMap**

在 PagesMap 中新增 AppearanceSettings 路由：

```typescript
if (name === RouterUrlConstants.APPEARANCE_SETTINGS) {
  AppearanceSettings()
}
```

- [ ] **Step 2: 合并菜单项**

将原有的三个菜单项（主题设置、字体大小、深色模式）合并为一个"外观设置"菜单项：

```typescript
ListItem() {
  SettingItem({
    icon: $r('sys.symbol.paintpalette'),
    title: '外观设置',
    onItemClick: () => {
      this.navigateToSubPage(RouterUrlConstants.APPEARANCE_SETTINGS)
    }
  })
}
```

删除原有的三个菜单项。

- [ ] **Step 3: 更新导入**

添加 AppearanceSettings 的导入：

```typescript
import { AppearanceSettings } from './AppearanceSettings';
```

- [ ] **Step 4: 提交更改**

```bash
git add features/profile/src/main/ets/pages/Index.ets
git commit -m "feat: 合并外观设置菜单项并更新 PagesMap"
```

---

### Task 6: 更新模块导出

**Files:**
- Modify: `features/profile/Index.ets`

- [ ] **Step 1: 导出 AppearanceSettings**

在 profile 模块的 Index.ets 中新增导出：

```typescript
export { AppearanceSettings } from './src/main/ets/pages/AppearanceSettings';
```

- [ ] **Step 2: 提交更改**

```bash
git add features/profile/Index.ets
git commit -m "feat: 导出 AppearanceSettings 页面"
```

---

### Task 7: 删除 FontSettings 页面

**Files:**
- Delete: `features/profile/src/main/ets/pages/FontSettings.ets`

- [ ] **Step 1: 删除 FontSettings.ets 文件**

```bash
rm features/profile/src/main/ets/pages/FontSettings.ets
```

- [ ] **Step 2: 从模块导出中移除**

从 `features/profile/Index.ets` 中移除 FontSettings 的导出：

```typescript
// 删除这一行
export { FontSettings } from './src/main/ets/pages/FontSettings';
```

- [ ] **Step 3: 提交更改**

```bash
git add features/profile/Index.ets
git commit -m "refactor: 删除独立的字体设置页面"
```

---

### Task 8: 构建验证

- [ ] **Step 1: 构建项目**

```bash
hvigorw clean && hvigorw assembleHap --mode module -p product=default
```

- [ ] **Step 2: 验证构建成功**

确认构建输出包含 `BUILD SUCCESSFUL`。

- [ ] **Step 3: 最终提交**

```bash
git status
git add .
git commit -m "feat: 完成外观设置合并与颜色优化"
```

---

## 验证清单

- [ ] SystemOptions 包含 fontWeight 和 iconWeight 字段
- [ ] 9 个主题颜色已更新为清新商务风格
- [ ] AppearanceSettings 页面包含四个设置区域
- [ ] 个人中心菜单显示"外观设置"入口
- [ ] 旧的三个菜单项已移除
- [ ] FontSettings 页面已删除
- [ ] 构建成功，无编译错误
- [ ] 主题切换正常工作
- [ ] 字体粗细切换正常工作
- [ ] 图标粗细切换正常工作
- [ ] 深色模式切换正常工作

---

## 注意事项

1. **向后兼容**: 旧用户已保存的 themeIndex、darkMode 继续有效
2. **默认值**: fontWeight 默认 1（常规），iconWeight 默认 1（常规）
3. **颜色一致性**: 确保浅色模式和深色模式下颜色都清晰可读
4. **性能**: 主题切换应立即生效，无需重启应用
