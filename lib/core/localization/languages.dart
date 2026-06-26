class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });

  static const List<SupportedLanguage> all = [
    SupportedLanguage(code: 'en', name: 'English', nativeName: 'English', flagEmoji: '🇺🇸'),
    SupportedLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flagEmoji: '🇮🇳'),
    SupportedLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flagEmoji: '🇸🇦'),
    SupportedLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flagEmoji: '🇧🇩'),
    SupportedLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', flagEmoji: '🇨🇳'),
    SupportedLanguage(code: 'da', name: 'Danish', nativeName: 'Dansk', flagEmoji: '🇩🇰'),
    SupportedLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flagEmoji: '🇳🇱'),
    SupportedLanguage(code: 'fi', name: 'Finnish', nativeName: 'Suomi', flagEmoji: '🇫🇮'),
    SupportedLanguage(code: 'fr', name: 'French', nativeName: 'Français', flagEmoji: '🇫🇷'),
    SupportedLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flagEmoji: '🇩🇪'),
    SupportedLanguage(code: 'el', name: 'Greek', nativeName: 'Ελληνικά', flagEmoji: '🇬🇷'),
    SupportedLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flagEmoji: '🇮🇳'),
    SupportedLanguage(code: 'he', name: 'Hebrew', nativeName: 'עברית', flagEmoji: '🇮🇱'),
    SupportedLanguage(code: 'hu', name: 'Hungarian', nativeName: 'Magyar', flagEmoji: '🇭🇺'),
    SupportedLanguage(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flagEmoji: '🇮🇩'),
    SupportedLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', flagEmoji: '🇮🇹'),
    SupportedLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flagEmoji: '🇯🇵'),
    SupportedLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flagEmoji: '🇮🇳'),
    SupportedLanguage(code: 'ko', name: 'Korean', nativeName: '한국어', flagEmoji: '🇰🇷'),
    SupportedLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', flagEmoji: '🇮🇳'),
    SupportedLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flagEmoji: '🇮🇳'),
    SupportedLanguage(code: 'ne', name: 'Nepali', nativeName: 'नेपाली', flagEmoji: '🇳🇵'),
    SupportedLanguage(code: 'no', name: 'Norwegian', nativeName: 'Norsk', flagEmoji: '🇳🇴'),
    SupportedLanguage(code: 'fa', name: 'Persian', nativeName: 'فارسی', flagEmoji: '🇮🇷'),
    SupportedLanguage(code: 'pl', name: 'Polish', nativeName: 'Polski', flagEmoji: '🇵🇱'),
    SupportedLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', flagEmoji: '🇧🇷'),
    SupportedLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', flagEmoji: '🇮🇳'),
    SupportedLanguage(code: 'ro', name: 'Romanian', nativeName: 'Română', flagEmoji: '🇷🇴'),
    SupportedLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flagEmoji: '🇷🇺'),
    SupportedLanguage(code: 'sr', name: 'Serbian', nativeName: 'Српски', flagEmoji: '🇷🇸'),
    SupportedLanguage(code: 'sk', name: 'Slovak', nativeName: 'Slovenčina', flagEmoji: '🇸🇰'),
    SupportedLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flagEmoji: '🇪🇸'),
    SupportedLanguage(code: 'sv', name: 'Swedish', nativeName: 'Svenska', flagEmoji: '🇸🇪'),
    SupportedLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flagEmoji: '🇮🇳'),
    SupportedLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flagEmoji: '🇮🇳'),
    SupportedLanguage(code: 'th', name: 'Thai', nativeName: 'ไทย', flagEmoji: '🇹🇭'),
    SupportedLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flagEmoji: '🇹🇷'),
    SupportedLanguage(code: 'uk', name: 'Ukrainian', nativeName: 'Українська', flagEmoji: '🇺🇦'),
    SupportedLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', flagEmoji: '🇵🇰'),
    SupportedLanguage(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', flagEmoji: '🇻🇳'),
  ];

  static SupportedLanguage? findByCode(String code) {
    try {
      return all.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  static String getNativeName(String code) {
    final lang = findByCode(code);
    return lang?.nativeName ?? code.toUpperCase();
  }

  static String getFlagEmoji(String code) {
    final lang = findByCode(code);
    return lang?.flagEmoji ?? '🌐';
  }
}