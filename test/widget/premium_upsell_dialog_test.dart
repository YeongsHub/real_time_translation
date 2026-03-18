import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_translation/features/subscription/presentation/widgets/premium_upsell_sheet.dart';

void main() {
  // The bottom sheet content is tall — use a larger surface to avoid overflow.
  const testSurfaceSize = Size(400, 900);

  Widget buildApp() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => PremiumUpsellSheet.show(context),
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );
  }

  group('PremiumUpsellSheet', () {
    testWidgets('displays upgrade title and description', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Premium으로 업그레이드'), findsOneWidget);
      expect(
        find.text('고품질 온라인 번역으로 더 정확한 소통을 경험하세요'),
        findsOneWidget,
      );
    });

    testWidgets('shows comparison table with free vs premium', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('무료'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('번역 품질'), findsOneWidget);
      expect(find.text('광고'), findsOneWidget);
    });

    testWidgets('defaults to yearly plan selected', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('₩59,900'), findsOneWidget);
      expect(find.text('/년'), findsOneWidget);
      expect(find.text('58% 할인'), findsWidgets); // badge + subtitle
    });

    testWidgets('switches to monthly plan on tap', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('월간'));
      await tester.pumpAndSettle();

      expect(find.text('₩9,900'), findsOneWidget);
      expect(find.text('/월'), findsOneWidget);
    });

    testWidgets('CTA button closes the dialog', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('지금 업그레이드'));
      await tester.pumpAndSettle();

      expect(find.text('Premium으로 업그레이드'), findsNothing);
    });

    testWidgets('shows restore purchase button', (tester) async {
      tester.view.physicalSize = testSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('구매 복원'), findsOneWidget);
    });
  });
}
