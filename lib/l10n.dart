import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:words/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('ko'),
    const Locale('iw'),
  ];

  static String getFlag(String countryCode) {
    switch (countryCode) {
      case 'ko':
        return '🇰🇷';
      case 'en':
        return '🇺🇸';
      case 'he':
        return '🇮🇱';
      default:
        return 'no flag';
    }
  }

  static String getLangCodeFromFlag(String flag) {
    switch (flag) {
      case '🇰🇷':
        return 'ko';
      case '🇺🇸':
        return 'en';
      case '🇮🇱':
        return 'he';
      default:
        return 'no flag';
    }
  }

  static String getLanguageName(BuildContext context, String countryCode) {
    if (countryCode == 'iw') {
      return 'עברית';
    }
    return LocaleNames.of(context)!.nameOf(countryCode)!;
  }

  static String getLanguageCode(BuildContext context, String countryCode) {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale;
    if (locale.languageCode == 'he') {
      return 'iw';
    }
    return locale.languageCode;
  }
}
