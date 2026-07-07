import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/status_model.dart';
import '../providers/status_provider.dart';

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  final _userIdController = TextEditingController();
  bool _loggingIn = false;
  String? _loginError;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pairAsync = ref.watch(pairProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _StatusBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: pairAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF9500)),
                    ),
                    error: (e, _) => Center(
                      child: Text('加载失败: $e',
                          style: const TextStyle(color: Color(0xFF8B5E3C))),
                    ),
                    data: (pair) {
                      if (pair == null || !pair.isPaired) {
                        return _buildLoginView();
                      }
                      return _buildStatusView(pair);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Text(
            'TA在干嘛',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8B5E3C),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF8B5E3C), size: 22),
            onPressed: _showServerSettings,
          ),
        ],
      ),
    );
  }

  // === 登录界面 ===

  Widget _buildLoginView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.favorite, size: 50, color: Color(0xFFFF9500)),
          ),
          const SizedBox(height: 24),
          Text(
            '连接TA',
            style: GoogleFonts.inter(
              fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF8B5E3C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '输入你的用户ID开始',
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFB08060)),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('用户ID', style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8B5E3C),
                )),
                const SizedBox(height: 10),
                TextField(
                  controller: _userIdController,
                  enabled: !_loggingIn,
                  style: GoogleFonts.inter(
                    fontSize: 16, color: const Color(0xFF8B5E3C),
                  ),
                  decoration: InputDecoration(
                    hintText: '例如：alice',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFFCCAA80)),
                    filled: true,
                    fillColor: const Color(0xFFF5EDD8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFB08060)),
                  ),
                ),
                if (_loginError != null) ...[
                  const SizedBox(height: 12),
                  Text(_loginError!, style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.redAccent,
                  )),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loggingIn ? null : _doLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9500),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _loggingIn
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : Text('登 录', style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w600,
                          )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDD8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18, color: Color(0xFFB08060)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '首次使用请让服务端管理员预先登记配对关系。\n'
                    '例：curl -X POST http://server/api/admin/pair -d \'{"user1":"alice","user2":"bob"}\'',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFB08060)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogin() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() => _loginError = '请输入用户ID');
      return;
    }
    setState(() {
      _loggingIn = true;
      _loginError = null;
    });
    final success = await ref.read(pairProvider.notifier).login(userId);
    if (!mounted) return;
    setState(() {
      _loggingIn = false;
      if (!success) _loginError = '登录失败：用户ID未登记或服务器不可达';
    });
  }

  // === 状态展示界面 ===

  Widget _buildStatusView(dynamic pair) {
    final partnerStatus = ref.watch(partnerStatusProvider);
    final hasPermission = ref.watch(usagePermissionProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          // 权限提示
          hasPermission.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (granted) {
              if (granted) return const SizedBox.shrink();
              return _buildPermissionBanner();
            },
          ),
          // 对方状态卡片
          _buildPartnerCard(partnerStatus),
          const SizedBox(height: 20),
          // 用户信息 + 退出
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 16, color: Color(0xFFB08060)),
                const SizedBox(width: 8),
                Text(pair.myId, style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF8B5E3C), fontWeight: FontWeight.w500,
                )),
                const Spacer(),
                TextButton(
                  onPressed: _confirmLogout,
                  child: Text('退出', style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFFB08060),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9500).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFFFF9500), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('需要使用情况访问权限', style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF8B5E3C),
                )),
                const SizedBox(height: 4),
                Text('用于获取当前正在使用的App并同步给对方', style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFFB08060),
                )),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final service = ref.read(realtimeStatusServiceProvider);
              await service.requestUsagePermission();
              ref.invalidate(usagePermissionProvider);
            },
            child: Text('授权', style: GoogleFonts.inter(
              color: const Color(0xFFFF9500), fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(AsyncValue<StatusModel?> partnerStatus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('TA正在用', style: GoogleFonts.inter(
            fontSize: 14, color: const Color(0xFFB08060),
          )),
          const SizedBox(height: 20),
          partnerStatus.when(
            loading: () => Column(
              children: [
                const CircularProgressIndicator(color: Color(0xFFFF9500)),
                const SizedBox(height: 12),
                Text('正在连接...', style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFFB08060),
                )),
              ],
            ),
            error: (e, st) => Column(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('连接中断', style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF8B5E3C),
                )),
                const SizedBox(height: 4),
                Text('等待重新连接...', style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFFB08060),
                )),
              ],
            ),
            data: (status) {
              if (status == null) {
                return Column(
                  children: [
                    const Text('😴', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text('暂无数据', style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF8B5E3C),
                    )),
                    const SizedBox(height: 6),
                    Text('等待对方上线~', style: GoogleFonts.inter(
                      fontSize: 14, color: const Color(0xFFB08060),
                    )),
                  ],
                );
              }
              return Column(
                children: [
                  Text(status.icon, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(status.appName, style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF8B5E3C),
                  )),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EDD8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.packageName,
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFB08060)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(_formatTime(status.updatedAt), style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFFCCAA80),
                      )),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF8F0E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('退出登录', style: GoogleFonts.inter(
          color: const Color(0xFF8B5E3C), fontWeight: FontWeight.w700,
        )),
        content: Text('退出后需要重新输入用户ID', style: GoogleFonts.inter(
          color: const Color(0xFFB08060),
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('取消', style: GoogleFonts.inter(color: const Color(0xFF8B5E3C))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('确定', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(pairProvider.notifier).logout();
    }
  }

  // === 工具方法 ===

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 30) return '实时';
    if (diff.inMinutes < 1) return '${diff.inSeconds}秒前';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }

  Future<void> _showServerSettings() async {
    final service = ref.read(realtimeStatusServiceProvider);
    final currentUrl = await service.getServerUrl();
    final urlController = TextEditingController(text: currentUrl);

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF8F0E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('服务器设置', style: GoogleFonts.inter(
          color: const Color(0xFF8B5E3C), fontWeight: FontWeight.w700,
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('服务器地址', style: GoogleFonts.inter(
              fontSize: 13, color: const Color(0xFFB08060),
            )),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8B5E3C)),
              decoration: InputDecoration(
                hintText: 'http://your-server:3000',
                hintStyle: GoogleFonts.inter(color: const Color(0xFFCCAA80)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDDC898)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: GoogleFonts.inter(color: const Color(0xFF8B5E3C))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9500),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await service.setServerUrl(urlController.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('服务器地址已更新')),
                );
              }
            },
            child: Text('保存', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    urlController.dispose();
  }
}

/// 温暖渐变背景
class _StatusBackground extends StatelessWidget {
  const _StatusBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8D5B0),
            Color(0xFFD4BC90),
            Color(0xFFEAD8B5),
            Color(0xFFC8A878),
          ],
        ),
      ),
    );
  }
}
