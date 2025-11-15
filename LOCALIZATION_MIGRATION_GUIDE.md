# Localization Migration Guide

## Overview

The app has been migrated from hardcoded translations to Flutter's official localization system using ARB (Application Resource Bundle) files. This provides better type safety, IDE support, and follows Flutter best practices.

## What Has Been Done

1. ✅ **Setup Flutter Localization**
   - Added `flutter_localizations` to `pubspec.yaml`
   - Created `l10n.yaml` configuration file
   - Generated ARB files for English (`app_en.arb`), Malayalam (`app_ml.arb`), and Hindi (`app_hi.arb`)

2. ✅ **Created Localization Services**
   - `AppLocalizationService`: Manages locale persistence with SharedPreferences
   - `LocaleNotifier`: ChangeNotifier for locale changes using Provider

3. ✅ **Updated Core Files**
   - `main.dart`: MaterialApp now uses `AppLocalizations` with locale support
   - `language_screen.dart`: Updated to use new localization system
   - `Login.dart`: Migrated as example
   - `main.dart` navigation: Updated bottom navigation labels

## How to Use AppLocalizations

### Basic Usage

Replace hardcoded strings with `AppLocalizations`:

**Before:**
```dart
Text('Welcome back')
```

**After:**
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.welcomeBack)
```

### In Widget Build Methods

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.home),
    ),
    body: Text(l10n.welcomeBack),
  );
}
```

### For TextField Hints

```dart
TextField(
  decoration: InputDecoration(
    hintText: l10n.email,
  ),
)
```

### In Async Methods

If you need translations in async methods, get `l10n` before the async operation:

```dart
Future<void> _handleAction() async {
  final l10n = AppLocalizations.of(context)!;
  
  // Now you can use l10n in async code
  if (someCondition) {
    _showSnackBar(l10n.fillAllFields);
  }
}
```

### Using Builder for Dynamic Text

If you're outside the build method or need to rebuild on locale change:

```dart
Builder(
  builder: (context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.someText);
  },
)
```

## Migration Steps for Remaining Screens

### Step 1: Update Imports

**Remove:**
```dart
import 'package:sugenix/services/language_service.dart';
import 'package:sugenix/widgets/translated_text.dart';
```

**Add:**
```dart
import 'package:sugenix/l10n/app_localizations.dart';
```

### Step 2: Replace TranslatedText Widgets

**Before:**
```dart
TranslatedText(
  'welcome_back',
  style: TextStyle(...),
  fallback: 'Welcome back',
)
```

**After:**
```dart
final l10n = AppLocalizations.of(context)!;
Text(
  l10n.welcomeBack,
  style: TextStyle(...),
)
```

### Step 3: Replace LanguageBuilder

**Before:**
```dart
LanguageBuilder(
  builder: (context, languageCode) {
    return TextField(
      decoration: InputDecoration(
        hintText: LanguageService.translate('email', languageCode),
      ),
    );
  },
)
```

**After:**
```dart
Builder(
  builder: (context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      decoration: InputDecoration(
        hintText: l10n.email,
      ),
    );
  },
)
```

### Step 4: Replace LanguageService.translate Calls

**Before:**
```dart
final languageCode = await LanguageService.getSelectedLanguage();
final text = LanguageService.translate('key', languageCode);
```

**After:**
```dart
final l10n = AppLocalizations.of(context)!;
final text = l10n.key; // Use the camelCase property name
```

## Key Name Mapping

ARB keys use camelCase. Here's the mapping:

| Old Key (snake_case) | New Property (camelCase) |
|---------------------|--------------------------|
| `welcome_back` | `welcomeBack` |
| `sign_in` | `signIn` |
| `sign_in_title` | `signInTitle` |
| `fill_all_fields` | `fillAllFields` |
| `current_glucose_level` | `currentGlucoseLevel` |
| `quick_actions` | `quickActions` |
| etc. | etc. |

## Adding New Translations

1. **Add to ARB files** (`lib/l10n/app_en.arb`, `app_ml.arb`, `app_hi.arb`):
```json
{
  "newKey": "New Text",
  "@newKey": {
    "description": "Description of the text"
  }
}
```

2. **Run code generation:**
```bash
flutter gen-l10n
```

3. **Use in code:**
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.newKey)
```

## Files That Need Migration

- [ ] `lib/signin.dart`
- [ ] `lib/screens/home_screen.dart`
- [ ] `lib/screens/settings_screen.dart`
- [ ] `lib/screens/profile_screen.dart`
- [ ] `lib/screens/glucose_monitoring_screen.dart`
- [ ] `lib/screens/medical_records_screen.dart`
- [ ] `lib/screens/medicine_orders_screen.dart`
- [ ] All other screens with hardcoded text

## Benefits of This Approach

1. **Type Safety**: IDE autocomplete and compile-time checks
2. **No Runtime Errors**: Missing translations caught at compile time
3. **Better Performance**: No string lookups at runtime
4. **Standard Flutter Approach**: Uses official Flutter localization
5. **Easy to Maintain**: All translations in one place (ARB files)
6. **IDE Support**: Full IntelliSense support for translation keys

## Notes

- The old `LanguageService` and `TranslatedText` widgets can be removed after all screens are migrated
- Language selection persists automatically via `AppLocalizationService`
- The app automatically rebuilds when language changes via `LocaleNotifier`

