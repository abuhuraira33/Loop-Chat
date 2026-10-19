import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final sdk = Platform.environment['FLUTTER_ROOT'];
  if (sdk != null) {
    final path = '$sdk/bin/cache/artifacts/material_fonts';
    final font = FontLoader('Roboto');
    for (final name in [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
      'Roboto-Black.ttf',
    ]) {
      final bytes = await File('$path/$name').readAsBytes();
      font.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await font.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(
      Future.value(
        ByteData.sublistView(
          await File('$path/MaterialIcons-Regular.otf').readAsBytes(),
        ),
      ),
    );
    await icons.load();
  }
  await testMain();
}
