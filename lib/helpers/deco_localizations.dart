import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecoLocalizations {

  DecoLocalizations(Locale locale){
    _localizedValues = null;
    this.locale = locale;
  }

  Locale locale;
  static Map<dynamic, dynamic> _localizedValues;

  static DecoLocalizations of(BuildContext context){
    return Localizations.of<DecoLocalizations>(context, DecoLocalizations);
  }

  String get currentLanguage => locale.languageCode;

  String localizedString(String key) {
    if (_localizedValues != null) {
      return _localizedValues[key] ?? key;
    }

    return key;
  }

  static Future<DecoLocalizations> load(Locale locale) async {
    DecoLocalizations translations = new DecoLocalizations(locale);
    String jsonContent = await rootBundle.loadString("lib/locale/i18n_${locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);
    return translations;
  }
}

class DecoLocalizationsDelegate extends LocalizationsDelegate<DecoLocalizations> {
  const DecoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode=='en' || locale.languageCode=='ar';
  }

  @override
  Future<DecoLocalizations> load(Locale locale) {
    return DecoLocalizations.load(locale);
  }

  @override
  bool shouldReload(DecoLocalizationsDelegate old) => false;
}

