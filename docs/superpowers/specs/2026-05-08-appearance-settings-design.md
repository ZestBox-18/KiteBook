# 外观设置合并与颜色优化设计

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将主题设置、字体设置、深色模式合并为统一的"外观设置"页面，并优化主题颜色为清新商务风格。

**Architecture:** 创建新的 AppearanceSettings 页面，采用单页三段式布局；优化 9 个主题色为浅灰蓝调；在 SystemOptions 中新增 fontWeight 和 iconWeight 字段；调整路由和个人中心菜单。

**Tech Stack:** ArkTS, ArkUI, PersistenceV2

---

## 背景与问题

当前存在以下问题：

1. 主题设置、字体大小、深色模式分散在三个独立页面，入口分散
2. 主题颜色过于深沉（如松墨 `#2B3A4A`），不够清新
3. 字体大小调节实用性不高，用户更关心字体粗细和图标粗细
4. 个人中心菜单项过多，不够简洁

---

## 设计目标

- 合并外观相关设置到一个统一页面
- 优化主题颜色为清新商务风格
- 提供字体粗细和图标粗细调节
- 简化个人中心菜单结构
- 保持数据兼容性和向后兼容

---

## 颜色优化方案

### 清新商务风格

将 9 个主题色整体提亮 20-30%，采用浅灰蓝调：

| 主题名 | 原 brand 色 | 新 brand 色 | 说明 |
|---|---|---|---|
| 松墨 | `#2B3A4A` | `#5A7A8A` | 浅灰蓝，默认主色 |
| 深海 | `#1E4E79` | `#4A7EA8` | 浅蓝，专业感 |
| 玄青 | `#2E6B6B` | `#5A9A9A` | 浅青，清醒理性 |
| 砂金 | `#8A6B3D` | `#A89060` | 浅金，精致点缀 |
| 赤陶 | `#9E5A3C` | `#B87860` | 浅土红，温润 |
| 云雾灰 | `#607080` | `#7A8A98` | 中性灰，极简 |
| 月白 | `#5D8899` | `#7AA0B0` | 冷白青，清爽 |
| 岩石 | `#6A5E55` | `#8A7A70` | 浅棕灰，稳重 |
| 暮紫 | `#5C4D7A` | `#8A70A0` | 浅紫，有格调 |

### 颜色计算规则

- **brand**: 主色，直接使用新色值
- **fontPrimary**: brand 色的 8% 透明度
- **iconPrimary**: brand 色原值
- **iconEmphasize**: brand 色提亮 30%
- **backgroundPrimary**: brand 色的 20% 透明度
- **compBackgroundNeutral**: brand 色提亮 30% 后的 35% 透明度
- **darkColors**: 基于浅色模式颜色，brand 色再提亮 15%

---

## 页面结构设计

### AppearanceSettings 页面

采用单页三段式布局，垂直滚动：

```
┌─────────────────────────┐
│      外观设置（标题）      │
├─────────────────────────┤
│  【主题选择】             │
│  4×3 网格，9 个色块       │
│  点击切换，显示选中标记     │
├─────────────────────────┤
│  【字体粗细】             │
│  四个选项卡片：            │
│  细体 / 常规 / 中等 / 粗体 │
├─────────────────────────┤
│  【图标粗细】             │
│  三个选项卡片：            │
│  细线 / 常规 / 粗线       │
├─────────────────────────┤
│  【深色模式】             │
│  三个选项卡片：            │
│  跟随系统 / 浅色模式 / 深色模式 │
└─────────────────────────┘
```

### 交互细节

- **主题选择**: 4 列网格，每个色块 48x48vp 圆形，下方显示主题名，选中时显示 ✓
- **字体粗细**: 卡片式单选，点击切换，选中项高亮
- **图标粗细**: 卡片式单选，点击切换，选中项高亮
- **深色模式**: 卡片式单选，点击切换，选中项高亮

---

## 数据结构设计

### SystemOptions 扩展

在 `SystemOptions` 类中新增字段：

```typescript
@ObservedV2
export class SystemOptions {
  @Trace themeIndex: number = 0
  @Trace fontWeight: number = 1  // 0=细体, 1=常轨, 2=中等, 3=粗体
  @Trace iconWeight: number = 1  // 0=细线, 1=常轨, 2=粗线
  @Trace darkMode: string = 'auto'  // 'auto' | 'light' | 'dark'
  // ... 其他字段
}
```

### 字体粗细映射

```typescript
const FONT_WEIGHT_MAP: Record<number, FontWeight> = {
  0: FontWeight.Light,    // 细体
  1: FontWeight.Normal,   // 常规
  2: FontWeight.Medium,   // 中等
  3: FontWeight.Bold      // 粗体
}
```

### 图标粗细映射

图标粗细通过调整图标的 strokeWidth 或选择不同图标集实现：
- 0: 细线 (strokeWidth: 1.5)
- 1: 常规 (strokeWidth: 2.0)
- 2: 粗线 (strokeWidth: 2.5)

---

## 路由与菜单调整

### 新增路由常量

在 `RouterUrlConstants` 中新增：

```typescript
static readonly APPEARANCE_SETTINGS: string = 'AppearanceSettings';
```

### 个人中心菜单调整

将原有的三个菜单项：
- 主题设置
- 字体大小
- 深色模式

合并为一个菜单项：
- 外观设置（图标：`sys.symbol.paintpalette`）

### 路由兼容性

- 保留 `THEME_SETTINGS`、`FONT_SETTINGS`、`DARK_MODE_SETTINGS` 路由常量（避免编译错误）
- 删除对应的菜单入口
- 新增 `APPEARANCE_SETTINGS` 路由和页面

---

## 文件变更清单

### 新增文件

1. `features/profile/src/main/ets/pages/AppearanceSettings.ets` - 外观设置页面

### 修改文件

1. `commons/base/src/main/ets/entities/AppThemes.ets` - 更新 9 个主题颜色
2. `commons/base/src/main/ets/entities/SystemOptions.ets` - 新增 fontWeight、iconWeight 字段
3. `commons/base/src/main/ets/constants/RouterUrlConstants.ets` - 新增 APPEARANCE_SETTINGS 常量
4. `features/profile/src/main/ets/pages/Index.ets` - 合并菜单项，更新 PagesMap
5. `features/profile/Index.ets` - 导出 AppearanceSettings，移除 FontSettings 导出

### 删除文件

1. `features/profile/src/main/ets/pages/FontSettings.ets` - 不再需要独立页面

---

## 实现顺序

1. 更新 `SystemOptions` 数据结构
2. 优化 `AppThemes` 颜色方案
3. 创建 `AppearanceSettings` 页面
4. 更新路由常量
5. 调整个人中心菜单和 PagesMap
6. 更新模块导出
7. 删除 `FontSettings` 页面
8. 构建验证

---

## 待确认项

- [x] 颜色风格：清新商务
- [x] 页面布局：单页三段式
- [x] 页面标题：外观设置
- [x] 字体调节：粗细而非大小
- [x] 图标调节：粗细选项

---

## 注意事项

1. **向后兼容**: 旧用户已保存的 themeIndex、darkMode 继续有效
2. **默认值**: fontWeight 默认 1（常规），iconWeight 默认 1（常规）
3. **颜色一致性**: 确保浅色模式和深色模式下颜色都清晰可读
4. **性能**: 主题切换应立即生效，无需重启应用
