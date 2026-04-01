# charactech_utils 高级用法指南

## 在组件中使用

### 完整的组件示例

```arkts
import testApi from '../api/test';
import { setGlobalToken, clearGlobalToken } from 'charactech_utils';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State isLoading: boolean = false;

  aboutToAppear(): void {
    // 应用启动时设置token（如果有的话）
    const savedToken = this.getSavedToken();
    if (savedToken) {
      setGlobalToken(savedToken);
    }
  }

  /**
   * 获取保存的token
   */
  private getSavedToken(): string | null {
    // 这里应该从本地存储中获取token
    return null;
  }

  /**
   * 处理用户登录
   */
  private async handleLogin() {
    try {
      this.isLoading = true;
      // 假设这是登录接口
      const loginResult = await testApi.login('username', 'password');
      
      // 登录成功后设置token
      setGlobalToken(loginResult.token);
      
      // 保存token到本地存储
      this.saveToken(loginResult.token);
      
      this.message = '登录成功';
    } catch (error) {
      console.error('登录失败:', error.message);
      this.message = '登录失败: ' + error.message;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 处理用户退出
   */
  private handleLogout() {
    clearGlobalToken();
    this.clearSavedToken();
    this.message = '已退出登录';
  }

  /**
   * 处理API调用
   */
  private async handleApiCall() {
    try {
      this.isLoading = true;
      this.message = '正在获取数据...';
      
      const result = await testApi.getJokes();
      console.log('获取笑话成功:', JSON.stringify(result));
      this.message = '获取数据成功';
    } catch (error) {
      console.error('获取笑话失败:', error.message);
      this.message = '获取数据失败: ' + error.message;
    } finally {
      this.isLoading = false;
    }
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
          this.handleApiCall();
        })
    }
    .height('100%')
    .width('100%')
  }
}
```

## Token管理最佳实践

### 登录和Token设置

```typescript
import { setGlobalToken, clearGlobalToken, request, Method } from 'charactech_utils';

class AuthService {
  /**
   * 用户登录
   */
  static async login(username: string, password: string) {
    try {
      const result = await request({
        url: '/auth/login',
        method: Method.POST,
        data: { username, password }
      });
      
      // 设置全局token
      setGlobalToken(result.token);
      
      // 保存到本地存储
      this.saveTokenToLocal(result.token);
      
      return result;
    } catch (error) {
      throw error;
    }
  }

  /**
   * 用户退出
   */
  static logout() {
    clearGlobalToken();
    this.clearTokenFromLocal();
  }

  /**
   * 检查token是否有效
   */
  static async checkTokenValid(): Promise<boolean> {
    try {
      await request({
        url: '/auth/check',
        method: Method.GET
      });
      return true;
    } catch (error) {
      // token无效，清空
      clearGlobalToken();
      this.clearTokenFromLocal();
      return false;
    }
  }

  /**
   * 保存token到本地存储
   */
  private static saveTokenToLocal(token: string) {
    // 实现本地存储逻辑
  }

  /**
   * 从本地存储清空token
   */
  private static clearTokenFromLocal() {
    // 实现清空逻辑
  }
}
```

## 错误处理策略

### 统一错误处理

```typescript
class ApiErrorHandler {
  /**
   * 统一的API调用包装器
   */
  static async safeApiCall<T>(apiCall: () => Promise<T>): Promise<T> {
    try {
      return await apiCall();
    } catch (error) {
      this.handleError(error);
      throw error;
    }
  }

  /**
   * 错误处理逻辑
   */
  private static handleError(error: Error) {
    const message = error.message;

    if (message.includes('token') || message.includes('401')) {
      // 认证失败
      console.error('认证失败，请重新登录');
      clearGlobalToken();
      // 跳转到登录页面
      this.redirectToLogin();
    } else if (message.includes('网络') || message.includes('timeout')) {
      // 网络错误
      console.error('网络连接失败，请检查网络');
      this.showNetworkError();
    } else if (message.includes('500')) {
      // 服务器错误
      console.error('服务器错误，请稍后重试');
      this.showServerError();
    } else {
      // 其他业务错误
      console.error('请求失败:', message);
      this.showBusinessError(message);
    }
  }

  private static redirectToLogin() {
    // 实现跳转到登录页面的逻辑
  }

  private static showNetworkError() {
    // 显示网络错误提示
  }

  private static showServerError() {
    // 显示服务器错误提示
  }

  private static showBusinessError(message: string) {
    // 显示业务错误提示
  }
}

// 使用示例
async function getUserInfo() {
  return ApiErrorHandler.safeApiCall(async () => {
    return await request({
      url: '/user/info',
      method: Method.GET
    });
  });
}
```

## 请求封装和拦截

### 自定义请求封装

```typescript
import { request, Method } from 'charactech_utils';

class ApiService {
  /**
   * 带有通用处理的请求函数
   */
  static async apiRequest(options: any) {
    // 请求前处理
    console.log('发起请求:', options.url);
    this.showLoading();

    try {
      const result = await request(options);
      
      // 响应后处理
      console.log('请求成功:', options.url);
      this.hideLoading();
      
      return result;
    } catch (error) {
      // 统一错误处理
      console.error('请求失败:', options.url, error.message);
      this.hideLoading();
      
      // 可以在这里添加错误上报、重试逻辑等
      this.reportError(options.url, error);
      
      throw error;
    }
  }

  /**
   * GET请求封装
   */
  static get(url: string, params?: any, options?: any) {
    return this.apiRequest({
      url,
      method: Method.GET,
      data: params,
      ...options
    });
  }

  /**
   * POST请求封装
   */
  static post(url: string, data?: any, options?: any) {
    return this.apiRequest({
      url,
      method: Method.POST,
      data,
      ...options
    });
  }

  /**
   * PUT请求封装
   */
  static put(url: string, data?: any, options?: any) {
    return this.apiRequest({
      url,
      method: Method.PUT,
      data,
      ...options
    });
  }

  /**
   * DELETE请求封装
   */
  static delete(url: string, params?: any, options?: any) {
    return this.apiRequest({
      url,
      method: Method.DELETE,
      data: params,
      ...options
    });
  }

  private static showLoading() {
    // 显示加载状态
  }

  private static hideLoading() {
    // 隐藏加载状态
  }

  private static reportError(url: string, error: Error) {
    // 错误上报逻辑
  }
}

// 使用示例
const userList = await ApiService.get('/users', { page: 1, size: 10 });
const newUser = await ApiService.post('/users', { name: 'John', email: 'john@example.com' });
```

## 文件上传最佳实践

### 完整的文件上传流程

```typescript
import { request, Method } from 'charactech_utils';
import { rcp } from '@kit.RemoteCommunicationKit';
import { picker, fileIo as fs } from '@kit.CoreFileKit';

class FileUploadService {
  /**
   * 选择并上传图片
   */
  static async selectAndUploadImage(): Promise<any> {
    try {
      // 1. 选择文件
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      
      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      
      if (photoSelectResult.photoUris.length === 0) {
        throw new Error('未选择文件');
      }

      // 2. 准备文件上传
      const fileUri = photoSelectResult.photoUris[0];
      return await this.uploadFile(fileUri, 'image');
    } catch (error) {
      console.error('文件上传失败:', error);
      throw error;
    }
  }

  /**
   * 上传文件的通用方法
   */
  static async uploadFile(fileUri: string, fileType: 'image' | 'document'): Promise<any> {
    try {
      // 1. 获取应用上下文
      const context = getContext();
      
      // 2. 生成新的文件名
      const fileExtension = this.getFileExtension(fileUri);
      const fileName = `${Date.now()}.${fileExtension}`;
      
      // 3. 拷贝文件到缓存目录
      const copyFilePath = `${context.cacheDir}/${fileName}`;
      const file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
      fs.copyFileSync(file.fd, copyFilePath);
      fs.closeSync(file);

      // 4. 准备上传数据
      const formFieldFileValue: rcp.FormFieldFileValue = {
        contentType: this.getContentType(fileExtension),
        remoteFileName: fileName,
        contentOrPath: copyFilePath,
      };

      const formData = new rcp.MultipartForm({
        'file': formFieldFileValue,
        'type': fileType
      });

      // 5. 上传文件
      const result = await request({
        url: '/upload',
        method: Method.POST,
        headers: {
          'Content-Type': 'multipart/form-data'
        },
        data: formData,
        readTimeout: 30000, // 30秒超时
        connectTimeout: 10000
      });

      // 6. 清理临时文件
      try {
        fs.unlinkSync(copyFilePath);
      } catch (cleanupError) {
        console.warn('清理临时文件失败:', cleanupError);
      }

      return result;
    } catch (error) {
      console.error('文件上传失败:', error);
      throw error;
    }
  }

  /**
   * 获取文件扩展名
   */
  private static getFileExtension(fileUri: string): string {
    const lastDotIndex = fileUri.lastIndexOf('.');
    return lastDotIndex > -1 ? fileUri.substring(lastDotIndex + 1) : 'jpg';
  }

  /**
   * 根据文件扩展名获取Content-Type
   */
  private static getContentType(extension: string): string {
    const contentTypes: Record<string, string> = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    };
    
    return contentTypes[extension.toLowerCase()] || 'application/octet-stream';
  }
}
```

## 性能优化建议

### 请求缓存

```typescript
class CacheService {
  private static cache = new Map<string, { data: any, timestamp: number }>();
  private static readonly CACHE_DURATION = 5 * 60 * 1000; // 5分钟

  /**
   * 带缓存的请求
   */
  static async cachedRequest(options: any, cacheKey?: string): Promise<any> {
    const key = cacheKey || this.generateCacheKey(options);
    
    // 检查缓存
    const cached = this.cache.get(key);
    if (cached && Date.now() - cached.timestamp < this.CACHE_DURATION) {
      console.log('使用缓存数据:', key);
      return cached.data;
    }

    // 发起请求
    try {
      const result = await request(options);
      
      // 缓存结果
      this.cache.set(key, {
        data: result,
        timestamp: Date.now()
      });
      
      return result;
    } catch (error) {
      throw error;
    }
  }

  /**
   * 清空缓存
   */
  static clearCache() {
    this.cache.clear();
  }

  /**
   * 生成缓存键
   */
  private static generateCacheKey(options: any): string {
    return `${options.method || 'get'}_${options.url}_${JSON.stringify(options.data || {})}`;
  }
}
```

## 调试和日志

### 请求日志记录

```typescript
class RequestLogger {
  private static logs: any[] = [];

  /**
   * 记录请求日志
   */
  static logRequest(options: any, result?: any, error?: Error) {
    const log = {
      timestamp: new Date().toISOString(),
      url: options.url,
      method: options.method || 'get',
      data: options.data,
      success: !error,
      result: result,
      error: error?.message,
      duration: 0 // 可以添加计时逻辑
    };

    this.logs.push(log);
    
    // 保持最近100条日志
    if (this.logs.length > 100) {
      this.logs.shift();
    }

    // 输出到控制台
    if (error) {
      console.error('API请求失败:', log);
    } else {
      console.log('API请求成功:', log);
    }
  }

  /**
   * 获取所有日志
   */
  static getLogs() {
    return [...this.logs];
  }

  /**
   * 清空日志
   */
  static clearLogs() {
    this.logs = [];
  }
}
```

这些高级用法和最佳实践可以帮助你更好地使用charactech_utils网络请求工具包，提高代码质量和用户体验。