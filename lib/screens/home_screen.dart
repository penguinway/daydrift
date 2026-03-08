import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import 'add_edit_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 浅色木纹背景
          const _WoodBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody(eventsAsync, ref)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditScreen()),
        ),
        backgroundColor: const Color(0xFFFF9500),
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        '时光',
        style: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF8B5E3C),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildBody(AsyncValue eventsAsync, WidgetRef ref) {
    return eventsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF9500)),
      ),
      error: (e, _) => Center(
        child: Text('加载失败: $e', style: const TextStyle(color: Color(0xFF8B5E3C))),
      ),
      data: (events) {
        if (events.isEmpty) return _buildEmpty();
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: events.length,
          itemBuilder: (ctx, i) => EventCard(
            event: events[i],
            onEdit: () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => AddEditScreen(event: events[i])),
            ),
            onDelete: () =>
                ref.read(eventsProvider.notifier).deleteEvent(events[i].id),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.calendar_today, size: 40, color: Color(0xFFFF9500)),
          ),
          const SizedBox(height: 20),
          Text(
            '还没有记录',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: const Color(0xFF8B5E3C),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击 + 添加一个特殊的日子',
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFB08060)),
          ),
        ],
      ),
    );
  }
}

/// 浅色木纹背景
class _WoodBackground extends StatelessWidget {
  const _WoodBackground();

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
            Color(0xFFDDC898),
            Color(0xFFE8D5B0),
          ],
          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
        ),
      ),
      child: CustomPaint(painter: _WoodGrainPainter()),
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 浅色木纹纹理
    final paint = Paint()
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 60; i++) {
      final t = i / 60;
      final y = size.height * t;
      // 交替深浅木纹色
      paint.color = (i % 3 == 0)
          ? const Color(0xFFB89060).withValues(alpha: 0.25)
          : const Color(0xFFF0E0C0).withValues(alpha: 0.4);

      final path = Path();
      path.moveTo(0, y);
      double prevY = y;
      for (double x = 0; x <= size.width; x += 15) {
        final wave = (i % 4 == 0) ? 3.0 : (i % 4 == 1) ? -2.0 : (i % 4 == 2) ? 1.5 : -1.0;
        prevY += (wave - prevY + y) * 0.1;
        path.lineTo(x, prevY);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
