import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class EventsRepository {
  static const _key = 'events';

  Future<List<EventModel>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveEvents(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
