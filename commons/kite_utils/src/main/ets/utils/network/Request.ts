/**
 * 网络请求工具类
 * 提供统一的HTTP请求封装，支持GET、POST、PUT、DELETE等方法
 * 支持全局token管理、请求头自定义、超时设置等功能
 *
 * @author ZestBox
 * @since 2025-08-09
 */

import http from '@ohos.net.http';


const TAG: string = '[network]';

/**
 * 全局API基础地址
 */
let baseApi = ''

/**
 * 初始化网络请求配置
 * 设置全局的API基础地址，所有请求都会以此为前缀
 *
 * @param inputBaseApi API基础地址，例如: 'https://api.example.com'
 * @example
* ```typescript
 * initRequest('https://api.example.com');
 * ```
 */
export function initRequest(inputBaseApi: string) {
  baseApi = inputBaseApi;
}

/**
 * 获取当前使用的 API 基础地址
 * @returns 当前设置的 baseApi 值
 * @example
* ```typescript
 * const apiUrl = getBaseApi(); // 返回 'https://api.example.com'
 * ```
 */
export function getBaseApi(): string {
  if (typeof baseApi === 'undefined') {
    throw new Error('baseApi 尚未初始化，请先调用 initRequest()');
  }
  return baseApi;
}

/**
 * HTTP请求头管理类
 * 用于管理请求头信息，包括Content-Type和Token等
 */
class Header {
  /** 内容类型，默认为application/json */
  public contentType: string;
  /** 认证token，可选 */
  public token?: string;

  /**
   * 构造函数
   * @param contentType 内容类型，默认为'application/json'
   */
  constructor(contentType: string = 'application/json') {
    this.contentType = contentType;
  }

  /**
   * 设置认证token
   * @param token 认证token字符串
   * @example
  * ```typescript
   * header.setToken('your-auth-token');
   * ```
   */
  setToken(token: string) {
    this.token = token;
  }

  /**
   * 将Header对象转换为普通对象
   * @returns 包含所有请求头的对象
   * @example
  * ```typescript
   * const headers = header.toObject();
   * // 返回: { 'Content-Type': 'application/json', 'token': 'your-token' }
   * ```
   */
  toObject(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': this.contentType
    };
    if (this.token && this.token.trim().length > 0) {
      headers['Authorization'] = `Bearer ${this.token}`;
      headers['token'] = this.token;
    }
    return headers;
  }
}


/**
 * HTTP请求服务类
 * 封装了HTTP请求的核心逻辑，提供统一的请求接口
 * 支持GET、POST、PUT、DELETE等HTTP方法
 */
class HttpService {
  /** HTTP请求对象 */
  private httpObj: http.HttpRequest;
  /** 请求头管理对象 */
  private header: Header;

  /**
   * 构造函数
   * 初始化HTTP请求对象和请求头管理对象
   */
  constructor() {
    this.httpObj = http.createHttp();
    this.header = new Header();
  }

  /**
   * 设置全局认证token
   * @param token 认证token字符串
   * @example
  * ```typescript
   * httpService.setToken('your-auth-token');
   * ```
   */
  setToken(token: string) {
    this.header.setToken(token);
  }

  /**
   * 构建完整的请求URL
   * 将基础API地址与路径拼接，并处理查询参数
   *
   * @param path API路径，例如: '/api/users'
   * @param params 查询参数对象，可选
   * @returns 完整的请求URL
   * @example
  * ```typescript
   * // 基础用法
   * buildUrl('/api/users'); // 返回: 'https://api.example.com/api/users'
   *
   * // 带参数
   * buildUrl('/api/users', { page: 1, size: 10 }); 
   * // 返回: 'https://api.example.com/api/users?page=1&size=10'
   * ```
   */
  private buildUrl(path: string, params?: Record<string, any>): string {
    let url = `${baseApi}${path}`;

    if (params) {
      const queryParams: string[] = [];
      Object.keys(params).forEach(key => {
        const value = params[key];
        if (value !== null && value !== undefined) {
          queryParams.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
        }
      });
      if (queryParams.length > 0) {
        url += `?${queryParams.join('&')}`;
      }
    }

    return url;
  }

  /**
   * 处理HTTP响应
   * 解析响应数据，根据业务状态码判断请求是否成功
   *
   * @param response HTTP响应对象
   * @param originalOptions 原始请求选项，用于错误处理时的上下文信息
   * @returns 解析后的响应数据
   * @throws {Error} 当业务状态码表示失败时抛出错误
   *
   * @example
  * 期望的响应格式:
   * ```json
   * {
   *   "code": 200,
   *   "message": "success",
   *   "data": { ... }
   * }
   * ```
   */
  private async handleResponse(response: http.HttpResponse, originalOptions?: any): Promise<any> {
    try {
      const result = JSON.parse(response.result as string);
      const { code, message, data } = result;

      if (code === 1 || code === 200) {
        return data;
      } else {
        // 这里应该记录错误msg到日志文件
        throw new Error(message); // 主动抛出携带业务信息的异常
      }
    } catch (error) {
      throw error;
    }
  }


  /**
   * 发起HTTP请求的核心方法
   * 支持GET、POST、PUT、DELETE等HTTP方法
   *
   * @param options 请求配置对象
   * @param options.url 请求路径，相对于baseApi
   * @param options.method 请求方法，默认为'get'，支持: 'get' | 'post' | 'put' | 'delete'
   * @param options.data 请求数据，GET请求时作为查询参数，其他请求时作为请求体
   * @param options.headers 自定义请求头，会与全局请求头合并
   * @param options.readTimeout 读取超时时间，单位毫秒
   * @param options.connectTimeout 连接超时时间，单位毫秒
   * @returns Promise<any> 返回解析后的响应数据
   *
   * @example
  * ```typescript
   * // GET请求
   * const result = await request({
   *   url: '/api/users',
   *   method: 'get',
   *   data: { page: 1, size: 10 }
   * });
   *
   * // POST请求
   * const result = await request({
   *   url: '/api/users',
   *   method: 'post',
   *   data: { name: 'John', email: 'john@example.com' },
   *   readTimeout: 5000
   * });
   * ```
   */
  async request(options: any): Promise<any> {
    const { url, method = 'get', data, headers, readTimeout, connectTimeout } = options;

    try {
      // 合并自定义headers
      const requestHeaders = { ...this.header.toObject(), ...headers };

      let requestOptions: http.HttpRequestOptions = {
        method: method.toLowerCase() === 'get' ? http.RequestMethod.GET :
          method.toLowerCase() === 'post' ? http.RequestMethod.POST :
            method.toLowerCase() === 'put' ? http.RequestMethod.PUT :
              http.RequestMethod.DELETE,
        header: requestHeaders
      };
      if (readTimeout) {
        requestOptions.readTimeout = readTimeout
      }
      if (connectTimeout) {
        requestOptions.connectTimeout = connectTimeout
      }

      let finalUrl: string;

      // 处理GET请求 - 参数放在URL中
      if (method.toLowerCase() === 'get') {
        finalUrl = this.buildUrl(url, data);
      } else {
        // 处理POST/PUT/DELETE请求 - 参数放在body中
        finalUrl = `${baseApi}${url}`;
        if (data) {
          requestOptions.extraData = JSON.stringify(data);
        }
      }

      const response = await this.httpObj.request(finalUrl, requestOptions);
      return this.handleResponse(response, options);
    } catch (error) {
      console.error(TAG, '请求失败:', error);
      throw error;
    }
  }
}

/**
 * HTTP服务单例实例
 * 全局共享的HTTP请求服务对象
 */
const service = new HttpService();

/**
 * 发起HTTP请求的便捷函数
 * 这是对外暴露的主要请求接口，内部使用HttpService实例
 *
 * @param options 请求配置对象
 * @param options.url 请求路径，相对于baseApi
 * @param options.method 请求方法，默认为'get'
 * @param options.data 请求数据
 * @param options.headers 自定义请求头
 * @param options.readTimeout 读取超时时间
 * @param options.connectTimeout 连接超时时间
 * @returns Promise<any> 返回解析后的响应数据
 *
 * @author ZestBox
 * @since 2025-08-09
 */
export function request(options: any) {
  // 默认method为get，与JS版本保持一致
  options.method = options.method || 'get';

  // 如果是get请求且有data，转换为params（兼容JS版本的写法）
  if (options.method.toLowerCase() === 'get' && options.data) {
    options.params = options.data;
  }

  return service.request(options);
}

/**
 * 设置全局认证token
 * 设置后，所有请求都会自动携带此token
 *
 * @param token 认证token字符串
 * @example
* ```typescript
 * import { setGlobalToken } from 'charactech_utils';
 *
 * // 用户登录后设置token
 * setGlobalToken('your-auth-token-here');
 *
 * // 之后的所有请求都会自动携带此token
 * const userInfo = await request({
 *   url: '/api/user/info',
 *   method: 'get'
 * });
 * ```
 */
export function setGlobalToken(token: string) {
  service.setToken(token);
}

/**
 * 清空全局认证token
 * 通常在用户退出登录时调用
 *
 * @example
* ```typescript
 * import { clearGlobalToken } from 'charactech_utils';
 *
 * // 用户退出登录时清空token
 * clearGlobalToken();
 * ```
 */
export function clearGlobalToken() {
  service.setToken('');
}
