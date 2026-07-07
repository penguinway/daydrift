import 'dart:async';
import 'package:flutter/services.dart';

/// 通过 MethodChannel 调用原生 UsageStats API
class UsageStatsService {
  static const _channel = MethodChannel('com.ufomiao.love_time/usage_stats');

  /// 获取当前前台应用信息
  /// 返回 { "packageName": "...", "appName": "..." } 或 null
  Future<Map<String, String>?> getForegroundApp() async {
    try {
      final result = await _channel.invokeMapMethod<String, String>('getForegroundApp');
      return result;
    } on PlatformException {
      return null;
    }
  }

  /// 检查是否有使用情况访问权限
  Future<bool> hasPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasUsagePermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 跳转到使用情况访问权限设置页
  Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } on PlatformException {
      // ignore
    }
  }
}
