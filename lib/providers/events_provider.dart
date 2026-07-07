import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../repositories/events_repository.dart';
import '../services/notification_service.dart';

final eventsRepositoryProvider = Provider((_) => EventsRepository());

final eventsProvider =
    AsyncNotifierProvider<EventsNotifier, List<EventModel>>(EventsNotifier.new);

class EventsNotifier extends AsyncNotifier<List<EventModel>> {
  late final EventsRepository _repo;
  final _notifications = NotificationService();

  @override
  Future<List<EventModel>> build() async {
    _repo = ref.read(eventsRepositoryProvider);
    final events = await _repo.loadEvents();
    await _notifications.rescheduleAll(events);
    return events;
  }

  Future<void> addEvent(EventModel event) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, event];
    state = AsyncData(updated);
    await _repo.saveEvents(updated);
    if (event.reminderEnabled) await _notifications.scheduleReminder(event);
  }

  Future<void> updateEvent(EventModel event) async {
    final current = state.valueOrNull ?? [];
    final updated = current.map((e) => e.id == event.id ? event : e).toList();
    state = AsyncData(updated);
    await _repo.saveEvents(updated);
    if (event.reminderEnabled) {
      await _notifications.scheduleReminder(event);
    } else {
      await _notifications.cancelReminder(event);
    }
  }

  Future<void> deleteEvent(String id) async {
    final current = state.valueOrNull ?? [];
    final event = current.firstWhere((e) => e.id == id);
    await _notifications.cancelReminder(event);
    final updated = current.where((e) => e.id != id).toList();
    state = AsyncData(updated);
    await _repo.saveEvents(updated);
  }
}
