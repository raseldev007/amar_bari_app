import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final Locale locale;

  const SettingsState({
    this.locale = const Locale('en'),
  });

  SettingsState copyWith({
    Locale? locale,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _localeKey = 'locale_code';

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Locale
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    
    state = state.copyWith(
      locale: Locale(localeCode),
    );
  }

  Future<void> setLocale(String languageCode) async {
    state = state.copyWith(locale: Locale(languageCode));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
