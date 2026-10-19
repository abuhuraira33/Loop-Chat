// Run with: flutter test test/preview_test.dart --dart-define=CAPTURE_PREVIEWS=true
// These captures are generated from the actual Flutter widgets.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_chat/app.dart';

void main() {
  testWidgets('capture mobile and desktop previews', (tester) async {
    if (!const bool.fromEnvironment('CAPTURE_PREVIEWS')) return;
    debugDisableShadows = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: key, child: const LoopChatApp()),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('docs/screenshots/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('welcome');
    await tester.ensureVisible(find.text('Open Loop Chat'));
    await tester.tap(find.text('Open Loop Chat'));
    await tester.pumpAndSettle();
    await capture('chats');
    await tester.tap(find.text('Abdul Ahad'));
    await tester.pumpAndSettle();
    await capture('conversation');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark appearance'));
    await tester.pumpAndSettle();
    await capture('profile-dark');
    tester.view.physicalSize = const Size(1200, 900);
    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    await capture('desktop-dark');
    debugDisableShadows = true;
    expect(tester.takeException(), isNull);
  });
}
