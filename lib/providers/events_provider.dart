import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../repositories/events_repository.dart';

final eventsRepositoryProvider = Provider((_) => EventsRepository());

final eventsProvider =
    AsyncNotifierProvider<EventsNotifier, List<EventModel>>(EventsNotifier.new);

class EventsNotifier extends AsyncNotifier<List<EventModel>> {
  late final EventsRepository _repo;

  @override
  Future<List<EventModel>> build() async {
    _repo = ref.read(eventsRepositoryProvider);
    return _repo.loadEvents();
  }

  Future<void> addEvent(EventModel event) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, event];
    state = AsyncData(updated);
    await _repo.saveEvents(updated);
  }

  Future<void> updateEvent(EventModel event) async {
    final current = state.valueOrNull ?? [];
    final updated = current.map((e) => e.id == event.id ? event : e).toList();
    state = AsyncData(updated);
    await _repo.saveEvents(updated);
  }

  Future<void> deleteEvent(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((e) => e.id != id).toList();
    state = AsyncData(updated);
    await _repo.saveEvents(updated);
  }
}
