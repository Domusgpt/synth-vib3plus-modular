// Basic Flutter widget test for Synth-VIB3+

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:synther_vib34d_holographic/main.dart';
import 'package:synther_vib34d_holographic/core/synth_app_initializer.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Initialize modules
    final modules = await initializeSynthModules();

    // Build our app and trigger a frame
    await tester.pumpWidget(SynthVIB3App(modules: modules));

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
