import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/status_model.dart';
import '../models/pair_model.dart';
import '../services/realtime_status_service.dart';

final realtimeStatusServiceProvider = Provider((_) => RealtimeStatusService());

/// 登录状态 Provider
final pairProvider = AsyncNotifierProvider<PairNotifier, PairModel?>(PairNotifier.new);

class PairNotifier extends AsyncNotifier<PairModel?> {
  late final RealtimeStatusService _service;

  @override
  Future<PairModel?> build() async {
    _service = ref.read(realtimeStatusServiceProvider);
    await _service.init();
    final pair = await _service.getPairInfo();
    if (pair != null && pair.isPaired) {
      await _service.startListening();
    }
    return pair;
  }

  /// 用户ID登录
  Future<bool> login(String userId) async {
    final success = await _service.login(userId);
    if (success) {
      state = AsyncData(await _service.getPairInfo());
    }
    return success;
  }

  /// 登出
  Future<void> logout() async {
    await _service.logout();
    state = const AsyncData(null);
  }
}

/// 对方状态 Provider (实时流)
final partnerStatusProvider = StreamProvider<StatusModel?>((ref) {
  final service = ref.read(realtimeStatusServiceProvider);
  return service.partnerStatusStream;
});

/// 使用情况访问权限 Provider
final usagePermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(realtimeStatusServiceProvider);
  return service.hasUsagePermission();
});
