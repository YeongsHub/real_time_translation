class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });

  static const List<Language> supported = [
    Language(code: 'ko', name: 'Korean', nativeName: '한국어', flagEmoji: '🇰🇷'),
    Language(code: 'en', name: 'English', nativeName: 'English', flagEmoji: '🇺🇸'),
    Language(code: 'ja', name: 'Japanese', nativeName: '日本語', flagEmoji: '🇯🇵'),
    Language(code: 'zh', name: 'Chinese', nativeName: '中文', flagEmoji: '🇨🇳'),
    Language(code: 'es', name: 'Spanish', nativeName: 'Español', flagEmoji: '🇪🇸'),
    Language(code: 'fr', name: 'French', nativeName: 'Français', flagEmoji: '🇫🇷'),
    Language(code: 'de', name: 'German', nativeName: 'Deutsch', flagEmoji: '🇩🇪'),
    Language(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', flagEmoji: '🇻🇳'),
    Language(code: 'th', name: 'Thai', nativeName: 'ไทย', flagEmoji: '🇹🇭'),
    Language(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flagEmoji: '🇮🇩'),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Language && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
