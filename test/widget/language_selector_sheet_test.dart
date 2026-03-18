import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_translation/features/translation/domain/models/language.dart';
import 'package:real_time_translation/features/translation/presentation/widgets/language_selector_sheet.dart';

void main() {
  const korean = Language(
    code: 'ko',
    name: 'Korean',
    nativeName: '한국어',
    flagEmoji: '\u{1F1F0}\u{1F1F7}',
  );

  Widget buildApp({Language? selected}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => LanguageSelectorSheet(
                currentLanguage: selected ?? korean,
                onSelected: (lang) => Navigator.of(context).pop(lang),
              ),
            ),
            child: const Text('Select Language'),
          ),
        ),
      ),
    );
  }

  group('LanguageSelectorSheet', () {
    testWidgets('shows title and all supported languages', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Select Language'));
      await tester.pumpAndSettle();

      expect(find.text('언어 선택'), findsOneWidget);

      // Check a sample of languages are visible
      expect(find.text('한국어'), findsOneWidget);
      // "English" appears as both nativeName and name (subtitle), so expect 2
      expect(find.text('English'), findsWidgets);
    });

    testWidgets('highlights currently selected language', (tester) async {
      await tester.pumpWidget(buildApp(selected: korean));
      await tester.tap(find.text('Select Language'));
      await tester.pumpAndSettle();

      // The check icon should appear for selected language
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('tapping a language closes the sheet', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Select Language'));
      await tester.pumpAndSettle();

      // Tap English
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.text('언어 선택'), findsNothing);
    });
  });
}
