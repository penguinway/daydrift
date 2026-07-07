import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:love_time/models/event_model.dart';
import 'package:love_time/providers/events_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const notificationsChannel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, null);
  });

  test('loads saved events when notification rescheduling fails', () async {
    final event = EventModel(
      id: 'event-1',
      name: '纪念日',
      date: DateTime(2024, 5, 20),
    );
    SharedPreferences.setMockInitialValues({
      'events': jsonEncode([event.toJson()]),
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, (call) async {
      if (call.method == 'cancelAll') {
        throw PlatformException(
          code: 'error',
          message: 'Missing type parameter.',
        );
      }
      return null;
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final events = await container.read(eventsProvider.future);

    expect(events, hasLength(1));
    expect(events.first.id, 'event-1');
  });

  test('deletes event even when notification cancellation fails', () async {
    final event = EventModel(
      id: 'event-1',
      name: '纪念日',
      date: DateTime(2024, 5, 20),
    );
    SharedPreferences.setMockInitialValues({
      'events': jsonEncode([event.toJson()]),
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, (call) async {
      if (call.method == 'cancel') {
        throw PlatformException(
          code: 'error',
          message: 'Missing type parameter.',
        );
      }
      return null;
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(eventsProvider.future);

    await container.read(eventsProvider.notifier).deleteEvent('event-1');

    expect(container.read(eventsProvider).valueOrNull, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('events')!) as List<dynamic>, isEmpty);
  });
}
