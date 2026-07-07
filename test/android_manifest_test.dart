import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('declares receivers required for scheduled Android notifications', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(
      manifest,
      contains('com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver'),
    );
    expect(
      manifest,
      contains('com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver'),
    );
    expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
    expect(manifest, contains('android.intent.action.MY_PACKAGE_REPLACED'));
    expect(manifest, contains('android.intent.action.QUICKBOOT_POWERON'));
    expect(manifest, contains('com.htc.intent.action.QUICKBOOT_POWERON'));
  });
}
