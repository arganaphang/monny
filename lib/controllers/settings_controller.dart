import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/account_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/transaction_controller.dart';
import '../database/database_helper.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();

  final themeMode = ThemeMode.system.obs;
  final locale = const Locale('en', 'US').obs;
  final currencySymbol = 'Rp'.obs;
  final appVersion = ''.obs;

  static const _keyTheme = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyCurrencySymbol = 'currency_symbol';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadAppVersion();
  }

  void _loadSettings() {
    final savedTheme = _box.read<String>(_keyTheme) ?? 'system';
    themeMode.value = _themeModeFromString(savedTheme);
    Get.changeThemeMode(themeMode.value);

    final savedLocale = _box.read<String>(_keyLocale) ?? 'en';
    locale.value = _localeFromCode(savedLocale);
    Get.updateLocale(locale.value);

    currencySymbol.value =
        _box.read<String>(_keyCurrencySymbol) ?? 'Rp';
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _box.write(_keyTheme, mode.name);
  }

  void setCurrencySymbol(String symbol) {
    final trimmed = symbol.trim();
    if (trimmed.isEmpty) return;
    currencySymbol.value = trimmed;
    _box.write(_keyCurrencySymbol, trimmed);
  }

  void setLocale(Locale newLocale) {
    locale.value = newLocale;
    Get.updateLocale(newLocale);
    _box.write(_keyLocale, newLocale.languageCode);
  }

  Future<void> clearAllData() async {
    await DatabaseHelper.instance.clearAll();
    Get.find<AccountController>().accounts.clear();
    Get.find<CategoryController>().categories.clear();
    Get.find<TransactionController>().transactions.clear();
    Get.snackbar(
      '',
      'data_cleared'.tr,
      snackPosition: SnackPosition.BOTTOM,
      titleText: const SizedBox.shrink(),
    );
  }

  Future<void> exportToCsv() async {
    final transactions = Get.find<TransactionController>().transactions;
    final categories = Get.find<CategoryController>().categories;
    final accounts = Get.find<AccountController>().accounts;

    final catMap = {for (final c in categories) c.id: c.name};
    final accMap = {for (final a in accounts) a.id: a.name};

    final rows = <List<dynamic>>[
      ['Date', 'Title', 'Type', 'Amount', 'Category', 'Account', 'Note'],
      ...transactions.map((t) => [
            t.date.toIso8601String(),
            t.title,
            t.type.name,
            t.amount,
            catMap[t.categoryId] ?? t.categoryId,
            accMap[t.accountId] ?? t.accountId,
            t.note ?? '',
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/monny_export_$timestamp.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Monny Export',
    );
  }

  ThemeMode _themeModeFromString(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Locale _localeFromCode(String code) => switch (code) {
        'id' => const Locale('id', 'ID'),
        _ => const Locale('en', 'US'),
      };
}
