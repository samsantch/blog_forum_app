import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blog_forum_app/core/widgets/app_text_field.dart';

void main() {
  testWidgets('displays the given label', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(controller: controller, label: 'Email'),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('obscures text when obscureText is true', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            label: 'Password',
            obscureText: true,
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
  });

  testWidgets('updates controller text when user types', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(controller: controller, label: 'Username'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'samuel');
    expect(controller.text, 'samuel');
  });
}