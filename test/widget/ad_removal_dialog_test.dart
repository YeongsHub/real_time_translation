import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_translation/features/subscription/presentation/widgets/ad_removal_dialog.dart';

void main() {
  Widget buildApp() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AdRemovalDialog.show(context),
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );
  }

  group('AdRemovalDialog', () {
    testWidgets('displays title and description', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('광고 없이 사용하기'), findsOneWidget);
      expect(
        find.text('Premium으로 업그레이드하면\n광고 없이 깔끔하게 번역할 수 있어요'),
        findsOneWidget,
      );
    });

    testWidgets('shows benefit list', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('광고 완전 제거'), findsOneWidget);
      expect(find.text('고품질 온라인 번역'), findsOneWidget);
      expect(find.text('40+개 언어 지원'), findsOneWidget);
    });

    testWidgets('CTA button closes dialog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Premium 시작하기'));
      await tester.pumpAndSettle();

      expect(find.text('광고 없이 사용하기'), findsNothing);
    });

    testWidgets('dismiss button closes dialog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('나중에'));
      await tester.pumpAndSettle();

      expect(find.text('광고 없이 사용하기'), findsNothing);
    });
  });
}
