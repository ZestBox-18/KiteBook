# kite_utils 模块文档

`kite_utils` 是一个面向 HarmonyOS ArkTS 项目的通用工具库，当前提供以下能力：

- Network 网络请求封装
- relationalStore 关系型数据库管理与升级
- Clog 日志打印与日志落盘
- BreakPoint / BreakpointSystem 响应式断点工具
- WindowUtil 窗口信息与沉浸式能力
- GlobalContext 全局上下文管理
- 常用UI组件

## 目录

- [安装](#安装)
- [Network 网络请求工具](#network-网络请求工具)
  - [特性](#特性)
  - [安装和配置](#安装和配置)
  - [API 文档](#api-文档)
  - [使用示例](#使用示例)
- [关系型数据库relationalStore工具](#关系型数据库relationalstore工具)
  - [概述](#概述)
  - [核心特性](#核心特性)
  - [使用说明](#使用说明)
  - [数据库回调功能](#数据库回调功能)
  - [最佳实践](#最佳实践)
  - [常见问题](#常见问题)
- [Clog 日志工具](#clog-日志工具)
  - [概述](#概述-1)
  - [核心特性](#核心特性-1)
  - [API 文档](#api-文档-1)
  - [使用示例](#使用示例-1)
  - [配置方法](#配置方法)
  - [最佳实践](#最佳实践-1)
- [BreakPoint 断点工具类](#breakpoint-断点工具类)
  - [使用示例](#使用示例-3)
- [模块说明](#模块说明)
- [WindowUtil 窗口工具](#windowutil-窗口工具)
- [GlobalContext 全局上下文](#globalcontext-全局上下文)
- [UI 组件](#ui-组件)

## 安装

```bash
ohpm install kite_utils
```

## 模块说明

当前模块版本：`1.0.13`

适用场景：

- 为 HarmonyOS ArkTS 项目统一网络请求入口
- 为业务模块提供关系型数据库版本管理能力
- 提供日志记录、日志导出与问题排查基础能力
- 提供多设备断点响应、窗口安全区和沉浸式相关支持
- 提供全局上下文、颜色选择器和常用 UI 组件

## Network 网络请求工具

一个专为ArkTS开发的网络请求工具包，提供简洁易用的HTTP请求封装。

### 特性

- 🚀 简洁的API设计，易于使用
- 🔧 支持GET、POST、PUT、DELETE等HTTP方法
- 🔐 内置Token管理，支持全局认证
- ⏱️ 支持请求超时设置
- 📝 完整的TypeScript类型支持
- 🛡️ 统一的错误处理机制
- 🔄 自动处理请求参数和响应数据

### 安装和配置

#### 1. 初始化配置

使用网络请求工具的时候需要先配置一个config.ets文件：

```ets
import { initRequest } from "kite_utils";

type EnvName = "development" | "production" | "topLine";

const ENV_CONFIG = new Map<EnvName, string>([
["development", "https://development.com/api"],
["production", "https://production.com/api"],
["topLine", "https://topLine.com/api"],
]);

// 设置当前的开发环境
export function SetBaseApi(name: EnvName) {
const config = ENV_CONFIG.get(name);
initRequest(config);
}
```

##### 2. 应用初始化

然后要在应用启动时进行初始化，如在`entry/src/main/ets/entryability/EntryAbility.ets`中设置：

```arkts
import { SetBaseApi } from '../api/config';
SetBaseApi('development')
```

### API 文档

#### 核心方法

##### `initRequest(baseApi: string)`

初始化网络请求配置，设置全局API基础地址。

**参数:**

- `baseApi`: API基础地址，例如 'https://api.example.com'

##### `request(options: RequestOptions)`

发起HTTP请求的核心方法。

**参数:**

- `options.url`: 请求路径，相对于baseApi
- `options.method`: 请求方法，支持 'get' | 'post' | 'put' | 'delete'，默认为'get'
- `options.data`: 请求数据，GET请求时作为查询参数，其他请求时作为请求体
- `options.headers`: 自定义请求头，会与全局请求头合并
- `options.readTimeout`: 读取超时时间，单位毫秒
- `options.connectTimeout`: 连接超时时间，单位毫秒

**返回值:** `Promise<any>` 解析后的响应数据

##### `setGlobalToken(token: string)`

设置全局认证token，设置后所有请求都会自动携带此token。

##### `clearGlobalToken()`

清空全局认证token，通常在用户退出登录时调用。

#### 类型定义

##### `Method` 枚举

```typescript
enum Method {
GET = 'get', // 获取数据
POST = 'post', // 创建数据
PUT = 'put', // 更新数据
DELETE = 'delete' // 删除数据
}
```

##### `AnyValue` 类型

```typescript
type AnyValue = any; // 通用返回值类型
```

### 使用示例

#### 基础用法

```arkts
import { AnyValue, request, Method } from 'kite_utils';
import { rcp } from '@kit.RemoteCommunicationKit';


export default class testApi {
  /**
   * 获取笑话列表 - GET请求示例
   * 演示如何使用GET方法获取数据，包含查询参数
   */
  static getJokes(): Promise<AnyValue> {
    return request({
      url: '/api/jokes/list',
      method: Method.GET,
      readTimeout: 1000,
      data: {
        page: 1,
        app_id: '123',
        app_secret: '123'
      }
    })
  }

  /**
   * CDK兑换 - POST请求示例
   * 演示如何使用POST方法提交数据
   */
  static cdkExchange(cdk: string, cdk_uid: string): Promise<AnyValue> {
    return request({
      url: '/yuelancdk/verify',
      method: Method.POST, // 推荐使用枚举
      data: {
        cdk: cdk,
        cdk_uid: cdk_uid
      }
    });
  }

  /**
   * 上传附件 - 文件上传示例
   * 演示如何上传文件，包含自定义请求头
   *
   * 使用前需要先准备文件数据：
   * ```typescript
   * // 文件选择和准备
   * documentViewPicker.select(documentSelectOptions).then(async (documentSelectResult: Array<string>) => {
   *   // 文件上传的时候一定要先拷贝一份，然后进行上传，否则没权限操作文件
   *   const context = getContext(this)
   *   const fileType = 'jpg'
   *   // 以时间戳生成新的文件名
   *   const fileName = Date.now() + '.' + fileType
   *   // 通过缓存路径+文件名 拼接出完整的路径
   *   const copyFilePath = context.cacheDir + '/' + fileName
   *   // 将文件拷贝到临时目录
   *   const file = fs.openSync(documentSelectResult[0], fs.OpenMode.READ_ONLY)
   *   fs.copyFileSync(file.fd, copyFilePath)
   *
   *   const formFieldFileValue: rcp.FormFieldFileValue = {
   *     contentType: "image/png",
   *     remoteFileName: fileName,
   *     contentOrPath: copyFilePath,
   *   };
   *
   *   const formData = new rcp.MultipartForm({
   *     'file': formFieldFileValue // file表示服务器端接收的数据的属性名
   *   })
   *
   *   // 调用上传接口
   *   const result = await testApi.uploadAttachment(formData);
   * });
   * ```

   */
  static uploadAttachment(formData: rcp.MultipartForm): Promise<AnyValue> {
    return request({
      url: '/notification/upload',
      method: Method.POST,
      headers: {
        'Content-Type': 'multipart/form-data'
      },
      data: formData
    })
  }

  /**

   * 获取图标 - 带超时设置的GET请求示例
   * 演示如何设置连接和读取超时时间
   */
  static getIcon(url: string): Promise<AnyValue> {
    return request({
      url: '/icon/get',
      method: Method.GET,
      readTimeout: 10000, // 读取超时10秒
      connectTimeout: 10000, // 连接超时10秒
      data: {
        url: url,
      }
    });
  }
};

```

#### 页面调用

```ts

import testApi from '../api/test';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  aboutToAppear(): void {

  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
          testApi.getJokes().then((res:string)=>{
            console.log(JSON.stringify(res))
          }).catch((err:Error)=>{
            console.log(JSON.stringify(err))
          })
        })
    }
    .height('100%')
    .width('100%')
  }
}
```

## 关系型数据库relationalStore工具

### 概述

本系统提供了完整的SQLite数据库版本管理和升级解决方案，支持从版本0（首次安装）开始的渐进式升级。

### 核心特性

- ✅ 自动版本检测和升级
- ✅ 渐进式升级路径（支持跨版本升级）
- ✅ 事务支持（所有操作在事务中执行，确保数据一致性）
- ✅ 完整的错误处理和日志记录
- ✅ 类型安全的配置接口
- ✅ 支持复杂的SQL升级脚本
- ✅ 数据库回调功能（支持初始化、升级完成、版本一致回调）

### 使用说明

#### 1. 安装和配置

##### 初始化配置

使用关系型数据库relationalStore工具的时候需要先配置一个config.ets文件：

```ts
import { DatabaseCallbacks, DatabaseUpgradeSql, dbManager, initDatabaseConfig } from 'kite_utils';
import { relationalStore } from '@kit.ArkData';


/**
 * 数据库升级脚本配置
 * 注意：确保升级路径的连续性，每个版本都要有对应的升级脚本
 */
const upgradeSqls: DatabaseUpgradeSql[] = [
  {
    fromVersion: 1,
    toVersion: 2,
    description: '添加用户头像字段和最后登录时间',
    sql: [
      `CREATE TABLE IF NOT EXISTS user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        setting_key TEXT NOT NULL,
        setting_value TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, setting_key)
      );`,
    ]
  },
  {
    fromVersion: 2,
    toVersion: 3,
    description: '创建用户设置表和用户角色表',
    sql: [
      `CREATE TABLE IF NOT EXISTS user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        setting_key TEXT NOT NULL,
        setting_value TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, setting_key)
      );`,
      `CREATE TABLE IF NOT EXISTS user_roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        role_name TEXT NOT NULL,
        granted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        granted_by INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by) REFERENCES users(id)
      );`,
      'CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings(user_id);',
      'CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);',
      'CREATE INDEX IF NOT EXISTS idx_user_roles_role_name ON user_roles(role_name);'
    ]
  }
];

/**
 * 初始化数据库管理器
 * @param context 应用上下文
 */
export function dbManagerInit(context: Context): void {
  initDatabaseConfig({
    dbName: 'db_charactech',
    SecurityLevel: relationalStore.SecurityLevel.S3,
    dbSql: {
      "users": 'CREATE TABLE IF NOT EXISTS users (\n' +
        '    id INTEGER PRIMARY KEY AUTOINCREMENT,\n' +
        '    name TEXT NOT NULL,\n' +
        '    email TEXT UNIQUE NOT NULL,\n' +
        '    phone TEXT,\n' +
        '    age INTEGER,\n' +
        '    gender TEXT,\n' +
        '    address TEXT,\n' +
        '    avatar_url TEXT,\n' +
        '    last_login_at DATETIME,\n' +
        '    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,\n' +
        '    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP\n' +
        ');',
      "user_settings": `CREATE TABLE IF NOT EXISTS user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        setting_key TEXT NOT NULL,
        setting_value TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, setting_key)
      );`,
      "user_roles": `CREATE TABLE IF NOT EXISTS user_roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        role_name TEXT NOT NULL,
        granted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        granted_by INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by) REFERENCES users(id)
      );`
    },
    version: 3,
    upgradeSqls: upgradeSqls
  });

  // 设置数据库回调
  const callbacks: DatabaseCallbacks = {
    onDatabaseInitialized: async (): Promise<void> => {
      console.log('=== 数据库初始化完成回调 ===');
      console.log('数据库首次创建完成，可以执行初始化操作');
    },
    onDatabaseUpgraded: async (fromVersion: number, toVersion: number): Promise<void> => {
      console.log('=== 数据库升级完成回调 ===');
      console.log(`数据库升级完成: ${fromVersion} -> ${toVersion}`);
      console.log('可以在这里执行升级后的清理或初始化操作');
    },
    onDatabaseVersionConsistent: async (currentVersion: number): Promise<void> => {
      console.log('=== 数据库版本一致回调 ===');
      console.log(`当前数据库版本已是最新，无需操作，版本: ${currentVersion}`);
    }
  };

  dbManager.setCallbacks(callbacks);
  dbManager.init(context);
  dbManager.createDatabaseStore();
}
```

#### 回调特性

- **类型安全**: 所有回调参数都有明确的类型定义
- **异步支持**: 回调函数支持异步操作，可以返回Promise
- **错误处理**: 回调函数内部的错误会被捕获并记录，不会影响数据库操作
- **可选配置**: 所有回调都是可选的，可以根据需要选择性实现
- **自动触发**: 回调会在相应的数据库操作完成后自动触发

#### 使用场景

1. **数据初始化**: 在数据库首次创建后插入默认数据
2. **缓存清理**: 在数据库升级后清理相关缓存
3. **用户通知**: 向用户展示数据库操作的进度或结果
4. **日志记录**: 记录数据库操作的详细信息用于调试
5. **性能监控**: 统计数据库操作的耗时和成功率

#### 注意事项

- 回调函数应该尽量简洁，避免执行耗时操作
- 回调函数中的异常不会影响数据库操作的结果
- 建议在回调中添加适当的错误处理逻辑
- 回调函数会在数据库操作的同一线程中执行

#### 2. 应用初始化

然后要在应用启动时进行初始化，如在`entry/src/main/ets/entryability/EntryAbility.ets`中加入：

```arkts
import { dbManagerInit } from '../database/config';
// ……
onWindowStageCreate(windowStage: window.WindowStage): void {
    // ……
    // 初始化用户数据库
    dbManagerInit(this.context);
		// ……
  }
```

#### 3. 版本升级流程

系统支持以下升级场景：

- **用户首次安装**：版本0 → 直接创建最新版本的表结构
- **用户从版本1升级**：版本1 → 版本2 → 版本3
- **用户从版本2升级**：版本2 → 版本3
- **版本已是最新**：无需操作

##### 添加新版本的步骤

当需要升级数据库时，请按以下步骤操作：

###### a) 更新版本号

```typescript
export function dbManagerInit(context: Context): void {
  initDatabaseConfig({
    // ... 其他配置
    version: 4, // 更新到新版本号
    upgradeSqls: upgradeSqls
  });
}
```

###### b) 添加升级脚本

在 `upgradeSqls` 数组中添加新的升级脚本：

```typescript
const upgradeSqls: DatabaseUpgradeSql[] = [
// ... 现有脚本
  {
    fromVersion: 3,
    toVersion: 4,
    description: '添加新功能表',
    sql: [
      `CREATE TABLE IF NOT EXISTS new_feature (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );`,
      'CREATE INDEX IF NOT EXISTS idx_new_feature_name ON new_feature(name);'
    ]
  }
];
```

###### c) 更新建表SQL（用于首次安装）

确保 `dbSql` 中包含最新版本的完整表结构：

```typescript
dbSql: {
  "users":
  '...',
  "user_settings":
  '...',
  "user_roles":
  '...',
  "new_feature":
  `CREATE TABLE IF NOT EXISTS new_feature (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );`
}
```

##### 升级脚本注意事项

* 幂等性

确保SQL语句可以重复执行而不会出错：

```sql
-- ✅ 正确：使用 IF NOT EXISTS
CREATE TABLE IF NOT EXISTS new_table (...);
ALTER TABLE users ADD COLUMN IF NOT EXISTS new_column TEXT;
CREATE INDEX IF NOT EXISTS idx_name ON table(column);

-- ❌ 错误：可能导致重复执行失败
CREATE TABLE new_table (...);
ALTER TABLE users ADD COLUMN new_column TEXT;
```

* 执行顺序

升级脚本中的SQL语句按数组顺序执行，确保依赖关系正确：

```typescript
sql: [
// 1. 先创建表
  'CREATE TABLE IF NOT EXISTS parent_table (...);',
  // 2. 再创建依赖表
  'CREATE TABLE IF NOT EXISTS child_table (...);',
  // 3. 最后创建索引
  'CREATE INDEX IF NOT EXISTS idx_name ON child_table(parent_id);'
]
```

* 版本连续性

确保 `fromVersion` 和 `toVersion` 形成连续的升级路径：

```typescript
// ✅ 正确：连续的升级路径
{
  fromVersion: 1, toVersion:
  2
}
,
{
  fromVersion: 2, toVersion:
  3
}
,
{
  fromVersion: 3, toVersion:
  4
}

// ❌ 错误：缺少中间版本
{
  fromVersion: 1, toVersion:
  2
}
,
{
  fromVersion: 3, toVersion:
  4
} // 缺少 2->3 的升级脚本
```

#### 错误处理

系统提供完整的错误处理机制：

- 所有数据库操作都在事务中执行，出现错误时自动回滚
- 升级过程中如果出现错误，会抛出异常并停止升级
- 所有错误都会记录详细的日志信息
- 事务回滚确保数据库状态一致性，但仍建议在生产环境中添加数据库备份机制

### 最佳实践

#### 测试升级脚本

在发布前务必测试升级脚本：

```typescript
// 测试不同版本的升级路径
// 1. 从版本1升级到最新版本
// 2. 从版本2升级到最新版本
// 3. 首次安装（版本0到最新版本）
```

#### 备份策略

虽然系统提供事务回滚机制，但仍建议在生产环境中实现数据库备份：

```typescript
// 在升级前创建备份
private
async
backupDatabase():
Promise<
void > {
  // 实现数据库备份逻辑
}
```

#### 事务回滚

系统内置事务回滚机制，无需额外开发：

```typescript
// 系统自动处理事务回滚
// 任何SQL执行失败都会自动回滚整个事务
// 确保数据库状态的一致性
```

### 示例场景

#### 场景1：首次使用（版本1用户）

用户首次使用时，数据库版本为1，系统会：

1. 检测当前版本：1
2. 目标版本：3
3. 执行升级脚本：1→2, 2→3
4. 更新数据库版本为3

#### 场景2：新用户安装

新用户安装时，数据库版本为0，系统会：

1. 检测当前版本：0
2. 直接创建最新版本（版本3）的所有表
3. 设置数据库版本为3

#### 场景3：已是最新版本

用户已经是最新版本时：

1. 检测当前版本：3
2. 目标版本：3
3. 无需操作

### 常见问题

#### Q: 如何处理数据迁移？

A: 在升级脚本中添加数据迁移SQL：

```sql
-- 迁移数据到新表结构
INSERT INTO new_table (id, name) SELECT id, old_name FROM old_table;
-- 删除旧表
DROP TABLE IF EXISTS old_table;
```

#### Q: 如何处理字段重命名？

A: SQLite不支持直接重命名字段，需要重建表：

```sql
-- 1. 创建新表
CREATE TABLE users_new (id INTEGER PRIMARY KEY, new_name TEXT);
-- 2. 迁移数据
INSERT INTO users_new SELECT id, old_name FROM users;
-- 3. 删除旧表
DROP TABLE users;
-- 4. 重命名新表
ALTER TABLE users_new RENAME TO users;
```

#### Q: 升级失败怎么办？

A: 系统会抛出异常并记录详细错误信息。建议：

1. 检查升级脚本的SQL语法
2. 确保升级路径的连续性
3. 在测试环境中验证升级脚本
4. 考虑实现数据库备份和回滚机制

### 日志示例

```
当前数据库版本: 1, 目标版本: 3
开始数据库升级: 1 -> 3
执行升级脚本: 1 -> 2
升级描述: 添加用户头像字段和最后登录时间
执行SQL语句 1/3: ALTER TABLE users ADD COLUMN avatar_url TEXT;
SQL语句 1 执行成功
执行SQL语句 2/3: ALTER TABLE users ADD COLUMN last_login_at DATETIME;
SQL语句 2 执行成功
执行SQL语句 3/3: CREATE INDEX IF NOT EXISTS idx_users_last_login ON users(last_login_at);
SQL语句 3 执行成功
升级脚本 1 -> 2 执行完成
执行升级脚本: 2 -> 3
升级描述: 创建用户设置表和用户角色表
...
数据库升级完成，版本更新为: 3
```

### 总结

通过以上配置和使用方式，你可以轻松地在HarmonyOS应用中集成完整的数据库版本管理功能。系统会自动处理数据库的创建、升级和数据迁移，确保应用在不同版本间的平滑过渡。

## Clog 日志工具

### 概述

Clog是一个专为ArkTS/HarmonyOS开发的轻量级日志工具，基于HarmonyOS的hilog系统构建。它提供了简洁易用的API，支持多种数据类型的日志输出，并具备灵活的配置能力。

### 核心特性

- 🚀 **简洁的API设计** - 提供info、warn、error、log四种日志级别
- 🔧 **多参数支持** - 支持2个参数（tag + content）和3个参数（tag + content1 + content2）的重载
- 📝 **多类型支持** - 支持字符串、数字、布尔值、对象、数组等多种数据类型
- ⚙️ **灵活配置** - 支持自定义日志域和日志前缀
- 🎯 **类型安全** - 完整的TypeScript类型支持，符合ArkTS规范
- 📊 **智能格式化** - 自动格式化JSON对象，提供良好的可读性
- 🔍 **标签管理** - 支持标签分类，便于日志过滤和查找

### API 文档

#### 核心方法

##### `info(tag: string, content: LogContent)` / `info(tag: string, content1: LogContent, content2: LogContent)`

打印信息级别日志。

**参数:**
- `tag`: 日志标签，用于分类和过滤
- `content` / `content1, content2`: 日志内容，支持多种数据类型

##### `warn(tag: string, content: LogContent)` / `warn(tag: string, content1: LogContent, content2: LogContent)`

打印警告级别日志。

##### `error(tag: string, content: LogContent)` / `error(tag: string, content1: LogContent, content2: LogContent)`

打印错误级别日志。

##### `log(tag: string, content: LogContent)` / `log(tag: string, content1: LogContent, content2: LogContent)`

打印普通日志（使用info级别）。

#### 配置方法
在入口文件进行：
##### `Clog.init(context)`
设置日志域，用于日志文件的生成。

##### `setLogDomain(domain: number)`

设置日志域，用于HarmonyOS hilog系统的日志分类。

**参数:**
- `domain`: 日志域值，默认为0x0fff

##### `setPrefix(prefix: string)`

设置日志前缀，用于标识日志来源。

**参数:**
- `prefix`: 日志前缀字符串，默认为'[Charactech]'

##### `getLogDomain(): number`

获取当前日志域值。

##### `getPrefix(): string`

获取当前日志前缀。

#### 类型定义

```typescript
/**
 * 支持的日志内容类型
 */
type LogContent = string | number | boolean | null | undefined | object | Array<LogContent>;
```

### 使用示例

#### 基础用法

```typescript
import { Clog } from 'kite_utils';

// 基础日志输出
Clog.info('APP', '应用启动完成');
Clog.warn('NETWORK', '网络连接不稳定');
Clog.error('DATABASE', '数据库连接失败');
Clog.log('USER', '用户操作记录');

// 多参数日志输出
Clog.info('LOGIN', '用户登录', { userId: 12345, userName: 'testUser' });
Clog.error('API', '请求失败', { errorCode: 500, message: 'Internal Server Error' });
```

#### 多种数据类型支持

```typescript
// 字符串
Clog.info('STRING', 'Hello World');

// 数字
Clog.info('NUMBER', 42);
Clog.info('FLOAT', 3.14159);

// 布尔值
Clog.info('BOOLEAN', true);

// 对象
const userInfo = {
  id: 123,
  name: 'John Doe',
  email: 'john@example.com'
};
Clog.info('OBJECT', userInfo);

// 数组
const items = ['apple', 'banana', 'orange'];
Clog.info('ARRAY', items);

// null 和 undefined
Clog.info('NULL', null);
Clog.info('UNDEFINED', undefined);

// 复杂嵌套对象
const complexData = {
  user: {
    id: 123,
    profile: {
      name: 'John',
      settings: ['theme:dark', 'lang:zh']
    }
  },
  timestamp: Date.now()
};
Clog.info('COMPLEX', complexData);
```

#### 应用场景示例

```typescript
// 应用启动日志
Clog.info('STARTUP', '应用启动', { version: '1.0.0', buildTime: '2024-01-01' });

// 用户操作日志
Clog.info('USER_ACTION', '按钮点击', { buttonId: 'login_btn', timestamp: Date.now() });

// 网络请求日志
Clog.info('HTTP_REQUEST', '发起请求', { url: '/api/users', method: 'GET' });
Clog.info('HTTP_RESPONSE', '请求成功', { status: 200, data: responseData });

// 错误处理日志
try {
  // 一些可能出错的操作
  const result = await someAsyncOperation();
  Clog.info('OPERATION', '操作成功', result);
} catch (error) {
  Clog.error('OPERATION', '操作失败', { error: error.message, stack: error.stack });
}

// 性能监控日志
const startTime = Date.now();
// 执行一些操作
const endTime = Date.now();
Clog.info('PERFORMANCE', '操作耗时', { duration: endTime - startTime, operation: 'data_processing' });
```

### 配置方法（非必须）

#### 应用启动时配置

```typescript
// 在应用启动时配置日志
Clog.setLogDomain(0x1000); // 设置应用专用的日志域
Clog.setPrefix('[MyHarmonyApp]'); // 设置应用专用的日志前缀

// 验证配置
console.log('当前日志域:', Clog.getLogDomain().toString(16));
console.log('当前日志前缀:', Clog.getPrefix());

// 使用配置后的日志
Clog.info('CONFIG', '日志配置完成');
```

## Color Picker 颜色选择器

一个功能强大的ArkTS颜色选择器组件，支持HSB颜色模式、透明度选择和预定义颜色。

### 概述

Color Picker是一个专为HarmonyOS Next开发的颜色选择器组件库，提供直观的颜色选择界面和丰富的自定义选项。组件采用HSB（色相、饱和度、亮度）颜色模式，支持实时颜色预览和多种布局方式。

### 核心特性

- 🎨 **HSB颜色模式**: 基于色相、饱和度、亮度的直观颜色选择
- 🔍 **实时预览**: 拖拽过程中实时显示颜色变化
- 🌈 **透明度支持**: 可选的Alpha通道调节
- 📐 **多种布局**: 支持默认和列式布局
- 🎯 **预定义颜色**: 支持常用颜色快速选择
- 🔧 **高度自定义**: 可自定义圆角、间距、颜色范围等
- 📱 **触摸友好**: 优化的触摸交互体验
- 🎭 **组件化设计**: 模块化组件，易于集成和扩展

### 组件介绍

#### HSBColorPicker
主要的颜色选择器组件，提供完整的颜色选择功能。

#### ColorSlider
可复用的滑块组件，支持水平、垂直和双向滑动。

#### 颜色工具函数
提供HSV、RGB、HEX等颜色格式之间的转换功能。

### 使用示例

#### 基础用法

```typescript
import { HSBColorPicker } from 'kite_utils/color-picker';

@ComponentV2
struct ColorPickerExample {
  @Local selectedColor: string = '#ff0000';

  build() {
    Column() {
      Text(`选中的颜色: ${this.selectedColor}`)
        .fontSize(16)
        .margin({ bottom: 20 })
      
      HSBColorPicker({
        color: this.selectedColor,
        onChange: (color: string) => {
          this.selectedColor = color;
        }
      })
        .height(170)
        .width('100%')
    }
    .padding(20)
  }
}
```

#### 支持透明度选择

```typescript
HSBColorPicker({
  color: this.selectedColor,
  showAlpha: true,
  onChange: (color: string) => {
    this.selectedColor = color;
    console.log('颜色变化:', color);
  }
})
  .height(200)
```

#### 预定义颜色

```typescript
HSBColorPicker({
  color: this.selectedColor,
  predefine: [
    '#ff0000', '#00ff00', '#0000ff',
    '#ffff00', '#ff00ff', '#00ffff',
    '#000000', '#ffffff', '#808080'
  ],
  onChange: (color: string) => {
    this.selectedColor = color;
  }
})
```

#### 列式布局

```typescript
import { HSBColorPickerLayout } from 'kite_utils/color-picker';

HSBColorPicker({
  color: this.selectedColor,
  layout: HSBColorPickerLayout.COLUMN,
  showAlpha: true,
  gutter: 12,
  onChange: (color: string) => {
    this.selectedColor = color;
  }
})
```

### API 文档

#### HSBColorPicker 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| color | string \| null | null | 当前选中的颜色值（HEX格式） |
| radius | number | 0 | 组件圆角半径 |
| gutter | number | 8 | 组件间距 |
| showAlpha | boolean | false | 是否显示透明度选择 |
| layout | HSBColorPickerLayout | DEFAULT | 布局方式 |
| predefine | string[] | [] | 预定义颜色数组 |
| s | [number, number] | [0, 100] | 饱和度范围 |
| b | [number, number] | [0, 100] | 亮度范围 |
| onChange | (value: string) => void | - | 颜色变化回调函数 |

#### HSBColorPickerLayout 枚举

```typescript
export enum HSBColorPickerLayout {
  DEFAULT,  // 默认布局
  COLUMN,   // 列式布局
}
```

#### ColorSlider 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| x | number | 0 | 水平位置（0-1） |
| y | number | 0 | 垂直位置（0-1） |
| slideDirection | SlideDirection | Horizontal | 滑动方向 |
| radius | number | 0 | 滑块圆角 |
| trackLinearGradient | LinearGradient \| null | null | 轨道渐变 |
| trackBackgroundColor | ResourceColor \| null | '#dcdae4' | 轨道背景色 |
| blockSize | number | 16 | 滑块大小 |
| dragStart | (x: number, y: number) => void | - | 拖拽开始回调 |
| dragMove | (x: number, y: number) => void | - | 拖拽移动回调 |
| dragEnd | (x: number, y: number) => void | - | 拖拽结束回调 |
| onChange | (x: number, y: number) => void | - | 位置变化回调 |

### 颜色工具函数

#### HSV ↔ RGB 转换

```typescript
import { hsv2rgb, rgb2hsv } from 'kite_utils/color-picker/utils/color';

// HSV转RGB
const [r, g, b] = hsv2rgb(120, 50, 80); // 色相120°，饱和度50%，亮度80%

// RGB转HSV
const [h, s, v] = rgb2hsv(255, 128, 64);
```

#### RGB ↔ HEX 转换

```typescript
import { rgb2hex, hex2rgb } from 'kite_utils/color-picker/utils/color';

// RGB转HEX
const hexColor = rgb2hex(255, 128, 64); // '#ff8040'

// HEX转RGB
const [r, g, b] = hex2rgb('#ff8040'); // [255, 128, 64]
```

#### HSVA ↔ HEX 转换

```typescript
import { hsva2hex, hex2hsva } from 'kite_utils/color-picker/utils/color';

// HSVA转HEX（带透明度）
const hexColor = hsva2hex(120, 50, 80, 0.8);

// HEX转HSVA
const [h, s, v, a] = hex2hsva('#ff804080');
```

### 高级用法

#### 自定义滑块样式

```typescript
ColorSlider({
  x: this.hueValue,
  slideDirection: SlideDirection.Horizontal,
  trackLinearGradient: {
    angle: 90,
    colors: [
      [Color.Red, 0.0],
      [Color.Yellow, 0.17],
      [Color.Green, 0.33],
      [Color.Cyan, 0.5],
      [Color.Blue, 0.67],
      [Color.Magenta, 0.83],
      [Color.Red, 1.0]
    ]
  },
  blockSize: 20,
  radius: 10,
  onChange: (x: number, y: number) => {
    this.hueValue = x;
  }
})
```

#### 监听拖拽事件

```typescript
HSBColorPicker({
  color: this.selectedColor,
  onChange: (color: string) => {
    this.selectedColor = color;
  },
  dragStart: () => {
    console.log('开始拖拽');
  },
  dragEnd: () => {
    console.log('拖拽结束');
    // 可以在这里保存颜色到本地存储
    this.saveColorToPreferences(this.selectedColor);
  }
})
```

#### 颜色验证和处理

```typescript
import { isValidHex, normalizeColor } from 'kite_utils/color-picker/utils/color';

// 验证颜色格式
if (isValidHex(userInputColor)) {
  this.selectedColor = normalizeColor(userInputColor);
} else {
  console.error('无效的颜色格式');
}
```

#### 响应式颜色选择器

```typescript
@ComponentV2
struct ResponsiveColorPicker {
  @Local selectedColor: string = '#3366cc';
  @Local screenWidth: number = 0;

  build() {
    Column() {
      HSBColorPicker({
        color: this.selectedColor,
        layout: this.screenWidth < 600 ? 
          HSBColorPickerLayout.COLUMN : 
          HSBColorPickerLayout.DEFAULT,
        showAlpha: true,
        gutter: this.screenWidth < 400 ? 4 : 8,
        onChange: (color: string) => {
          this.selectedColor = color;
        }
      })
        .height(this.screenWidth < 600 ? 250 : 200)
    }
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.screenWidth = newValue.width as number;
    })
  }
}
```

Color Picker组件提供了丰富的自定义选项和强大的颜色处理能力，适用于各种需要颜色选择的应用场景。通过合理使用组件参数和工具函数，可以创建出符合应用需求的颜色选择界面。

通过以上配置和使用方式，你可以在HarmonyOS应用中轻松集成强大的日志功能，提高应用的可维护性和调试效率。

本数据库版本升级系统提供了完整、安全、可靠的数据库版本管理解决方案。通过遵循本指南的最佳实践，可以确保数据库升级过程的顺利进行，为应用的持续迭代提供坚实的数据基础。


This project contains code from keke © 2024 KEKE UI, released under the MIT License.


## BreakPoint 断点工具类

根据传入值返回对应的内容

### 使用示例

#### 基础用法

```typescript
import { BreakPoint, Clog } from "kite_utils";
//……
  Clog.log('断电输出',new BreakPoint({
  xs: 100,
  sm: 200,
  md: 300,
  lg: 400
}).getValue('sm'))
//……
```

## WindowUtil 窗口工具

`WindowUtil` 用于统一管理窗口信息，支持安全区、键盘高度、沉浸式模式等场景，适合页面布局避让和窗口状态监听。

常见能力包括：

- 获取顶部和底部安全区信息
- 获取键盘高度变化
- 设置窗口沉浸式模式
- 提供统一的窗口信息对象

## GlobalContext 全局上下文

`GlobalContext` 用于在模块内部统一管理和获取全局上下文，适合在工具类或非组件代码中共享上下文对象。

## UI 组件

模块当前内置以下常用 UI 组件能力：

- `HSBColorPicker` / `ColorSlider`：颜色选择器相关组件与工具方法
- `HdsMiniBarButton`：浮动迷你栏按钮组件
