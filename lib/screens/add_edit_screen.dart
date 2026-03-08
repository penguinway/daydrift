import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  final EventModel? event; // null = 新增

  const AddEditScreen({super.key, this.event});

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  late final TextEditingController _nameCtrl;
  late DateTime _selectedDate;
  final _uuid = const Uuid();

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.event?.name ?? '');
    _selectedDate = widget.event?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: '选择日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入事件名称')),
      );
      return;
    }

    final event = EventModel(
      id: widget.event?.id ?? _uuid.v4(),
      name: name,
      date: _selectedDate,
    );

    if (_isEditing) {
      ref.read(eventsProvider.notifier).updateEvent(event);
    } else {
      ref.read(eventsProvider.notifier).addEvent(event);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9500),
        elevation: 0,
        title: Text(
          _isEditing ? '编辑事件' : '新增事件',
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
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '事件名称',
              style: GoogleFonts.inter(color: const Color(0xFF8B5E3C), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: GoogleFonts.inter(color: const Color(0xFF1C1C1E), fontSize: 16),
              decoration: InputDecoration(
                hintText: '例如：我们在一起的日子',
                hintStyle: GoogleFonts.inter(color: const Color(0xFFBBBBBB)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
                ),
              ),
              maxLength: 30,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                  Text('$currentLength/$maxLength',
                      style: GoogleFonts.inter(color: const Color(0xFFAAAAAA), fontSize: 12)),
            ),
            const SizedBox(height: 24),
            Text(
              '日期',
              style: GoogleFonts.inter(color: const Color(0xFF8B5E3C), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            GestureDetector(
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
                      DateFormat('yyyy年M月d日').format(_selectedDate),
                      style: GoogleFonts.inter(color: const Color(0xFF1C1C1E), fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
