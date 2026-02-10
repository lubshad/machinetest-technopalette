import 'dart:convert';

import 'package:agora_chat_uikit/chat_uikit_localizations.dart';
import 'package:flutter/material.dart';


import '../core/repository.dart';
import '../exporter.dart';
import '../mixins/event_listener.dart';
import 'shared_preferences_services.dart';

const String _localeKey = "locale_preference";
const String _localizationsKey = "localizations_preference";

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._private();
  static LocalizationService get i => _instance;
  LocalizationService._private();

  String get fontFamily => _locale.languageCode == 'ar' ? "Cairo" : "Kanit";

  Locale _locale = const Locale('en');
  bool _initialized = false;

  Locale get locale => _locale;

  List<Locale> get supportedLocales => const [Locale('en'), Locale('ar')];

  ChatUIKitLocalizations chatLocalizations = ChatUIKitLocalizations();

  // ignore: prefer_final_fields
  Map<String, dynamic> _localizations = {
    "en": {
      "Home": "Home",
      "Companies": "Companies",
      "Earnings": "Earnings",
      "Tasks": "Tasks",
      "Chat": "Chats",
      "Profile": "Profile",
    },
    "ar": {
      "Home": "الرئيسية",
      "Companies": "الشركات",
      "Earnings": "الأرباح",
      "Tasks": "المهام",
      "Chat": "المحادثات",
      "Profile": "الحساب",
    },
  };

  String localizedText(String text) =>
      _localizations[locale.languageCode]?[text] ?? text;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // Load initial data from SharedPreferences
      final localizationsSaved = await SharedPreferencesService.i.getValue(
        key: _localizationsKey,
      );
      if (localizationsSaved.isNotEmpty) {
        _localizations = jsonDecode(localizationsSaved);
      }

      final savedLocaleCode = await SharedPreferencesService.i.getValue(
        key: _localeKey,
      );

      // Setup chat localizations with initial data
      chatLocalizations.addLocales(
        locales: [
          ChatLocal(
            'ar',
            (_localizations['ar'] as Map<String, dynamic>)
                .cast<String, String>(),
          ),
        ],
      );
      chatLocalizations.resetLocales();

      if (savedLocaleCode.isNotEmpty) {
        _locale = Locale(savedLocaleCode);
        chatLocalizations.translate(_locale.languageCode);
      }

      // Notify listeners with initial data
      notifyListeners();

      // Then fetch fresh data from API and refresh
      try {
        final translations = await DataRepository.i.fetchTranslations();
        _localizations = translations;
        await SharedPreferencesService.i.setValue(
          key: _localizationsKey,
          value: jsonEncode(_localizations),
        );

        // Update chat localizations with fresh data
        chatLocalizations.addLocales(
          locales: [
            ChatLocal(
              'ar',
              (_localizations['ar'] as Map<String, dynamic>)
                  .cast<String, String>(),
            ),
          ],
        );
        chatLocalizations.resetLocales();

        if (savedLocaleCode.isNotEmpty) {
          chatLocalizations.translate(_locale.languageCode);
        }

        // Notify listeners with refreshed data
        _initialized = true;
        notifyListeners();
      } catch (e) {
        // If API call fails, keep using initial data
        // Error is silently handled to maintain initial state
      }
    } catch (e) {
      // If loading fails, use default locale
      _locale = const Locale('en');
    }
  }

  Future<void> updateLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      try {
        chatLocalizations.translate(newLocale.languageCode);
      } catch (e) {
        logError(e);
      }
      await SharedPreferencesService.i.setValue(
        key: _localeKey,
        value: newLocale.languageCode,
      );
      notifyListeners();
      EventListener.i.sendEvent(Event(eventType: EventType.languageChanged));
    }
  }

  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    await updateLocale(newLocale);
  }
}

extension StringExtension on String {
  bool get containsRTL {
    // Unicode ranges for RTL scripts:
    final rtlRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF' // Arabic, Persian, Urdu
      r'\u0590-\u05FF' // Hebrew
      r'\uFB50-\uFDFF\uFE70-\uFEFF]', // Arabic presentation forms
    );

    return rtlRegex.hasMatch(this);
  }

  String get translated => LocalizationService.i.localizedText(this);
}

class TranslatedText extends StatelessWidget {
  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaler,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.textWidthBasis,
    this.selectionColor,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextWidthBasis? textWidthBasis;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final localizedText = LocalizationService.i.localizedText(text);
    final textWidget = Text(
      localizedText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textScaler: textScaler,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      textWidthBasis: textWidthBasis,
      selectionColor: selectionColor,
    );
    return textWidget;
  }
}
