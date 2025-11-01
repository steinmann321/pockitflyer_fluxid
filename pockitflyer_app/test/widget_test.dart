import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockitflyer_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Nearby Flyers'), findsOneWidget);
  }, tags: ['tdd_green']);
}
