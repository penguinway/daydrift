import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wish_model.dart';
import '../providers/wishes_provider.dart';
import '../widgets/wish_card.dart';
import 'add_edit_wish_screen.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  String _selectedCategory = '全部';
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final wishesAsync = ref.watch(wishesProvider);
    final categoriesAsync = ref.watch(wishCategoriesProvider);
    final categories = <String>['全部', ...(categoriesAsync.valueOrNull ?? <String>[])];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _WishBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildCategoryFilter(categories),
                Expanded(child: _buildBody(wishesAsync)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditWishScreen()),
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
        '心愿',
        style: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF8B5E3C),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = categories[i];
          final selected = _selectedCategory == c;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = c),
            child: Chip(
              label: Text(c),
              labelStyle: GoogleFonts.inter(
                color: selected ? Colors.white : const Color(0xFF8B5E3C),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              backgroundColor: selected ? const Color(0xFFFF9500) : Colors.white,
              side: BorderSide(color: selected ? const Color(0xFFFF9500) : const Color(0xFFDDCCAA)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(AsyncValue<List<WishModel>> wishesAsync) {
    return wishesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF9500))),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (wishes) {
        var filtered = _selectedCategory == '全部'
            ? wishes
            : wishes.where((w) => w.category == _selectedCategory).toList();

        final active = filtered.where((w) => w.status != WishStatus.completed).toList();
        final completed = filtered.where((w) => w.status == WishStatus.completed).toList();

        if (filtered.isEmpty) return _buildEmpty();

        return ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          children: [
            ...active.map((w) => WishCard(
                  wish: w,
                  onTap: () => _editWish(w),
                  onStatusChange: () => _cycleStatus(w),
                  onDelete: () => ref.read(wishesProvider.notifier).deleteWish(w.id),
                )),
            if (completed.isNotEmpty) ...[
              GestureDetector(
                onTap: () => setState(() => _showCompleted = !_showCompleted),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Icon(_showCompleted ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF8B5E3C)),
                      const SizedBox(width: 4),
                      Text('已完成 (${completed.length})',
                          style: GoogleFonts.inter(color: const Color(0xFF8B5E3C), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              if (_showCompleted)
                ...completed.map((w) => WishCard(
                      wish: w,
                      onTap: () => _editWish(w),
                      onStatusChange: () => _cycleStatus(w),
                      onDelete: () => ref.read(wishesProvider.notifier).deleteWish(w.id),
                    )),
            ],
          ],
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
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.auto_awesome, size: 40, color: Color(0xFFFF9500)),
          ),
          const SizedBox(height: 20),
          Text('还没有心愿', style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF8B5E3C), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('点击 + 添加你们的心愿', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFB08060))),
        ],
      ),
    );
  }

  void _editWish(WishModel wish) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditWishScreen(wish: wish)));
  }

  void _cycleStatus(WishModel wish) {
    final next = switch (wish.status) {
      WishStatus.todo => WishStatus.planning,
      WishStatus.planning => WishStatus.completed,
      WishStatus.completed => WishStatus.todo,
    };
    ref.read(wishesProvider.notifier).updateWish(wish.copyWith(status: next));
  }
}

class _WishBackground extends StatelessWidget {
  const _WishBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8D5B0), Color(0xFFD4BC90), Color(0xFFEAD8B5), Color(0xFFC8A878), Color(0xFFDDC898), Color(0xFFE8D5B0)],
          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
        ),
      ),
    );
  }
}
