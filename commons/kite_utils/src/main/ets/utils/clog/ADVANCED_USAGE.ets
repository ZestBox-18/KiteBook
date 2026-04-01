/**
 * @ author ZestBox
 * @ since 2025-09-10
 */
import { Clog } from './Clog';


/**
 * Clog配置功能测试
 */
export function ADVANCED_USAGE(): void {
  console.log('=== Clog配置功能测试开始 ===');

  // 测试默认配置
  console.log('默认日志域:', Clog.getLogDomain().toString(16)); // 输出十六进制
  console.log('默认日志前缀:', Clog.getPrefix());

  // 使用默认配置记录日志
  Clog.info('TEST', '使用默认配置的日志');

  // 测试自定义日志域
  Clog.setLogDomain(0x1234);
  console.log('设置后的日志域:', Clog.getLogDomain().toString(16));
  Clog.info('TEST', '使用自定义日志域的日志');

  // 测试自定义日志前缀
  Clog.setPrefix('[MyApp]');
  console.log('设置后的日志前缀:', Clog.getPrefix());
  Clog.info('TEST', '使用自定义前缀的日志');

  // 测试同时自定义日志域和前缀
  Clog.setLogDomain(0x5678);
  Clog.setPrefix('[CustomApp]');
  console.log('最终日志域:', Clog.getLogDomain().toString(16));
  console.log('最终日志前缀:', Clog.getPrefix());
  Clog.info('TEST', '使用完全自定义配置的日志');

  // 测试不同日志级别
  Clog.warn('TEST', '警告日志测试');
  Clog.error('TEST', '错误日志测试');
  Clog.log('TEST', '普通日志测试');

  // 测试多参数日志
  Clog.info('TEST', '第一个参数', '第二个参数');

  // 恢复默认配置
  Clog.setLogDomain(0x0fff);
  Clog.setPrefix('[Charactech]');
  Clog.info('TEST', '恢复默认配置后的日志');

  console.log('=== Clog配置功能测试结束 ===');
}

/**
 * 配置使用示例
 */
export function clogConfigurationExample(): void {
  console.log('=== Clog配置使用示例 ===');

  // 应用启动时配置日志
  Clog.setLogDomain(0x1000); // 设置应用专用的日志域
  Clog.setPrefix('[MyHarmonyApp]'); // 设置应用专用的日志前缀

  // 正常使用日志功能
  Clog.info('STARTUP', '应用启动完成');

  const users: Record<string, string> = {
    'name': '张三',
    'age': '30'
  }
  Clog.info('USER', '用户登录', users);
  Clog.warn('NETWORK', '网络连接不稳定');
  const errorCode: Record<string, number> = {
    'errorCode': 500,
  }
  Clog.error('DATABASE', '数据库连接失败', errorCode);

  console.log('当前配置 - 日志域:', Clog.getLogDomain().toString(16), '前缀:', Clog.getPrefix());
}