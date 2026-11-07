import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fontLoader = FontLoader('Mukta');
  final weights = ['Regular', 'SemiBold', 'Bold', 'ExtraBold'];
  for (final weight in weights) {
    final file = File('assets/fonts/Mukta-$weight.ttf');
    if (file.existsSync()) {
      final bytes = await file.readAsBytes();
      fontLoader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
  }
  await fontLoader.load();

  // Try loading MaterialIcons and Roboto fallback if available
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? 'C:/flutter';
  final materialIconFile = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  );
  if (materialIconFile.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons');
    final iconBytes = await materialIconFile.readAsBytes();
    iconLoader.addFont(Future.value(ByteData.sublistView(iconBytes)));
    await iconLoader.load();
  }

  final robotoFile = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/roboto-regular.ttf',
  );
  if (robotoFile.existsSync()) {
    final robotoLoader = FontLoader('Roboto');
    final robotoBytes = await robotoFile.readAsBytes();
    robotoLoader.addFont(Future.value(ByteData.sublistView(robotoBytes)));
    await robotoLoader.load();
  }

  await testMain();
}
