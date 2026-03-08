import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../utils/date_calculator.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _cardRadius = 16.0;
  static const _headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFAA00), Color(0xFFFF7700)],
  );

  const EventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = DateTime(event.date.year, event.date.month, event.date.day);
    final total = today.difference(from).inDays;
    final bd = DateCalculator.breakdown(event.date);

    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final startWeekday = weekdays[event.date.weekday - 1];
    final todayWeekday = weekdays[now.weekday - 1];
    final startStr = DateFormat('yyyy-M-d').format(event.date);
    final todayStr = DateFormat('yyyy-M-d').format(now);

    return GestureDetector(
      onLongPress: () => _showMenu(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Column(
            children: [
              // 橙色渐变顶栏
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(gradient: _headerGradient),
                child: Text(
                  event.name,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 白色主体：大数字
              Container(
                width: double.infinity,
                color: const Color(0xFFF8F8F8),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // 超大天数数字
                    Text(
                      '$total',
                      style: GoogleFonts.inter(
                        fontSize: 96,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C1C1E),
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // 年月日细分（有则显示）
                    if (total >= 30)
                      Text(
                        _formatBreakdown(bd),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFFAAAAAA),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              // 分隔线
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              // 底部日期信息
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  '$startStr 周$startWeekday  ～  $todayStr 周$todayWeekday',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBreakdown(({int years, int months, int days}) bd) {
    final parts = <String>[];
    if (bd.years > 0) parts.add('${bd.years}年');
    if (bd.months > 0) parts.add('${bd.months}个月');
    if (bd.days > 0) parts.add('${bd.days}天');
    return parts.isEmpty ? '就是今天' : parts.join(' ');
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFFFF9500)),
              title: Text('编辑', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              onTap: () { Navigator.pop(context); onEdit(); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text('删除', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w500)),
              onTap: () { Navigator.pop(context); onDelete(); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
