import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/status_model.dart';
import '../models/pair_model.dart';
import 'usage_stats_service.dart';

/// 自建服务器的实时状态服务
class RealtimeStatusService {
  static final RealtimeStatusService _instance = RealtimeStatusService._();
  factory RealtimeStatusService() => _instance;
  RealtimeStatusService._();

  static const _pairKey = 'pair_data';
  static const _serverUrlKey = 'server_url';
  static const _defaultBaseUrl = 'http://10.0.2.2:3000';
  static const _reportInterval = Duration(seconds: 10);

  final _usageStats = UsageStatsService();
  late final Dio _dio;
  WebSocketChannel? _wsChannel;
  final _partnerStatusController = StreamController<StatusModel?>.broadcast();
  Timer? _reconnectTimer;
  Timer? _reportTimer;
  bool _initialized = false;
  String _baseUrl = _defaultBaseUrl;
  String? _lastReportedPackage;

  Stream<StatusModel?> get partnerStatusStream => _partnerStatusController.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_serverUrlKey) ?? _defaultBaseUrl;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  /// 设置服务器地址
  Future<void> setServerUrl(String url) async {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    _dio.options.baseUrl = _baseUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, _baseUrl);
    // 如果已登录，重新连接
    final pair = await getPairInfo();
    if (pair != null && pair.isPaired) {
      await _disconnectWs();
      _connectWs(pair.myId);
    }
  }

  /// 获取当前服务器地址
  Future<String> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey) ?? _defaultBaseUrl;
  }

  /// 获取本地保存的登录信息
  Future<PairModel?> getPairInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pairKey);
    if (raw == null) return null;
    return PairModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _savePairInfo(PairModel pair) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pairKey, jsonEncode(pair.toJson()));
  }

  /// 检查使用情况访问权限
  Future<bool> hasUsagePermission() => _usageStats.hasPermission();

  /// 请求使用情况访问权限
  Future<void> requestUsagePermission() => _usageStats.requestPermission();

  /// 用用户ID登录服务器验证身份
  Future<bool> login(String userId) async {
    await init();
    try {
      final response = await _dio.post('/api/login', data: {
        'userId': userId,
      });

      if (response.statusCode == 200) {
        final partnerId = response.data['partnerId'] as String;
        final pair = PairModel(myId: userId, partnerId: partnerId);
        await _savePairInfo(pair);
        _connectWs(userId);
        _startReporting();
        return true;
      }
      return false;
    } on DioException {
      return false;
    }
  }

  /// 上报当前前台应用
  Future<void> _reportCurrentApp() async {
    final pair = await getPairInfo();
    if (pair == null || !pair.isPaired) return;

    final appInfo = await _usageStats.getForegroundApp();
    if (appInfo == null) return;

    final packageName = appInfo['packageName']!;
    if (packageName == _lastReportedPackage) return;
    _lastReportedPackage = packageName;

    final status = StatusModel(
      userId: pair.myId,
      packageName: packageName,
      appName: appInfo['appName']!,
      updatedAt: DateTime.now(),
    );

    try {
      await _dio.post('/api/status/update', data: status.toJson());
    } on DioException {
      // 网络失败静默忽略
    }
  }

  void _startReporting() {
    _reportTimer?.cancel();
    _reportTimer = Timer.periodic(_reportInterval, (_) => _reportCurrentApp());
    _reportCurrentApp();
  }

  void _stopReporting() {
    _reportTimer?.cancel();
    _reportTimer = null;
  }

  void _connectWs(String userId) {
    _disconnectWs();
    final wsUrl = _baseUrl.replaceFirst('http', 'ws');
    try {
      _wsChannel = WebSocketChannel.connect(
        Uri.parse('$wsUrl/ws?userId=$userId'),
      );
      _wsChannel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            if (json['type'] == 'status_update') {
              final status = StatusModel.fromJson(
                Map<String, dynamic>.from(json['data'] as Map),
              );
              _partnerStatusController.add(status);
            }
          } catch (_) {}
        },
        onDone: () => _scheduleReconnect(userId),
        onError: (_) => _scheduleReconnect(userId),
      );
    } catch (_) {
      _scheduleReconnect(userId);
    }
  }

  void _scheduleReconnect(String userId) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _connectWs(userId);
    });
  }

  Future<void> _disconnectWs() async {
    _reconnectTimer?.cancel();
    await _wsChannel?.sink.close();
    _wsChannel = null;
  }

  /// 启动（已登录状态下调用）
  Future<void> startListening() async {
    await init();
    final pair = await getPairInfo();
    if (pair != null && pair.isPaired) {
      _connectWs(pair.myId);
      _startReporting();
    }
  }

  /// 登出
  Future<void> logout() async {
    _stopReporting();
    await _disconnectWs();
    _lastReportedPackage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pairKey);
    _partnerStatusController.add(null);
  }

  void dispose() {
    _stopReporting();
    _disconnectWs();
    _partnerStatusController.close();
  }
}
