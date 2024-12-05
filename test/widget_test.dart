// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:RescueAce/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Buat data dummy untuk userData dan savedNotificationData
    final Map<String, dynamic> dummyUserData = {
      'nama': 'Test User',
      'role': 'Damkar',
      'cabang': 'Dummy Cabang',
    };

    final Map<String, dynamic>? dummyNotificationData = {
      'status': 'aktif',
      'kebakaran': {
        'id_kebakaran': 1,
        'lokasi': 'Jl. Dummy Lokasi',
      },
      'rute': {
        'coordinates': [
          [112.794676, -7.282219],
          [112.794700, -7.282300],
        ],
      },
    };

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      userData: dummyUserData,
      savedNotificationData: dummyNotificationData,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
