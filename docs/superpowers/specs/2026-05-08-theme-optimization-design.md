# 默认主题配色与命名优化设计

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 KiteBook 的默认主题体系从“数量多但质感弱”优化为“少而精、高端稳重、长期易用”的精品主题方案。

**Architecture:** 精简主题数组与字典，只保留 9 个高质量主题，统一中文命名，默认主题改为“松墨”，并保持 ThemeSettings 页面与主题数据结构完全一致。

**Tech Stack:** ArkTS, ArkUI, PersistenceV2

---

## 背景与问题

当前主题系统存在以下问题：

1. 主题数量过多（21 个），整体偏花哨，不利于专业感
2. 主题名偏“直译颜色”，例如“绿色 / 红色 / 青色”，显得普通
3. 部分配色过艳，长时间看账单和报表时不够舒适
4. `ThemeSettings.ets` 中主题名称与 `AppThemes.ets` 主题顺序耦合不一致，易出错
5. 默认主题不够稳重，缺乏成熟记账工具的气质

---

## 设计目标

- 主题更少，但更高级
- 默认配色更沉稳，适合长期使用
- 命名更统一、更有质感
- 数据结构与页面显示保持一致
- 旧数据越界时可安全回退

---

## 设计原则

### 1. 以冷静商务为主
整体风格优先考虑：
- 低饱和
- 高辨识
- 长时间使用不刺眼
- 适合展示账单、报表、资产等信息

### 2. 保留少量轻奢点缀
在偏商务的整体基础上，保留少量有格调的颜色作为补充，让主题库不会过于单调。

### 3. 统一中文命名
所有主题统一采用中文名称，提升整体产品气质和页面可读性。

---

## 主题方案

最终保留以下 **9 个主题**：

| 主题名 | 定位 | 说明 |
|---|---|---|
| 松墨 | 默认主色 | 深灰蓝，稳重耐看，适合默认主题 |
| 深海 | 沉稳蓝 | 专业可信，适合金融记账类界面 |
| 玄青 | 冷静青 | 清醒理性，适合数据展示 |
| 砂金 | 轻奢金 | 商务点缀，提升精致感 |
| 赤陶 | 暖土色 | 温润有质感，但不俗气 |
| 云雾灰 | 中性灰 | 极简百搭，适合极简风格用户 |
| 月白 | 冷白青 | 清爽轻盈，适合浅色偏好 |
| 岩石 | 稳重棕灰 | 沉稳厚重，适合资产类界面 |
| 暮紫 | 精致点缀 | 有格调但不张扬 |

---

## 默认策略

- 默认主题设置为 **松墨**
- 旧用户若已保存的 `themeIndex` 超出新数组长度，则回退到默认主题

---

## 数据结构设计

### `AppThemes.ets`

只保留 9 个主题实例，并通过以下结构管理：

- `gAppThemePineInk` （松墨）
- `gAppThemeDeepSea` （深海）
- `gAppThemeMysticCyan` （玄青）
- `gAppThemeSandGold` （砂金）
- `gAppThemeTerracotta` （赤陶）
- `gAppThemeCloudGray` （云雾灰）
- `gAppThemeMoonWhite` （月白）
- `gAppThemeRock` （岩石）
- `gAppThemeDuskPurple` （暮紫）

### `gAppThemes`

按上述顺序形成长度为 9 的数组。

### `gAppThemesDict`

采用统一中文名映射：

- 松墨
- 深海
- 玄青
- 砂金
- 赤陶
- 云雾灰
- 月白
- 岩石
- 暮紫

---

## 页面设计

### ThemeSettings 页面

- 页面只显示 9 个主题
- 主题名称统一使用上述中文名
- 名称顺序与 `gAppThemes` 完全一致
- 选中状态保持当前交互逻辑

### 兼容性设计

- 页面读取 `themeIndex`
- 若 `themeIndex >= gAppThemes.length`，自动回退到默认主题

---

## 交互不变部分

- 主题切换仍通过 `themeIndex` 存储
- 深色模式设置保持不变
- 设置持久化方式保持不变

---

## 预期效果

- 默认主题更沉稳专业
- 主题列表更简洁高级
- 整体命名更有品质感
- 长期使用更舒适
- 数据结构和页面显示保持一致，降低维护风险

---

## 待确认

本设计已完成，以下为最终确认项：

- [ ] 保留 9 个主题
- [ ] 删除旧主题
- [ ] 默认主题为“松墨”
- [ ] 主题统一中文命名
- [ ] 越界 `themeIndex` 回退默认主题
