import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/income_expense_row.dart';
import '../widgets/period_selector.dart';
import '../widgets/spending_bar_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text(
                  'dashboard_title'.tr,
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: PeriodSelector()),
            SliverToBoxAdapter(child: _SummarySection()),
            SliverToBoxAdapter(
              child: _SectionTitle(
                  textTheme: textTheme,
                  title: 'spending_overview'.tr),
            ),
            const SliverToBoxAdapter(child: SpendingBarChart()),
            SliverToBoxAdapter(
              child: _SectionTitle(
                  textTheme: textTheme,
                  title: 'top_categories'.tr),
            ),
            const SliverToBoxAdapter(child: CategoryBreakdown()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: IncomeExpenseRow(
            income: ctrl.periodIncome,
            expense: ctrl.periodExpense,
          ),
        ));
  }
}

class _SectionTitle extends StatelessWidget {
  final TextTheme textTheme;
  final String title;
  const _SectionTitle({required this.textTheme, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style:
            textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
