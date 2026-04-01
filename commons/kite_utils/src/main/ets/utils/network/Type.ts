/**
 * 网络请求相关的类型定义
 * 包含HTTP方法枚举和通用类型定义
 * 
 * @author ZestBox
 * @since 2025-08-09
 */

/**
 * 通用值类型
 * 用于表示任意类型的返回值，通常用于API响应数据
 * 
 * @example
 * ```typescript
 * import { AnyValue } from 'charactech_utils';
 * 
 * function getUserInfo(): Promise<AnyValue> {
 *   return request({ url: '/api/user/info' });
 * }
 * ```
 */
export type AnyValue = any;

/**
 * HTTP请求方法枚举
 * 定义了支持的HTTP请求方法常量
 * 
 * @example
 * ```typescript
 * import { Method, request } from 'charactech_utils';
 * 
 * // 使用枚举值
 * const users = await request({
 *   url: '/api/users',
 *   method: Method.GET
 * });
 * 
 * const newUser = await request({
 *   url: '/api/users',
 *   method: Method.POST,
 *   data: { name: 'John' }
 * });
 * ```
 */
export enum Method {
  /** GET请求方法，用于获取数据 */
  GET = 'get',
  /** POST请求方法，用于创建数据 */
  POST = 'post',
  /** PUT请求方法，用于更新数据 */
  PUT = 'put',
  /** DELETE请求方法，用于删除数据 */
  DELETE = 'delete'
}