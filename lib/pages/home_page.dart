import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:monny/controllers/controllers.dart';
import 'package:monny/models/models.dart';
import 'package:monny/utils/formatters.dart';
import 'package:monny/widgets/balance_card.dart';
import 'package:monny/widgets/income_expense_row.dart';
import 'package:monny/widgets/transaction_list_item.dart';
import 'package:monny/pages/add_transaction_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(textTheme: textTheme)),
            SliverToBoxAdapter(child: _BalanceSection()),
            SliverToBoxAdapter(child: _ThisMonthSection(textTheme: textTheme)),
            SliverToBoxAdapter(
              child: _SectionHeader(textTheme: textTheme),
            ),
            _RecentTransactionsList(textTheme: textTheme),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TextTheme textTheme;
  const _Header({required this.textTheme});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'greeting_morning'.tr;
    if (hour >= 12 && hour < 17) return 'greeting_afternoon'.tr;
    if (hour >= 17 && hour < 21) return 'greeting_evening'.tr;
    return 'greeting_night'.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatFullDate(DateTime.now()),
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accountCtrl = Get.find<AccountController>();
    return Obx(() {
      final total = accountCtrl.accounts
          .fold<double>(0, (sum, a) => sum + a.balance);
      return BalanceCard(balance: total);
    });
  }
}

class _ThisMonthSection extends StatelessWidget {
  final TextTheme textTheme;
  const _ThisMonthSection({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final txCtrl = Get.find<TransactionController>();
    final now = DateTime.now();

    return Obx(() {
      final monthTx = txCtrl.transactions.where((t) =>
          t.date.year == now.year && t.date.month == now.month);

      final income = monthTx
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);
      final expense = monthTx
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Text(
              '${'this_month'.tr} — ${DateFormat('MMMM yyyy', Get.locale?.languageCode ?? 'en').format(now)}',
              style: textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          IncomeExpenseRow(income: income, expense: expense),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final TextTheme textTheme;
  const _SectionHeader({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'recent_transactions'.tr,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {},
            child: Text('see_all'.tr),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsList extends StatelessWidget {
  final TextTheme textTheme;
  const _RecentTransactionsList({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final txCtrl = Get.find<TransactionController>();
    final categoryCtrl = Get.find<CategoryController>();

    return Obx(() {
      final recent = txCtrl.transactions.take(5).toList();

      if (recent.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'no_transactions'.tr,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        );
      }

      return SliverList.separated(
        itemCount: recent.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final tx = recent[index];
          final category = categoryCtrl.categories
              .firstWhereOrNull((c) => c.id == tx.categoryId);
          return TransactionListItem(
            transaction: tx,
            category: category,
            onTap: () => Get.to(
              () => AddTransactionPage(transaction: tx),
            ),
          );
        },
      );
    });
  }
}
