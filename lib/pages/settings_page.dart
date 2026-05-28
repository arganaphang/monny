import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../utils/picker_options.dart';
import 'accounts_page.dart';
import 'categories_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'settings_title'.tr,
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _ManageSection()),
            SliverToBoxAdapter(child: _AppearanceSection()),
            SliverToBoxAdapter(child: _DataSection()),
            SliverToBoxAdapter(child: _AboutSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

// ─── Manage ───────────────────────────────────────────────────────────────────

class _ManageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'manage'.tr,
      children: [
        _SettingsTile(
          icon: Icons.account_balance_wallet_outlined,
          title: 'accounts'.tr,
          onTap: () => Get.to(() => const AccountsPage()),
        ),
        _SettingsTile(
          icon: Icons.category_outlined,
          title: 'categories'.tr,
          showDivider: false,
          onTap: () => Get.to(() => const CategoriesPage()),
        ),
      ],
    );
  }
}

// ─── Appearance ──────────────────────────────────────────────────────────────

class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();

    return _Section(
      title: 'appearance'.tr,
      children: [
        Obx(() => _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'theme'.tr,
              subtitle: _themeModeLabel(ctrl.themeMode.value),
              onTap: () => _showThemePicker(context, ctrl),
            )),
        Obx(() => _SettingsTile(
              icon: Icons.language_outlined,
              title: 'language'.tr,
              subtitle: _localeLabel(ctrl.locale.value.languageCode),
              onTap: () => _showLanguagePicker(context, ctrl),
            )),
        Obx(() => _SettingsTile(
              icon: Icons.attach_money_outlined,
              title: 'currency_symbol'.tr,
              subtitle: ctrl.currencySymbol.value,
              onTap: () => _showCurrencyPicker(context, ctrl),
              showDivider: false,
            )),
      ],
    );
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'theme_light'.tr,
        ThemeMode.dark => 'theme_dark'.tr,
        ThemeMode.system => 'theme_system'.tr,
      };

  String _localeLabel(String code) =>
      code == 'id' ? 'Bahasa Indonesia' : 'English';

  void _showThemePicker(BuildContext context, SettingsController ctrl) {
    _showPickerSheet(
      context: context,
      title: 'theme'.tr,
      items: [
        (Icons.light_mode_outlined, 'theme_light'.tr, ThemeMode.light),
        (Icons.dark_mode_outlined, 'theme_dark'.tr, ThemeMode.dark),
        (Icons.brightness_auto_outlined, 'theme_system'.tr, ThemeMode.system),
      ],
      isSelected: (mode) => ctrl.themeMode.value == mode,
      onSelect: (mode) => ctrl.setThemeMode(mode),
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsController ctrl) {
    _showPickerSheet(
      context: context,
      title: 'currency_symbol'.tr,
      items: kCurrencyOptions
          .map((e) => (Icons.attach_money_outlined, '${e.$1}  —  ${e.$2}', e.$1))
          .toList(),
      isSelected: (symbol) => ctrl.currencySymbol.value == symbol,
      onSelect: (symbol) => ctrl.setCurrencySymbol(symbol),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsController ctrl) {
    _showPickerSheet(
      context: context,
      title: 'language'.tr,
      items: [
        (Icons.flag_outlined, 'English', const Locale('en', 'US')),
        (Icons.flag_outlined, 'Bahasa Indonesia', const Locale('id', 'ID')),
      ],
      isSelected: (locale) =>
          ctrl.locale.value.languageCode == locale.languageCode,
      onSelect: (locale) => ctrl.setLocale(locale),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _DataSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();
    final colors = Theme.of(context).colorScheme;

    return _Section(
      title: 'data'.tr,
      children: [
        _SettingsTile(
          icon: Icons.download_outlined,
          title: 'export_csv'.tr,
          subtitle: 'export_csv_subtitle'.tr,
          onTap: () => ctrl.exportToCsv(),
        ),
        _SettingsTile(
          icon: Icons.delete_outline,
          title: 'clear_data'.tr,
          subtitle: 'clear_data_subtitle'.tr,
          iconColor: colors.error,
          titleColor: colors.error,
          showDivider: false,
          onTap: () => _showClearDataDialog(context, ctrl),
        ),
      ],
    );
  }

  void _showClearDataDialog(BuildContext context, SettingsController ctrl) {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('clear_data_confirm_title'.tr),
        content: Text('clear_data_confirm_body'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.clearAllData();
            },
            child: Text('delete'.tr,
                style: TextStyle(color: colors.onError)),
          ),
        ],
      ),
    );
  }
}

// ─── About ────────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();

    return _Section(
      title: 'about'.tr,
      children: [
        _SettingsTile(
          icon: Icons.info_outline,
          title: 'app_title'.tr,
          subtitle: 'Monny — Personal Money Manager',
          onTap: null,
        ),
        Obx(() => _SettingsTile(
              icon: Icons.tag_outlined,
              title: 'app_version'.tr,
              subtitle: ctrl.appVersion.value.isEmpty
                  ? '—'
                  : ctrl.appVersion.value,
              showDivider: false,
              onTap: null,
            )),
      ],
    );
  }
}

// ─── Shared components ────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showDivider;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? colors.onSurfaceVariant;
    final effectiveTitleColor = titleColor ?? colors.onSurface;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: effectiveIconColor, size: 22),
          title: Text(title,
              style: TextStyle(color: effectiveTitleColor, fontSize: 15)),
          subtitle: subtitle != null
              ? Text(subtitle!,
                  style: TextStyle(
                      color: colors.outline, fontSize: 13))
              : null,
          trailing: onTap != null
              ? Icon(Icons.chevron_right,
                  color: colors.outlineVariant, size: 20)
              : null,
          onTap: onTap,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

// ─── Generic picker bottom sheet ─────────────────────────────────────────────

void _showPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<(IconData, String, T)> items,
  required bool Function(T) isSelected,
  required void Function(T) onSelect,
}) {
  final colors = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(title,
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            ...items.map((item) {
              final (icon, label, value) = item;
              final selected = isSelected(value);
              return ListTile(
                leading: Icon(icon,
                    color: selected ? colors.primary : colors.onSurfaceVariant),
                title: Text(label,
                    style: TextStyle(
                        color: selected ? colors.primary : colors.onSurface,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal)),
                trailing: selected
                    ? Icon(Icons.check, color: colors.primary)
                    : null,
                onTap: () {
                  onSelect(value);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    ),
  );
}
