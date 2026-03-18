import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_translation/features/translation/domain/models/language.dart';
import 'package:real_time_translation/features/translation/presentation/widgets/speaker_panel.dart';

void main() {
  const korean = Language(
    code: 'ko',
    name: 'Korean',
    nativeName: '한국어',
    flagEmoji: '\u{1F1F0}\u{1F1F7}',
  );

  Widget buildPanel({
    String label = 'SPEAKER A',
    Language language = korean,
    String translatedText = '',
    String originalText = '',
    bool isListening = false,
    bool isTopPanel = true,
    VoidCallback? onMicPressed,
    VoidCallback? onLanguageTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            SpeakerPanel(
              label: label,
              selectedLanguage: language,
              translatedText: translatedText,
              originalText: originalText,
              isListening: isListening,
              isTopPanel: isTopPanel,
              onMicPressed: onMicPressed ?? () {},
              onLanguageTap: onLanguageTap ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  group('SpeakerPanel', () {
    testWidgets('renders label and language name', (tester) async {
      await tester.pumpWidget(buildPanel(label: 'SPEAKER A'));

      expect(find.text('SPEAKER A'), findsOneWidget);
      expect(find.text('한국어'), findsOneWidget);
    });

    testWidgets('shows placeholder text when no translation', (tester) async {
      await tester.pumpWidget(buildPanel());

      expect(find.text('마이크를 눌러 말하세요'), findsOneWidget);
    });

    testWidgets('shows listening text when isListening', (tester) async {
      await tester.pumpWidget(buildPanel(isListening: true));

      expect(find.text('듣고 있어요...'), findsOneWidget);
    });

    testWidgets('shows translated and original text', (tester) async {
      await tester.pumpWidget(buildPanel(
        translatedText: 'Hello',
        originalText: '안녕하세요',
      ));

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('안녕하세요'), findsOneWidget);
    });

    testWidgets('mic button triggers onMicPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(buildPanel(
        onMicPressed: () => pressed = true,
      ));

      // Find and tap the mic icon button
      final micIcon = find.byIcon(Icons.mic_rounded);
      expect(micIcon, findsOneWidget);
      await tester.tap(micIcon);
      expect(pressed, isTrue);
    });

    testWidgets('shows stop icon when listening', (tester) async {
      await tester.pumpWidget(buildPanel(isListening: true));

      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsNothing);
    });

    testWidgets('language chip triggers onLanguageTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildPanel(
        onLanguageTap: () => tapped = true,
      ));

      await tester.tap(find.text('한국어'));
      expect(tapped, isTrue);
    });

    testWidgets('renders as bottom panel with tertiary colors', (tester) async {
      await tester.pumpWidget(buildPanel(
        isTopPanel: false,
        label: 'SPEAKER B',
      ));

      expect(find.text('SPEAKER B'), findsOneWidget);
    });
  });
}
