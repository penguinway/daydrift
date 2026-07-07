import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../services/notification_service.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  final EventModel? event; // null = 新增

  const AddEditScreen({super.key, this.event});

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  late final TextEditingController _nameCtrl;
  late DateTime _selectedDate;
  late bool _reminderEnabled;
  late int _reminderDaysBefore;
  late int _reminderHour;
  late int _reminderMinute;
  var _isSaving = false;
  final _uuid = const Uuid();

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.event?.name ?? '');
    _selectedDate = widget.event?.date ?? DateTime.now();
    _reminderEnabled = widget.event?.reminderEnabled ?? false;
    _reminderDaysBefore = widget.event?.reminderDaysBefore ?? 0;
    _reminderHour = widget.event?.reminderHour ?? 8;
    _reminderMinute = widget.event?.reminderMinute ?? 0;
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

  Future<void> _save() async {
    if (_isSaving) return;

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入事件名称')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_reminderEnabled) {
        await NotificationService().requestPermission();
        if (!mounted) return;
      }

      final event = EventModel(
        id: widget.event?.id ?? _uuid.v4(),
        name: name,
        date: _selectedDate,
        reminderEnabled: _reminderEnabled,
        reminderDaysBefore: _reminderDaysBefore,
        reminderHour: _reminderHour,
        reminderMinute: _reminderMinute,
      );

      if (_isEditing) {
        await ref.read(eventsProvider.notifier).updateEvent(event);
      } else {
        await ref.read(eventsProvider.notifier).addEvent(event);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? '事件已保存' : '事件已添加')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
            onTap: _isSaving ? null : _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                _isSaving ? '保存中' : '保存',
                style: GoogleFonts.inter(
                  color: _isSaving ? Colors.white70 : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
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
            const SizedBox(height: 24),
            // 提醒设置
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDDDDD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_outlined, color: Color(0xFFFF9500), size: 20),
                      const SizedBox(width: 8),
                      Text('纪念日提醒', style: GoogleFonts.inter(color: const Color(0xFF8B5E3C), fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Switch(
                        value: _reminderEnabled,
                        onChanged: (v) => setState(() => _reminderEnabled = v),
                        activeThumbColor: const Color(0xFFFF9500),
                      ),
                    ],
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 12),
                    Text('提前提醒', style: GoogleFonts.inter(color: const Color(0xFF8B5E3C), fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [0, 1, 3, 7].map((d) => ChoiceChip(
                        label: Text(d == 0 ? '当天' : '$d天前'),
                        selected: _reminderDaysBefore == d,
                        onSelected: (_) => setState(() => _reminderDaysBefore = d),
                        selectedColor: const Color(0xFFFF9500).withValues(alpha: 0.2),
                        labelStyle: GoogleFonts.inter(
                          color: _reminderDaysBefore == d ? const Color(0xFFFF9500) : const Color(0xFF8E8E93),
                          fontWeight: FontWeight.w500, fontSize: 13,
                        ),
                        backgroundColor: const Color(0xFFF8F8F8),
                        side: BorderSide(color: _reminderDaysBefore == d ? const Color(0xFFFF9500) : const Color(0xFFEEEEEE)),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
                          cancelText: '取消',
                          confirmText: '确定',
                        );
                        if (picked != null) setState(() { _reminderHour = picked.hour; _reminderMinute = picked.minute; });
                      },
                      child: Row(
                        children: [
                          Text('提醒时间', style: GoogleFonts.inter(color: const Color(0xFF8B5E3C), fontSize: 12)),
                          const SizedBox(width: 12),
                          Text(
                            '${_reminderHour.toString().padLeft(2, '0')}:${_reminderMinute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.inter(color: const Color(0xFFFF9500), fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.access_time, color: Color(0xFFFF9500), size: 16),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
