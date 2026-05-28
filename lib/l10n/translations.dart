import 'package:get/get.dart';
import 'package:monny/l10n/app_en.dart';
import 'package:monny/l10n/app_id.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en,
        'id_ID': id,
      };
}
