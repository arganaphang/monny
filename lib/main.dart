import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:monny/controllers/controllers.dart';
import 'package:monny/l10n/translations.dart';
import 'package:monny/pages/add_transaction_page.dart';
import 'package:monny/pages/dashboard_page.dart';
import 'package:monny/pages/home_page.dart';
import 'package:monny/pages/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting();
  _registerControllers();
  runApp(const Application());
}

void _registerControllers() {
  Get.put(AccountController());
  Get.put(CategoryController());
  Get.put(TransactionController());
  Get.put(DashboardController());
  Get.put(SettingsController());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Monny',
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF212121),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFEEEEEE),
          onPrimaryContainer: Color(0xFF212121),
          secondary: Color(0xFF757575),
          onSecondary: Colors.white,
          tertiary: Color(0xFF9E9E9E),
          surface: Colors.white,
          onSurface: Color(0xFF212121),
          surfaceContainerLow: Color(0xFFF5F5F5),
          surfaceContainerHighest: Color(0xFFEEEEEE),
          outline: Color(0xFF9E9E9E),
          outlineVariant: Color(0xFFE0E0E0),
          error: Color(0xFFE53935),
          onError: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Color(0xFF212121),
          primaryContainer: Color(0xFF424242),
          onPrimaryContainer: Colors.white,
          secondary: Color(0xFFBDBDBD),
          onSecondary: Color(0xFF212121),
          tertiary: Color(0xFF757575),
          surface: Color(0xFF121212),
          onSurface: Colors.white,
          surfaceContainerLow: Color(0xFF1E1E1E),
          surfaceContainerHighest: Color(0xFF2C2C2C),
          outline: Color(0xFF616161),
          outlineVariant: Color(0xFF424242),
          error: Color(0xFFEF5350),
          onError: Colors.white,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    DashboardPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddTransactionPage()),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'nav_home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined),
            activeIcon: const Icon(Icons.bar_chart),
            label: 'nav_dashboard'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: 'nav_settings'.tr,
          ),
        ],
      ),
    );
  }
}
