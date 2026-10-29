import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_companion/login_page.dart.dart';

void main() {
  testWidgets('shows the Virtual Companion login page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('New here? Create an account'), findsOneWidget);
  });
}
