# KiteBook - HarmonyOS 记账应用

一款基于 HarmonyOS 开发的个人记账应用，帮助用户轻松管理日常收支。

## 项目信息

- **应用名称**: KiteBook
- **包名**: `cn.zestbox.kitebook`
- **版本**: 1.0.0
- **SDK版本**: 6.1.0(23)
- **开发语言**: ArkTS
- **构建系统**: hvigor

## 项目结构

```
KiteBook/
├── AppScope/              # 应用全局配置
├── products/              # 入口模块
│   └── entry/            # 主入口 HAP
├── commons/               # 共享模块
│   ├── base/             # 基础组件和常量
│   └── kite_utils/       # 工具库（独立发版）
├── features/              # 功能模块
│   ├── home/             # 首页
│   ├── billing/          # 账单
│   ├── record/           # 记账记录
│   ├── reports/          # 报表
│   └── profile/          # 个人中心
├── hvigor/                # 构建配置
└── build/                 # 构建产物
```

## 功能特性

### 已完成功能

- ✅ 个人中心页面
    - 用户信息展示与编辑
    - 华为账号登录
    - 登录/退出动画效果（头像旋转、用户名滑动）
    - 主题设置
    - 字体大小设置
    - 通知设置
    - 深色模式
    - 数据导出
    - 关于页面

- ✅ 动画效果
    - 头像旋转动画：登录时默认头像旋转，90度时切换为用户头像
    - 用户名滑动动画：旧文字向左滑出，新文字从右侧滑入
    - 按钮动画：登录按钮缩小消失，更新/退出按钮放大出现

### 开发中功能

- 🚧 首页
- 🚧 账单管理
- 🚧 记账记录
- 🚧 数据报表

## 技术栈

- **UI框架**: ArkUI (声明式UI)
- **状态管理**: `@ComponentV2` + `@Local` + `@Param` + `@Monitor`
- **持久化**: `PersistenceV2`
- **网络请求**: 自定义 request 工具
- **数据库**: 自定义 dbManager 工具
- **动画**: `animateTo` + `curves.springMotion`

## 构建和运行

### 环境要求

- DevEco Studio 6.0+
- HarmonyOS SDK 6.1.0(23)

### 构建项目

```bash
# 完整构建
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

### 测试

```bash
# 运行模块单元测试
hvigorw test@entry --mode module -p product=default
hvigorw test@home --mode module -p product=default
```

## 模块说明

### kite_utils 工具库

`kite_utils` 是独立发版的工具库，包含以下通用工具：

| 工具               | 说明                                        |
|------------------|-------------------------------------------|
| `request`        | 网络请求工具，支持 GET/POST/PUT/DELETE，内置 Token 管理 |
| `dbManager`      | 数据库工具，支持版本管理和渐进式升级                        |
| `Clog`           | 日志工具，支持 info/warn/error 多级别日志             |
| `HSBColorPicker` | 颜色选择器组件，支持 HSB 模式和透明度                     |
| `BreakPoint`     | 响应式断点工具                                   |
| `WindowUtil`     | 窗口信息工具，处理安全区避让等                           |

**注意**: 本项目的业务代码不能写到 `kite_utils` 模块中。

## 代码规范

### 命名约定

| 类型      | 约定                | 示例                   |
|---------|-------------------|----------------------|
| 类名      | PascalCase        | `DatabaseManager`    |
| 接口名     | I + PascalCase    | `IDatabaseCallbacks` |
| 枚举名     | PascalCase + Enum | `OrderStatusEnum`    |
| 函数名/变量名 | camelCase         | `initRequest()`      |
| 常量      | UPPER_SNAKE_CASE  | `BUNDLE_NAME`        |

### 组件命名

| 类型   | 命名方式            | 示例                  |
|------|-----------------|---------------------|
| 页面组件 | 功能名，无后缀         | `Index`, `Home`     |
| 通用组件 | 可加 Component 后缀 | `UserCardComponent` |
| 弹窗组件 | XxxDialog       | `ConfirmDialog`     |

### 日志规范

```typescript
const TAG: string = '[ComponentName]';
Clog.info(TAG, '信息日志');
Clog.warn(TAG, '警告信息');
Clog.error(TAG, '错误信息', errorObject);
```

## 许可证

Copyright (C) 2026 ZestBox
