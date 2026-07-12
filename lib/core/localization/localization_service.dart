import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/api_service.dart';
import 'languages.dart';
import 'messages.dart';

class LocalizationService extends GetxService {
  static const String _storageKey = 'selected_language';
  final GetStorage _storage = GetStorage();
  final ApiService _apiService = Get.find<ApiService>();
  final Connectivity _connectivity = Connectivity();

  final RxString currentLanguage = 'en'.obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, String> remoteTranslations = <String, String>{}.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await detectSystemLanguage();
    await loadSavedLanguage();
    await fetchRemoteTranslations();
  }

  Future<void> detectSystemLanguage() async {
    try {
      final locale = Get.deviceLocale;
      if (locale != null) {
        final systemLang = locale.languageCode;
        if (SupportedLanguage.findByCode(systemLang) != null) {
          await changeLanguage(systemLang, save: false);
        }
      }
    } catch (e) {
      log('Error detecting system language: $e');
    }
  }

  Future<void> loadSavedLanguage() async {
    try {
      final savedLang = _storage.read<String>(_storageKey);
      if (savedLang != null && SupportedLanguage.findByCode(savedLang) != null) {
        await changeLanguage(savedLang, save: false);
      }
    } catch (e) {
      log('Error loading saved language: $e');
    }
  }

  Future<void> changeLanguage(String langCode, {bool save = true}) async {
    try {
      if (!SupportedLanguage.all.any((lang) => lang.code == langCode)) {
        langCode = 'en';
      }

      currentLanguage.value = langCode;

      Get.updateLocale(Locale(langCode));

      if (save) {
        await _storage.write(_storageKey, langCode);
        await updateBackendLanguage(langCode);
      }
    } catch (e) {
      log('Error changing language: $e');
    }
  }

  Future<void> updateBackendLanguage(String langCode) async {
    try {
      await _apiService.put(
        '/api/users/language',
        body: {'language': langCode},
      );
    } catch (e) {
      log('Error updating backend language: $e');
    }
  }

  Future<void> fetchRemoteTranslations() async {
    try {
      isLoading.value = true;

      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        isLoading.value = false;
        return;
      }

      final response = await _apiService.get(
        '/api/localization/translations',
        query: {'language': currentLanguage.value},
      );

      if (response != null && response is Map) {
        final translations = response['data']?['translations'];
        if (translations != null && translations is Map) {
          remoteTranslations.value = Map<String, String>.from(translations);
        }
      }
    } catch (e) {
      log('Error fetching remote translations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getRemoteTranslation(String key) {
    return remoteTranslations[key] ?? key;
  }

  String getLocalTranslation(String key) {
    final translations = Messages().keys[currentLanguage.value];
    return translations?[key] ?? key;
  }

  String translate(String key) {
    final remote = getRemoteTranslation(key);
    if (remote != key) {
      return remote;
    }
    return getLocalTranslation(key);
  }

  List<SupportedLanguage> getAvailableLanguages() {
    return SupportedLanguage.all;
  }

  SupportedLanguage? getCurrentLanguage() {
    return SupportedLanguage.findByCode(currentLanguage.value);
  }

  String getCurrentLanguageName() {
    final lang = getCurrentLanguage();
    return lang?.nativeName ?? 'English';
  }

  String getCurrentLanguageFlag() {
    final lang = getCurrentLanguage();
    return lang?.flagEmoji ?? '🌐';
  }
}