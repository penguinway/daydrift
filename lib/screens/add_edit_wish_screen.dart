import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/wish_model.dart';
import '../providers/wishes_provider.dart';

class AddEditWishScreen extends ConsumerStatefulWidget {
  final WishModel? wish;

  const AddEditWishScreen({super.key, this.wish});

  @override
  ConsumerState<AddEditWishScreen> createState() => _AddEditWishScreenState();
}

class _AddEditWishScreenState extends ConsumerState<AddEditWishScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _category;
  DateTime? _targetDate;
  late WishStatus _status;
  final _uuid = const Uuid();

  bool get _isEditing => widget.wish != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.wish?.title ?? '');
    _descCtrl = TextEditingController(text: widget.wish?.description ?? '');
    _category = widget.wish?.category ?? '旅行';
    _targetDate = widget.wish?.targetDate;
    _status = widget.wish?.status ?? WishStatus.todo;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: '选择目标日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入心愿标题')),
      );
      return;
    }

    final wish = WishModel(
      id: widget.wish?.id ?? _uuid.v4(),
      title: title,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      category: _category,
      targetDate: _targetDate,
      status: _status,
      createdAt: widget.wish?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      ref.read(wishesProvider.notifier).updateWish(wish);
    } else {
      ref.read(wishesProvider.notifier).addWish(wish);
    }
    // Add custom category if new
    ref.read(wishCategoriesProvider.notifier).addCategory(_category);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(wishCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? ['旅行', '美食', '体验', '购物', '学习'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5EDD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9500),
        elevation: 0,
        title: Text(
          _isEditing ? '编辑心愿' : '新增心愿',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          GestureDetector(
            onTap: _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '保存',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('心愿标题'),
            const SizedBox(height: 8),
            _buildTextField(_titleCtrl, '例如：一起去看极光', maxLength: 30),
            const SizedBox(height: 24),
            _label('备注'),
            const SizedBox(height: 8),
            _buildTextField(_descCtrl, '补充说明（可选）', maxLines: 3),
            const SizedBox(height: 24),
            _label('分类'),
            const SizedBox(height: 8),
            _buildCategorySelector(categories),
            const SizedBox(height: 24),
            _label('目标日期（可选）'),
            const SizedBox(height: 8),
            _buildDatePicker(),
            if (_isEditing) ...[
              const SizedBox(height: 24),
              _label('状态'),
              const SizedBox(height: 8),
              _buildStatusSelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(color: const Color(0xFF8B5E3C), fontSize: 13, fontWeight: FontWeight.w600),
      );

  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      maxLength: maxLength,
      style: GoogleFonts.inter(color: const Color(0xFF1C1C1E), fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFFBBBBBB)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2)),
        counterText: maxLength != null ? null : '',
      ),
      buildCounter: maxLength != null
          ? (_, {required currentLength, required isFocused, maxLength}) =>
              Text('$currentLength/$maxLength', style: GoogleFonts.inter(color: const Color(0xFFAAAAAA), fontSize: 12))
          : null,
    );
  }

  Widget _buildCategorySelector(List<String> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...categories.map((c) => ChoiceChip(
              label: Text(c),
              selected: _category == c,
              onSelected: (_) => setState(() => _category = c),
              selectedColor: const Color(0xFFFF9500).withValues(alpha: 0.2),
              labelStyle: GoogleFonts.inter(
                color: _category == c ? const Color(0xFFFF9500) : const Color(0xFF8B5E3C),
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: _category == c ? const Color(0xFFFF9500) : const Color(0xFFDDDDDD)),
            )),
        ActionChip(
          label: const Text('+ 自定义'),
          onPressed: _addCustomCategory,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDDDDDD)),
          labelStyle: GoogleFonts.inter(color: const Color(0xFF8B5E3C)),
        ),
      ],
    );
  }

  void _addCustomCategory() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('自定义分类'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: '输入分类名称')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('确定')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _category = result);
    }
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Color(0xFFFF9500), size: 20),
            const SizedBox(width: 12),
            Text(
              _targetDate != null ? DateFormat('yyyy年M月d日').format(_targetDate!) : '点击选择日期',
              style: GoogleFonts.inter(color: _targetDate != null ? const Color(0xFF1C1C1E) : const Color(0xFFBBBBBB), fontSize: 16),
            ),
            const Spacer(),
            if (_targetDate != null)
              GestureDetector(
                onTap: () => setState(() => _targetDate = null),
                child: const Icon(Icons.close, color: Color(0xFFAAAAAA), size: 20),
              )
            else
              const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: WishStatus.values.map((s) {
        final (label, color) = switch (s) {
          WishStatus.todo => ('想做', const Color(0xFFFF9500)),
          WishStatus.planning => ('计划中', const Color(0xFF007AFF)),
          WishStatus.completed => ('已完成', const Color(0xFF34C759)),
        };
        final selected = _status == s;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _status = s),
            selectedColor: color.withValues(alpha: 0.2),
            labelStyle: GoogleFonts.inter(color: selected ? color : const Color(0xFF8E8E93), fontWeight: FontWeight.w500),
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? color : const Color(0xFFDDDDDD)),
          ),
        );
      }).toList(),
    );
  }
}
