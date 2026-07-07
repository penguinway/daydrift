import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/wish_model.dart';

class WishCard extends StatelessWidget {
  final WishModel wish;
  final VoidCallback onTap;
  final VoidCallback onStatusChange;
  final VoidCallback onDelete;

  const WishCard({
    super.key,
    required this.wish,
    required this.onTap,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showMenu(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStatusBadge(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (color, icon) = switch (wish.status) {
      WishStatus.todo => (const Color(0xFFFF9500), Icons.star_outline),
      WishStatus.planning => (const Color(0xFF007AFF), Icons.schedule),
      WishStatus.completed => (const Color(0xFF34C759), Icons.check_circle),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                wish.title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C1C1E),
                  decoration: wish.status == WishStatus.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildCategoryChip(),
          ],
        ),
        if (wish.description != null && wish.description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            wish.description!,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF8E8E93)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (wish.targetDate != null) ...[
          const SizedBox(height: 4),
          Text(
            '目标: ${DateFormat('yyyy-M-d').format(wish.targetDate!)}',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFAAAAAA)),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E8D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        wish.category,
        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8B5E3C)),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final nextStatus = switch (wish.status) {
      WishStatus.todo => '标记为计划中',
      WishStatus.planning => '标记为已完成',
      WishStatus.completed => '重新标记为想做',
    };
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
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Color(0xFF007AFF)),
              title: Text(nextStatus, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              onTap: () { Navigator.pop(context); onStatusChange(); },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFF3C3C3C)),
              title: Text('编辑', style: GoogleFonts.inter(color: const Color(0xFF3C3C3C), fontWeight: FontWeight.w500)),
              onTap: () { Navigator.pop(context); onTap(); },
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
