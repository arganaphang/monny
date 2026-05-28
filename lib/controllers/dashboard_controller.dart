import 'package:get/get.dart';

import '../models/models.dart';
import 'transaction_controller.dart';
import 'category_controller.dart';

enum DashboardPeriod { week, month, year }

class DashboardController extends GetxController {
  final _txCtrl = Get.find<TransactionController>();
  final _catCtrl = Get.find<CategoryController>();

  final selectedPeriod = DashboardPeriod.month.obs;

  List<Transaction> get periodTransactions {
    final now = DateTime.now();
    return _txCtrl.transactions.where((t) {
      switch (selectedPeriod.value) {
        case DashboardPeriod.week:
          final startOfWeek =
              now.subtract(Duration(days: now.weekday - 1));
          final start = DateTime(
              startOfWeek.year, startOfWeek.month, startOfWeek.day);
          final end = start.add(const Duration(days: 7));
          return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(end);
        case DashboardPeriod.month:
          return t.date.year == now.year && t.date.month == now.month;
        case DashboardPeriod.year:
          return t.date.year == now.year;
      }
    }).toList();
  }

  double get periodIncome => periodTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (s, t) => s + t.amount);

  double get periodExpense => periodTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (s, t) => s + t.amount);

  // Returns [x-index → (income, expense)] for bar chart
  Map<int, (double, double)> get chartData {
    final groups = <int, (double, double)>{};

    for (final t in periodTransactions) {
      final x = _xIndex(t.date);
      final current = groups[x] ?? (0.0, 0.0);
      if (t.type == TransactionType.income) {
        groups[x] = (current.$1 + t.amount, current.$2);
      } else {
        groups[x] = (current.$1, current.$2 + t.amount);
      }
    }
    return groups;
  }

  // Returns x-axis labels for the current period
  List<String> get chartLabels {
    switch (selectedPeriod.value) {
      case DashboardPeriod.week:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case DashboardPeriod.month:
        return ['W1', 'W2', 'W3', 'W4', 'W5'];
      case DashboardPeriod.year:
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    }
  }

  // Returns top expense categories: [(category, total)]
  List<(Category, double)> get topExpenseCategories {
    final totals = <String, double>{};
    for (final t in periodTransactions
        .where((t) => t.type == TransactionType.expense)) {
      totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    }

    final result = totals.entries.map((e) {
      final cat =
          _catCtrl.categories.firstWhereOrNull((c) => c.id == e.key);
      return cat != null ? (cat, e.value) : null;
    }).whereType<(Category, double)>().toList();

    result.sort((a, b) => b.$2.compareTo(a.$2));
    return result.take(5).toList();
  }

  int _xIndex(DateTime date) {
    switch (selectedPeriod.value) {
      case DashboardPeriod.week:
        return date.weekday - 1; // 0=Mon … 6=Sun
      case DashboardPeriod.month:
        return ((date.day - 1) ~/ 7).clamp(0, 4); // 0–4 weeks
      case DashboardPeriod.year:
        return date.month - 1; // 0=Jan … 11=Dec
    }
  }
}
