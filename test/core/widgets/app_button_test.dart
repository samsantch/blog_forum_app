import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blog_forum_app/core/widgets/app_button.dart';

void main() {
  testWidgets('shows label text when not loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Submit', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Submit'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows spinner and hides label when loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Submit', isLoading: true, onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Submit'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Submit', onPressed: () => wasTapped = true),
        ),
      ),
    );

    await tester.tap(find.byType(AppButton));
    expect(wasTapped, isTrue);
  });
}