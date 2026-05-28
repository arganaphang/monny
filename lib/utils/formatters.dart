import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/settings_controller.dart';

String get _locale => Get.locale?.toLanguageTag() ?? 'en';

String get _currencySymbol {
  if (Get.isRegistered<SettingsController>()) {
    return '${Get.find<SettingsController>().currencySymbol.value} ';
  }
  return 'Rp ';
}

String formatCurrency(double amount) => NumberFormat.currency(
      locale: _locale,
      symbol: _currencySymbol,
      decimalDigits: 0,
    ).format(amount);

String formatShortDate(DateTime date) =>
    DateFormat('d MMM', _locale).format(date);

String formatFullDate(DateTime date) =>
    DateFormat('EEEE, d MMMM yyyy', _locale).format(date);
