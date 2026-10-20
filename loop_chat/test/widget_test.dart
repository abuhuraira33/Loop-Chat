import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_chat/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> openApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const LoopChatApp());
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Open Loop Chat'));
  await tester.tap(find.text('Open Loop Chat'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('welcome, search, empty search, send and back', (tester) async {
    await openApp(tester);
    await tester.enterText(find.byKey(const Key('search')), 'no such contact');
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search')), 'Abdul');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abdul Ahad'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('message-input')),
      'Hello from Loop',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-message')));
    await tester.pumpAndSettle();
    expect(find.text('Hello from Loop'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Got it! Let’s keep in touch.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Loop Chat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile editing, theme toggle and people navigation', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile-name')), 'Loop User');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Loop User'), findsOneWidget);
    await tester.tap(find.text('Dark appearance'));
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    expect(find.text('Your people'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search')), 'Zain');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zain Malik'));
    await tester.pumpAndSettle();
    expect(find.text('Start a little conversation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop uses a navigation rail', (tester) async {
    await openApp(tester, size: const Size(1200, 900));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact phone has no overflow', (tester) async {
    await openApp(tester, size: const Size(320, 640));
    await tester.tap(find.text('Abdul Ahad'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
