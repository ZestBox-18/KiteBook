# KiteBook 项目指南

本文档为 AI 编码代理提供项目结构和代码风格指南。

## 项目概述

KiteBook 是一个 HarmonyOS 记账应用，使用 ArkTS（HarmonyOS 的 TypeScript 变体）开发。

- **包名**: `cn.zestbox.kitebook`
- **SDK版本**: `26.0.0`
- **构建系统**: hvigor
- **测试框架**: `@ohos/hypium` + `@ohos/hamock`

## 构建和测试命令

### 构建项目

```bash
# 完整构建（推荐）
hvigorw clean && hvigorw assembleHap --mode module -p product=default

# 增量构建
hvigorw assembleHap --mode module -p product=default

# 构建特定模块
hvigorw assembleHap --mode module -p module=entry@default -p product=default
```

### 代码检查

```bash
hvigorw lint
```

### 编译检查要点

- 开始编译排查前，先确认工程根目录已正确初始化；如果使用 DevEco MCP，优先执行工程路径初始化，再进行同步和构建。
- 功能模块新增跨模块引用后，先检查对应模块的 `oh-package.json5` 是否补齐依赖，再判断是否是代码本身报错；ArkTS 的“Cannot find module”经常是依赖声明遗漏，不是页面语法本身有问题。
- 修改 `oh-package.json5`、`module.json5`、路由表或跨模块导出后，必须先执行一次依赖同步，再看编译结果，避免把缓存问题误判为代码问题。
- 编译排查优先顺序固定为：`project_sync/ohpm install` -> 普通 debug 构建 -> 必要时 clean 后重新构建。不要一上来就只看增量构建结果。
- 如果普通构建通过，但怀疑有缓存或增量编译误判，继续执行一次 clean build；只有 clean build 也通过，才算构建链路真正稳定。
- 处理编译日志时，优先解决首个阻塞性错误，再重新构建，不要一次性根据后续连带报错做大范围猜测式修改。
- `WARN` 和 `ERROR` 要分开处理：`ERROR` 必须在当前轮修复；`WARN` 需要记录原因，判断是否影响运行时稳定性，再决定是否顺手处理。
- LSP/静态检查工具如果对大文件超时，不能直接认定文件无问题；以 hvigor 完整构建结果为主，必要时拆分文件逐个检查。
- 构建完成后，清理本轮临时日志目录或调试产物，不要把 `.codex/` 之类的中间文件混入工作区。
- 如果本轮为修复编译问题而新增依赖，留意对应 `oh-package-lock.json5` 变更是否属于依赖同步产物；这类 lockfile 更新通常应与依赖声明一起保留。

### 测试

```bash
# 运行模块单元测试
hvigorw test@entry --mode module -p product=default
hvigorw test@home --mode module -p product=default

# 运行单个测试文件：在 DevEco Studio 中右键点击测试文件 -> Run 'xxx.test.ets'
```

### 测试文件位置

- **单元测试**: `src/test/*.test.ets` - 纯逻辑测试
- **UI测试**: `src/ohosTest/ets/test/*.test.ets` - 界面和 Ability 测试

## 项目结构

```
KiteBook/
├── AppScope/              # 应用全局配置
├── products/entry/        # 入口模块（HAP）
├── commons/               # 共享模块
│   ├── base/             # 轻量基础包：常量、实体、主题状态、基础组件和小型公共资源
│   ├── data_core/        # 数据运行时核心 HSP：数据库初始化、业务数据管理器、后续云同步能力
│   └── kite_utils/       # 工具库（独立发版，勿在此编写业务代码）
├── features/              # 功能模块
│   ├── home/             # 首页
│   ├── billing/          # 账单
│   ├── record/           # 记账记录
│   ├── reports/          # 报表
│   └── profile/          # 个人中心
└── hvigor/                # 构建配置
```

**重要**: `kite_utils` 是独立发版的工具库，本项目的业务代码不能写到该模块中。业务相关代码应写在 `data_core`、`base`、`features`
或 `products/entry` 中。

### 模块边界

| 模块 | 职责 | 不应放入 |
|------|------|---------|
| `products/entry` | 应用入口、Ability 初始化、全局 Navigation/Tabs 容器、全局弹窗挂载点 | 业务数据查询细节、页面私有 UI |
| `commons/base` | 轻量公共定义：常量、路由、实体 Bean/Enum、主题状态、基础 UI 组件、小型公共资源 | 数据库访问、API 请求、云同步流程、大型媒体资源 |
| `commons/data_core` | 运行时共享的数据能力：数据库配置、业务 Manager、后续 SyncService/Repository | 页面组件、弹窗 UI、纯展示状态 |
| `commons/kite_utils` | 可独立发版的通用工具：网络、数据库底座、日志、窗口、断点、第三方组件封装 | KiteBook 业务模型和业务规则 |
| `features/*` | 功能页面、功能内组件、功能内 ViewModel/Calculator | 跨功能共享的数据 Manager、入口级全局弹窗状态 |

**资源拆分原则**：

- 跨模块共享颜色和公共媒体资源放入 `commons/shared_assets` HSP，使用 `$r('[shared_assets].color.xxx')`、`$r('[shared_assets].media.xxx')` 引用。
- 入口启动资源如 `startWindowIcon`、`startWindowBackground` 保留在 `products/entry` 本地，确保 `module.json5` 中的 `$media:`、`$color:` 无模块名前缀引用可解析。
- 功能模块私有图片、页面配置留在对应 `features/*/src/main/resources`，不要放入公共资源模块。
- `base` 必须保持轻量，不能因为“所有模块都要用”就继续承载数据库、同步、API 聚合等运行时能力。

### 当前架构补充约定

#### 模块类型和依赖方向

- `products/entry` 是入口 HAP，只负责 Ability、全局容器、全局弹窗、全局 Tab/FAB 挂载点和应用级初始化。
- `commons/base` 是 HAR，承载可被所有模块依赖的轻量类型、常量、路由、全局状态和基础 UI 组件。
- `commons/data_core` 是 shared HSP，承载数据库配置、初始化和业务 Manager。功能模块需要账单、账户、分类、预算数据时，从 `data_core` 导入对应 Manager。
- `commons/shared_assets` 是 shared HSP，承载跨模块共享资源。页面资源优先使用 `[shared_assets]` 前缀，入口启动资源例外。
- `features/*` 是 shared HSP，页面内部的组件、ViewModel、Calculator 和私有资源留在对应功能模块内。
- 依赖方向应保持为：`entry -> features -> data_core/base/kite_utils/shared_assets`，`data_core -> base/kite_utils`，不要让 `base` 反向依赖 `data_core` 或任何 feature。

#### 数据访问和刷新链路

- 业务数据访问统一通过 `data_core` 的 Manager 完成，例如 `BillManager`、`AccountManager`、`BudgetManager`、`CategoryManager`。
- 数据库初始化只在 `EntryAbility.onCreate` 中调用 `dbManagerInit(this.context)`，不要在页面或组件中重复初始化数据库。
- 新增、删除、更新账单后，需要通过 `billSyncController.notifyBillChanged()` 通知其他页面刷新。
- 需要监听账单变化的页面，在 `aboutToAppear` 中注册 `billSyncController.register(...)`，在 `aboutToDisappear` 中注销，避免重复监听。
- 首页这类复杂页面应保持“页面拉取数据 + Calculator/ViewModel 计算 + 子组件展示”的分层，不要把大量统计计算散落在展示组件中。
- 全局新增账单入口放在 `products/entry`，由 `AddBillSheetComponent` 负责录入，保存成功后通知账单同步控制器。

#### 页面导航和 Tab 控制

- 主 Tab 容器只放在 `products/entry/src/main/ets/pages/Index.ets`，使用全局 `mainTabController`。
- 功能模块内部使用自己的 `NavPathStack` 管理子页面，不要跨模块直接操作其他功能的页面栈。
- 从主页面进入子页面前，根据设备和交互需要调用 `mainTabController.applyHideAnimation(...)`；子页面返回时再恢复 Tab。
- 路由名集中维护在 `RouterUrlConstants`，不要在多个页面散落硬编码路由字符串。

#### 主题和资源使用

- 全局主题状态使用 `AppThemeState`，通过 `AppStorageV2.connect(AppThemeState, 'themeState', ...)` 获取。
- `onWillApplyTheme` 只在入口 `products/entry/src/main/ets/pages/Index.ets` 中同步主题颜色，功能页面直接消费 `themeState`。
- 系统颜色模式（`dark` / `light` / `auto` 到 `ConfigurationConstant.ColorMode` 的映射）使用 `kite_utils` 的 `SystemColorModeUtil`；读取 `SystemOptions.darkMode` 属于应用层逻辑，保留在入口或业务设置页面，不要塞进 `kite_utils`。
- 组件颜色优先使用 `themeState` 或 `[shared_assets]` 资源，不新增无意义的硬编码颜色。业务语义明确的状态色可以局部使用，但要保持深色模式可读。
- 底部 Tab 图标使用 `sys.symbol.*` + `SymbolGlyphModifier`，不要使用 `sys.media.*`。
- 共享颜色和公共媒体资源新增到 `commons/shared_assets/src/main/resources`；功能私有资源新增到对应 `features/*/src/main/resources`。

#### 安全区和窗口信息

- `WindowUtil` 必须通过 `AppStorageV2.connect(WindowUtil, 'winUtil')!` 获取同一个全局实例。
- 主页面使用 `HdsNavigation` 时，顶部内容避让采用 `safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE` 或对应常量。
- 子页面使用 `HdsNavDestination` 时，标题栏设置 `avoidLayoutSafeArea: true`，内容区使用 `safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI` 等常量补齐。
- 沉浸模式下不要使用 `expandSafeArea` 处理顶部避让。
- 底部可滚动内容需要考虑 `navIndicatorHeight + CommonConstants.TAB_HEIGHT`，避免被底部 Tab 或手势条遮挡。

#### ArkTS 实现偏好

- 新增业务代码不要使用 `any`、`unknown`、无类型上下文对象字面量或动态属性访问。
- 避免新增 `as` 类型断言；确实需要和系统 API 交互时，优先封装在小范围内，并用具体类型承接结果。
- 使用当前页面的 `UIContext.animateTo(...)`，不要使用全局 `animateTo`。页面已缓存 `uiContext` 时优先使用 `this.uiContext?.animateTo(...)`；未缓存时再调用 `this.getUIContext().animateTo(...)`。
- `Promise`、回调和集合类型都要写清楚泛型或函数签名，便于 ArkTS 编译和 lint 检查。
- `@Builder` 只适合抽取稳定结构。会随 `@Local`、`@Param`、`@Trace` 变化的展示文本、按钮启用态、颜色等，优先在 Builder 内部直接读取当前组件状态，不要把动态值预先拼成字符串或布尔值作为 Builder 参数传入，否则在 `ListItemGroup`、弹窗回调等场景下可能出现部分 UI 不刷新。
- 如果确实要复用带动态状态的行组件，优先拆成语义明确的 Builder，例如 `RecentLogActionRow()`、`ClearLogActionRow()`，在内部读取 `this.hasLogs`、`this.clearing` 等状态；不要写成 `ActionRow(..., enabled)` 后到处传动态布尔值。
- 系统弹窗、Picker、半模态等非组件直接事件回调中修改页面状态时，优先使用已缓存的当前页面 `UIContext` 提交状态变化，例如 `this.uiContext?.animateTo({ duration: 0 }, () => { ... })`。这里不是为了做动画，而是确保状态更新发生在当前 UIContext 的刷新上下文里；如果页面没有缓存 `uiContext`，再退回 `this.getUIContext().animateTo(...)`。

### kite_utils 工具库

`kite_utils` 包含以下通用工具（通过 `import { ... } from 'kite_utils'` 使用）：

| 工具                  | 说明                                        |
|---------------------|-------------------------------------------|
| `request`           | 网络请求工具，支持 GET/POST/PUT/DELETE，内置 Token 管理 |
| `dbManager`         | 数据库工具，支持版本管理和渐进式升级                        |
| `Clog`              | 日志工具，支持 info/warn/error 多级别日志             |
| `HSBColorPicker`    | 颜色选择器组件，支持 HSB 模式和透明度                     |
| `HdsMiniBarButton`  | 浮动迷你栏按钮组件，支持沉浸光感材质                        |
| `BreakPoint`        | 响应式断点工具                                   |
| `WindowUtil`        | 窗口信息工具，处理安全区避让等                           |

**目录结构**：

```
kite_utils/
├── LICENSE                              # MIT License (ZestBox)
└── src/main/ets/
    ├── utils/                            # 自己开发的工具
    │   ├── network/                      # 网络请求
    │   ├── database/                     # 数据库
    │   ├── clog/                         # 日志
    │   ├── breakpoint/                   # 断点系统
    │   ├── windowInfo/                   # 窗口信息
    │   └── context/                      # 全局上下文
    └── third-party/                      # 第三方组件（统一管理）
        ├── hds-button/                   # 浮动按钮组件
        │   ├── LICENSE                   # Apache License 2.0
        │   └── HdsMiniBarButton.ets
        └── color-picker/                 # 颜色选择器组件
            ├── LICENSE                   # MIT License (KEKE UI)
            └── ...
```

## 代码风格指南

### 文件头注释

#### 自己开发的代码

```typescript
/**
 * Copyright (C), YYYY-MM-DD
 * @author 作者名
 * @date YYYY/MM/DD
 * @version 1.0
 * @description: 功能描述
 */
```

#### 第三方代码

第三方组件放在 `kite_utils/src/main/ets/third-party/` 目录，每个组件有自己的 LICENSE 文件。源文件头部添加版权声明：

```typescript
/**
 * MIT License / Apache License 2.0
 *
 * Copyright (c) YYYY 原作者
 * ...
 */
```

#### 基于官方代码修改

保留原始版权声明 + 添加修改说明：

```typescript
/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0...
 *
 * Modified by ZestBox, 2025
 * - 添加 xxx 功能
 * - 优化 xxx 逻辑
 */
```

### 导入顺序

```typescript
// 1. HarmonyOS Kit 导入
import { hilog } from '@kit.PerformanceAnalysisKit';

// 2. 项目内部模块导入（使用模块名）
import { CommonConstants } from 'base';
import { WindowUtil } from 'kite_utils';

// 3. 相对路径导入
import { MyComponent } from './components/MyComponent';
```

### 命名约定

#### 基本命名规则

| 类型      | 约定                | 示例                                     |
|---------|-------------------|----------------------------------------|
| 类名      | PascalCase        | `DatabaseManager`, `AppTheme`          |
| 接口名     | I + PascalCase    | `IDatabaseCallbacks`, `IHomeView`      |
| 枚举名     | PascalCase + Enum | `OrderStatusEnum`, `PaymentMethodEnum` |
| 函数名/变量名 | camelCase         | `initRequest()`, `dbStore`             |
| 私有成员    | 无前缀 + private     | `private dbContext?: Context`          |

#### 上下文命名规则

```typescript
// UIContext 类型命名为 uiContext
uiContext: UIContext = this.getUIContext();

// UIAbilityContext 类型命名为 context
context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
```

**使用边界**：

- 页面和组件里的 UI 操作优先使用当前组件的 `UIContext`，包括 Toast、弹窗、Picker、动画、状态提交等。页面已缓存 `uiContext` 时优先使用缓存字段；未缓存时使用 `this.getUIContext()`。不要为了方便把 UI 操作绕到全局 Context。
- 页面中可以缓存当前页面上下文，但应在 `aboutToAppear`、`onReady` 或明确的生命周期方法中初始化，不要在字段初始化阶段直接依赖 `this.getUIContext()`。
- 推荐页面字段命名：

```typescript
private uiContext: UIContext | undefined = undefined
private context: common.UIAbilityContext | undefined = undefined

aboutToAppear(): void {
  this.uiContext = this.getUIContext();
  const hostContext = this.uiContext.getHostContext();
  if (hostContext) {
    this.context = hostContext as common.UIAbilityContext;
  }
}
```

- `UIContext` 用于 UI 行为：`showAlertDialog`、`getPromptAction().showToast`、`animateTo`、组件快照、弹窗等。
- `common.UIAbilityContext` 用于 Ability 级能力：`filesDir`、资源访问、应用级目录、权限、启动 Ability 等。
- `GlobalContext` 只用于非组件层、工具层、Manager 层等无法直接拿到页面 `UIContext` 的场景，适合保存应用级 `UIAbilityContext`、全局单例或跨层运行时对象。不要在页面组件里优先使用 `GlobalContext` 替代 `this.getUIContext()`。
- `EntryAbility.onCreate` 中不要读取 `PersistenceV2` 后直接应用会被页面持久化覆盖的设置。应用级设置应在页面容器加载完成后，由专门的 Runtime/Startup 类统一应用，入口文件保持轻量。

**重要**：使用 `UIContext.animateTo` 而非全局 `animateTo`（已弃用）：

```typescript
// 正确用法
this.uiContext?.animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
  this.opacity = 0;
});

// 错误用法（已弃用）
animateTo({ curve: curves.springMotion(0.6, 0.9), duration: 400 }, () => {
  this.opacity = 0;
});
```

#### 组件命名规则

| 类型   | 命名方式            | 示例                             |
|------|-----------------|--------------------------------|
| 页面组件 | 功能名，无后缀         | `Index`, `Home`, `Ordinary`    |
| 通用组件 | 可加 Component 后缀 | `UserCardComponent`            |
| 弹窗组件 | XxxDialog       | `ConfirmDialog`, `InputDialog` |

```typescript
// 页面组件
@Entry
@ComponentV2
struct
Index
{
  build()
  { /* ... */
  }
}

// 弹窗组件
@ComponentV2
struct
ConfirmDialog
{
  build()
  { /* ... */
  }
}
```

#### 文件命名后缀

| 目录/用途 | 后缀         | 示例                   |
|-------|------------|----------------------|
| 管理类   | Manager    | `DatabaseManager`    |
| 工具类   | Util       | `WindowUtil`         |
| 常量类   | Constants  | `CommonConstants`    |
| 数据源   | DataSource | `CityListDataSource` |
| 请求模型  | Request    | `LoginRequest`       |
| 响应模型  | Response   | `UserResponse`       |
| 数据实体  | Bean       | `UserInfoBean`       |
| 参数模型  | Params     | `SearchParams`       |

#### 常量命名

```typescript
// 文件级常量（TAG模式）
const TAG: string = '[DatabaseManager]';

// 类静态常量（UPPER_SNAKE_CASE）
class CommonConstants {
  static readonly BUNDLE_NAME: string = 'com.zestbox.kitebook';
  static readonly FULL_WIN: string = '100%';
}
```

#### 方法命名动词前缀

| 前缀        | 用途      | 示例                                |
|-----------|---------|-----------------------------------|
| `init`    | 初始化     | `initDatabase()`, `initRequest()` |
| `update`  | UI更新    | `updateUserList()`                |
| `show`    | 显示弹窗/提示 | `showErrorMessage()`              |
| `fetch`   | 获取数据    | `fetchUserDetails()`              |
| `process` | 数据处理    | `processOrderData()`              |
| `handle`  | 事件处理    | `handleItemClick()`               |
| `on`      | 事件回调    | `onLoginSuccess()`, `onConfirm()` |
| `get`     | 获取值     | `getUserName()`                   |
| `set`     | 设置值     | `setTheme()`                      |

### 组件定义

```typescript
@ComponentV2
export struct
MyComponent
{
  @
  Param
  propertyName: Type = defaultValue;
  @
  Local
  localState: Type = initialValue;

  build()
  {
    Column()
    { /* 组件内容 */
    }
  }
}
```

### 持久化存储

使用 `PersistenceV2` 实现设置项的自动持久化，修改即保存，应用重启后自动恢复：

```typescript
// 定义设置项类型
class SystemOptions {
  theme: string = 'light';
  fontSize: number = 14;
}

// 在组件中使用
@ComponentV2
export struct
SettingsPage
{
  @
  Local
  option_system: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!;

  build()
  {
    // 修改 option_system.theme 等属性会自动保存
  }
}
```

### 日志规范

```typescript
const TAG: string = '[ComponentName]';
Clog.info(TAG, '信息日志');
Clog.warn(TAG, '警告信息');
Clog.error(TAG, '错误信息', errorObject);
```

#### 日志级别使用规范

- `Clog.info`：记录正常业务流程中的关键节点，只用于开发排查需要的低频信息，例如功能开关变更、导出成功、初始化完成、一次重要流程开始/结束。不要在列表渲染、循环、频繁手势、每条账单计算等高频路径里输出 info。
- `Clog.warn`：记录可恢复但需要关注的异常状态，例如非关键数据缺失、使用默认值兜底、可忽略的文件不存在、降级逻辑、生效失败但不阻塞主流程的情况。
- `Clog.error`：记录真实失败或不可预期异常，例如数据库操作失败、文件读写失败、导入导出失败、网络请求失败、全局 JS crash、会影响用户完成当前操作的问题。捕获到的 `error` 对象应尽量作为第三个参数传入。
- 不要使用 `hilog` 直接输出项目业务日志；全局统一走 `Clog`，便于本地落盘、导出和问题排查。
- 日志内容应避免记录用户隐私、完整账单明细、Token、手机号、银行卡号、精确定位等敏感信息。需要定位问题时，只记录状态、数量、类型、错误码、脱敏后的关键字段。

#### 日志落盘规范

- `Clog.init(context)` 只负责初始化日志目录，目录为 `context.filesDir/logs`；不要在页面或组件中重复自建日志目录。
- 关闭详细日志时，本地仍保留 `error` 级别日志；开启详细日志时，`info`、`warn`、`error` 均可落盘，用于开发人员排查问题。
- 页面或设置项只控制“详细日志”开关，不应阻止错误日志落盘。错误日志是问题排查的最低保障。
- 日志文件使用 JSONL 形式按行记录，并按文件大小轮转。导出时打包日志目录，不要在页面中拼接单个日志文件内容。
- 全局 JS crash 捕获应统一进入 `Clog.error('[Crash]', exceptionInfo)`，不要再维护一套独立的 `CrashUtil` 或 `ExceptionLog.json`，除非有明确兼容需求。
- 日志清空只清理本机日志文件和临时导出压缩包，不影响账单、账户、预算等业务数据。页面显示的“本地占用”和“最近更新”如果统计整个日志目录，则清空逻辑也必须覆盖同一目录，避免统计范围和清理范围不一致。
- 清空日志成功后，页面应直接把展示状态置为 `暂无`、`0 KB`、不可导出；再次进入页面时再从文件系统重新计算真实状态。
- 日志导出成功、清空失败、压缩失败等操作要通过 `Clog.info/warn/error` 记录结果，但清空成功后不要立即写入新的 info 日志到同一日志目录，否则会出现刚清空又生成新日志的体验问题。

### 错误处理

```typescript
try {
  await this.dbStore!.executeSql(sql);
} catch (error) {
  const err = error as BusinessError;
  Clog.error(TAG, `操作失败: ${err.message}`);
}
```

### 测试编写

```typescript
import { describe, it, expect } from '@ohos/hypium';

export default function myUnitTest() {
  describe('MyTestSuite', () => {
    it('testCaseName', 0, () => {
      expect(someFunction()).assertEqual(expectedValue);
    });
  });
}
```

## ArkTS 特殊规则

1. **禁止使用 `any` 或 `unknown`**：必须使用具体类型
2. **禁止使用 `as` 类型断言**：使用类型守卫或显式类型
3. **禁止动态属性访问**：如 `obj[dynamicKey]`
4. **对象字面量必须有类型上下文**：通过类型化变量或参数提供

## 代码检查规则

项目配置了以下检查规则（见 `code-linter.json5`）：

- `@performance/recommended` - 性能最佳实践
- `@typescript-eslint/recommended` - TypeScript 推荐
- 安全规则（AES、Hash、RSA 等加密相关）

## 资源引用

`$r('sys.symbol.plus_circle')` - 系统资源 | `$r('app.color.brand')` - 应用资源

## 安全区处理方案

### 沉浸模式配置

项目在 `EntryAbility` 中设置了沉浸模式：

```typescript
this.windowUtil!.setImmersiveType(ImmersiveType.IMMERSIVE);
```

**沉浸模式效果**：

- 内容延伸到状态栏下方
- 状态栏可见
- 需要手动处理安全区避让

### 安全区布局结构

```
┌─────────────────────────────────────┐
│           状态栏 (可见)              │  ← safeAreaTop
├─────────────────────────────────────┤
│           标题栏                     │  ← TITLE_BAR_HEIGHT_MINI (56vp)
├─────────────────────────────────────┤
│                                     │
│           页面内容                   │
│                                     │
└─────────────────────────────────────┘
```

### 子页面安全区处理（HdsNavDestination）

子页面使用 `HdsNavDestination` 组件，配合 `titleBar.avoidLayoutSafeArea: true` 处理安全区：

```typescript
import { hdsMaterial, HdsNavDestination, ScrollEffectType } from '@kit.UIDesignKit';
import { WindowUtil } from 'kite_utils';
import { CommonConstants } from 'base';

@ComponentV2
export struct
ThemeSettings
{
  @
  Local
  pageInfos: NavPathStack = new NavPathStack()
  @
  Local
  winUtil: WindowUtil = AppStorageV2.connect(WindowUtil, 'winUtil')!;

  build()
  {
    HdsNavDestination()
    {
      Column()
      {
        // 页面内容
      }
      .
      width('100%')
        .height('100%')
        .backgroundColor($r('app.color.title_bar_bg'))
        // 关键：内容区 padding = 安全区高度 + 标题栏高度
        .padding({ top: this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_MINI })
    }
    .
    titleBar({
      padding: {
        start: LengthMetrics.vp(20),
        end: LengthMetrics.vp(2)
      },
      style: {
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR,
          blurEffectiveStartOffset: LengthMetrics.vp(0),
          blurEffectiveEndOffset: LengthMetrics.vp(20)
        },
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        },
        originalStyle: {
          backgroundStyle: { backgroundColor: $r('app.color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: { backgroundColor: $r('app.color.title_bar_bg') },
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('app.color.text_primary'),
              subTitleColor: $r('app.color.text_secondary')
            },
            backIconStyle: {
              backgroundColor: $r('app.color.action_bg'),
              iconColor: $r('app.color.text_primary')
            }
          }
        }
      },
      content: { title: { mainTitle: "页面标题" } },
      avoidLayoutSafeArea: true  // 关键：标题栏自动避让安全区
    })
      .onReady((context: NavDestinationContext) => {
        this.pageInfos = context.pathStack;
      })
  }
}
```

### 主页面安全区处理（HdsNavigation）

主页面使用 `HdsNavigation` 组件，通过 `ignoreLayoutSafeArea` 处理安全区：

```typescript
HdsNavigation(this.pageInfos)
{
  Column()
  { /* 内容 */
  }
  .
  padding({
    top: this.winUtil.mainWindowInfo.safeAreaTop + CommonConstants.TITLE_BAR_HEIGHT_FREE,
    left: 16,
    right: 16
  })
}
.
titleBar({
  avoidLayoutSafeArea: true
})
  .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
```

### 标题栏高度常量

在 `CommonConstants` 中定义：

```typescript
// HdsNavDestination 标题栏高度
// HdsNavDestinationTitleMode.MINI: 标题栏高度 56vp
static
readonly
TITLE_BAR_HEIGHT_MINI: number = 56;

// HdsNavDestination 半模态模式
// HdsNavDestinationTitleMode.MODAL: 背板高度 64vp，标题栏高度 56vp，上 padding 8vp
static
readonly
TITLE_BAR_HEIGHT_MODAL: number = 56;
static
readonly
TITLE_BAR_BACKPLATE_HEIGHT_MODAL: number = 64;
static
readonly
TITLE_BAR_PADDING_TOP_MODAL: number = 8;
```

### 安全区相关属性

| 属性               | 作用           | 使用场景           |
|------------------|--------------|----------------|
| `safeAreaTop`    | 顶部安全区高度（状态栏） | 所有页面顶部 padding |
| `safeAreaBottom` | 底部安全区高度      | 底部弹窗、输入框避让     |
| `keyboardHeight` | 键盘高度         | 键盘弹出时动态避让      |

### 注意事项

1. **不要使用 `expandSafeArea`**：在沉浸模式下，`expandSafeArea` 会让组件扩展到安全区，与预期相反
2. **使用常量而非魔法数字**：标题栏高度使用 `CommonConstants.TITLE_BAR_HEIGHT_MINI`
3. **WindowUtil 必须通过 AppStorageV2 获取**：确保全局共享同一实例

## 多设备适配

### 断点系统

项目使用 `BreakpointSystem` 进行响应式布局，断点定义如下：

| 断点   | 宽度范围                  | 设备类型    |
|------|-----------------------|---------|
| `sm` | 320vp ≤ width < 600vp | 手机      |
| `md` | 600vp ≤ width < 840vp | 平板竖屏    |
| `lg` | 840vp ≤ width         | 平板横屏、PC |

### Tab 栏多设备适配

主入口页面根据设备尺寸智能显示/隐藏 Tab 栏，使用 `mainTabController` 控制动画：

```typescript
import { mainTabController } from 'base';
import { HdsAnimationMode } from '@kit.UIDesignKit';

// 主入口 - 使用全局 controller
HdsTabs
({ controller: mainTabController })
{
  // ...
}

// 导航到子页面时隐藏 Tab
private
navigateToSubPage(name:
string
)
:
void {
  mainTabController
  .
  applyHideAnimation
  (
  HdsAnimationMode
  .
  SCROLL_ANIMATION
  )
  ;
  this
  .
  pageInfos
  .
  pushPath({ name: name });
}

// 子页面返回时显示 Tab
HdsNavDestination()
{
  // ...
}
.
onBackPressed(() => {
  mainTabController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
  return false;
})
```

**Tab 显示规则**：

| 设备           | 主页面    | 子页面    |
|--------------|--------|--------|
| 手机 (sm)      | 显示 Tab | 隐藏 Tab |
| 平板竖屏 (md)    | 显示 Tab | 隐藏 Tab |
| 平板横屏/PC (lg) | 显示 Tab | 显示 Tab |

### 断点系统使用注意事项

1. **必须注册和注销**：在 `aboutToAppear` 中调用 `register()`，在 `aboutToDisappear` 中调用 `unregister()`
2. **通过 AppStorageV2 获取**：确保全局共享同一实例
3. **响应式更新**：使用 `@Local` 装饰器，断点变化时 UI 自动更新

## Git 提交规范

### 提交消息格式

```
<type>: <description>
```

### 提交类型

| 类型         | 说明        | 示例                            |
|------------|-----------|-------------------------------|
| `feat`     | 新功能       | `feat: 添加用户登录动画效果`            |
| `fix`      | 修复 bug    | `fix: 修复头像旋转动画闪烁问题`           |
| `refactor` | 重构（不改变功能） | `refactor: 统一 UIContext 参数命名` |
| `style`    | 代码格式调整    | `style: 格式化代码缩进`              |
| `docs`     | 文档更新      | `docs: 更新 README 文件`          |
| `test`     | 测试相关      | `test: 添加登录功能单元测试`            |
| `chore`    | 构建/工具/依赖  | `chore: 更新依赖版本`               |

### Git 操作流程

**重要规则**：

1. **写好一个小功能就要提交**，不要积累太多改动
2. **提交前必须先问用户**，得到确认后再执行 `git commit`
3. **推送前必须先问用户**，得到确认后再执行 `git push`

**操作示例**：

```bash
# 1. 查看改动
git status
git diff

# 2. 添加改动（等待用户确认）
git add <files>

# 3. 提交（必须先问用户）
git commit -m "feat: 添加新功能"

# 4. 推送（必须先问用户）
git push
```

### Git Worktree 工作流程

**重要**：如果用户说要使用worktree，那么所有开发工作必须在独立的 worktree 分支上进行，不在 main 分支直接开发，默认在main分支开发

**开发新功能流程**：

```bash
# 1. 创建 worktree 和新分支
git worktree add .worktrees/KiteBook_<feature-name> -b feature/<feature-name>

# 2. 切换到 worktree 目录进行开发
cd .worktrees/KiteBook_<feature-name>

# 3. 进行开发、构建、测试
# ... 开发工作 ...

# 4. 提交并推送
git add .
git commit -m "feat: 实现xxx功能"
git push -u origin feature/<feature-name>

# 5. 在 GitHub 创建 Pull Request

# 6. 合并到 main 后，删除 worktree
cd /Users/zestbox/MyCode/projects/KiteBook  # 回到主目录
git worktree remove .worktrees/KiteBook_<feature-name>
git branch -d feature/<feature-name>  # 删除本地分支
```

**常用命令**：

```bash
# 查看所有 worktree
git worktree list

# 删除 worktree
git worktree remove .worktrees/KiteBook_<feature-name>

# 强制删除（有未提交改动时）
git worktree remove --force .worktrees/KiteBook_<feature-name>
```

**Worktree 目录结构**：

```
KiteBook/
├── .worktrees/                    # worktree 目录
│   ├── KiteBook_billing/                   # feature/billing 分支
│   └── KiteBook_reports/                   # feature/reports 分支
├── products/
├── features/
└── ...
```

## 常见问题

**编译失败**: 检查类型是否正确（避免 any），确认导入路径正确，或运行 `hvigorw clean` 清理缓存后重新构建。

**测试失败**: 确认测试文件在正确的目录（`src/test` 或 `srcohsTest`），检查测试依赖是否安装。

## 主题与深色模式兼容

### 主题颜色系统

项目使用 `AppThemeState` 管理主题颜色，在入口文件 `Index.ets` 中通过 `onWillApplyTheme` 回调自动同步，其他页面直接使用即可：

```typescript
// 获取主题状态（全局共享，自动跟随深色/浅色模式）
@Local
themeState: AppThemeState =
  AppStorageV2.connect(AppThemeState, 'themeState', () => new AppThemeState())!;
```

**重要**：

- `onWillApplyTheme` 只需在入口文件 `products/entry/src/main/ets/pages/Index.ets` 中实现
- `AppThemeState` 中的颜色会根据深色/浅色模式自动切换，不要使用硬编码颜色值

### 颜色使用规范

| 场景      | 使用属性                       | 说明         |
|---------|----------------------------|------------|
| 品牌色/选中态 | `themeState.brand`         | 按钮、选中项、强调色 |
| 一级文本    | `themeState.fontPrimary`   | 标题、主要内容    |
| 二级文本    | `themeState.fontSecondary` | 副标题、描述文字   |
| 一级图标    | `themeState.iconPrimary`   | 主要图标       |
| 二级图标    | `themeState.iconSecondary` | 次要图标、未选中态  |

### TabBar 主题色适配

底部 Tab 栏需要使用 `TabBarSymbol` + `SymbolGlyphModifier` 实现主题色适配：

```typescript
import { SymbolGlyphModifier } from '@kit.ArkUI';

// 创建带主题色的 TabBarSymbol
private
createTabBarSymbol(icon:
Resource
)
:
TabBarSymbol
{
  return {
    normal: new SymbolGlyphModifier(icon)
      .fontColor([this.themeState.iconSecondary])  // 未选中：二级图标色
      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
      .fontSize(24)
      .fontWeight(this.optionSystem.iconThickness),
    selected: new SymbolGlyphModifier(icon)
      .fontColor([this.themeState.brand])  // 选中：品牌色
      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
      .fontSize(24)
      .fontWeight(this.optionSystem.iconThickness)
  };
}

// 使用方式
TabContent()
{
  Home()
}
.
tabBar(new BottomTabBarStyle(this.createTabBarSymbol($r('sys.symbol.house')), '首页')
  .labelStyle({
    selectedColor: this.themeState.brand, // 选中文字：品牌色
    unselectedColor: this.themeState.fontSecondary  // 未选中文字：二级文本色
  }))
```

**注意事项**：

1. 图标必须使用 `sys.symbol.*` 资源，不能使用 `sys.media.*`
2. `SymbolGlyphModifier` 是类型，需要通过 `new` 创建实例
3. `LabelStyle` 不支持 `fontWeight` 属性，文字粗细无法单独设置

### SettingItem 组件规范

SettingItem 使用 Button 包裹实现按压反馈，避免闪烁问题：

```typescript
@ComponentV2
export struct
SettingItem
{
  @
  Param
  icon: Resource = $r('sys.symbol.gearshape')
  @
  Param @
  Require
  title: ResourceStr | string = ''
  @
  Event
  onItemClick: () => void = () => {
  }
  @
  Local
  optionSystem: SystemOptions =
    PersistenceV2.connect(SystemOptions, 'SystemOptions', () => new SystemOptions())!

  build()
  {
    Button()
    {
      Row()
      {
        Row
        ({ space: 12 })
        {
          SymbolGlyph(this.icon)
            .fontSize(20)
            .fontWeight(this.optionSystem.iconThickness)
            .fontColor([$r('app.color.text_primary')])
          Text(this.title)
            .fontSize(16)
            .fontWeight(this.optionSystem.fontThickness)
            .fontColor($r('app.color.text_primary'))
        }
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(20)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([$r('app.color.text_primary')])
      }
      .
      justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
    }
    .
    backgroundColor('#00000000')  // 透明背景，继承 ListItemGroup 的 CARD 样式
      .onClick(() => {
        this.onItemClick()
      })
  }
}
```

**关键点**：

1. 使用 `Button` 包裹，系统自动处理按压反馈
2. 背景色设为透明 `#00000000`，继承父容器的 CARD 样式
3. 不要手动设置 `backgroundColor` 或按压状态，否则会导致闪烁
4. 使用 `ListItemGroupStyle.CARD` 样式时，子项背景会自动适配深色/浅色模式

### 资源颜色定义

共享颜色资源定义在 `commons/shared_assets/src/main/resources/` 目录：

- `base/element/color.json` - 浅色模式颜色
- `dark/element/color.json` - 深色模式颜色

系统会根据当前模式自动加载对应的颜色资源。

### 不需要运行到模拟器，我自己手动运行到真机
