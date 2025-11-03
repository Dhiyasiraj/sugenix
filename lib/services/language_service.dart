import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'Sugenix',
      'home': 'Home',
      'glucose': 'Glucose',
      'records': 'Records',
      'medicine': 'Medicine',
      'profile': 'Profile',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'welcome': 'Welcome',
      'logout': 'Logout',
      'settings': 'Settings',
      'language': 'Language',
    },
    'ml': {
      'app_name': 'സുജെനിക്സ്',
      'home': 'ഹോം',
      'glucose': 'ഗ്ലൂക്കോസ്',
      'records': 'റെക്കോർഡുകൾ',
      'medicine': 'മരുന്ന്',
      'profile': 'പ്രൊഫൈൽ',
      'login': 'ലോഗിൻ',
      'signup': 'സൈൻ അപ്പ്',
      'email': 'ഇമെയിൽ',
      'password': 'പാസ്‌വേഡ്',
      'name': 'പേര്',
      'welcome': 'സ്വാഗതം',
      'logout': 'ലോഗ്‌ഔട്ട്',
      'settings': 'ക്രമീകരണങ്ങൾ',
      'language': 'ഭാഷ',
    },
    'hi': {
      'app_name': 'सुजेनिक्स',
      'home': 'होम',
      'glucose': 'ग्लूकोज',
      'records': 'रिकॉर्ड्स',
      'medicine': 'दवा',
      'profile': 'प्रोफ़ाइल',
      'login': 'लॉगिन',
      'signup': 'साइन अप',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'name': 'नाम',
      'welcome': 'स्वागत है',
      'logout': 'लॉग आउट',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
    },
  };

  static final List<Map<String, String>> _supportedLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ml', 'name': 'മലയാളം', 'flag': '🇮🇳'},
    {'code': 'hi', 'name': 'हिंदी', 'flag': '🇮🇳'},
  ];

  static List<Map<String, String>> getSupportedLanguages() {
    return _supportedLanguages;
  }

  static String getLanguageName(String code) {
    final lang = _supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'code': code, 'name': code, 'flag': ''},
    );
    return lang['name'] ?? code;
  }

  static Future<String> getSelectedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? _defaultLanguage;
    } catch (e) {
      return _defaultLanguage;
    }
  }

  static Future<void> setSelectedLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Handle error
    }
  }

  static String translate(String key, String languageCode) {
    return _translations[languageCode]?[key] ??
        _translations[_defaultLanguage]?[key] ??
        key;
  }

  static Future<String> getTranslated(String key) async {
    final languageCode = await getSelectedLanguage();
    return translate(key, languageCode);
  }
}

