import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/date_calculator.dart';

class DaysDisplay extends StatelessWidget {
  final DateTime date;

  const DaysDisplay({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    // 只取一次 now，保证 totalDays 和 breakdown 基准一致
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = DateTime(date.year, date.month, date.day);
    final total = today.difference(from).inDays;
    final bd = DateCalculator.breakdown(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$total',
          style: GoogleFonts.inter(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        Text(
          '天',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatBreakdown(bd),
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white60,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _formatBreakdown(({int years, int months, int days}) bd) {
    final parts = <String>[];
    if (bd.years > 0) parts.add('${bd.years}年');
    if (bd.months > 0) parts.add('${bd.months}个月');
    if (bd.days > 0) parts.add('${bd.days}天');
    return parts.isEmpty ? '就是今天' : parts.join(' ');
  }
}
