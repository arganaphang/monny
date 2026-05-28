import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../models/models.dart';
import '../utils/formatters.dart';

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Obx(() {
      final items = ctrl.topExpenseCategories;

      if (items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('no_data'.tr,
                style:
                    textTheme.bodyMedium?.copyWith(color: colors.outline)),
          ),
        );
      }

      final maxAmount = items.first.$2;

      return Column(
        children: items
            .map((item) => _CategoryItem(
                  category: item.$1,
                  amount: item.$2,
                  fraction: item.$2 / maxAmount,
                ))
            .toList(),
      );
    });
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final double amount;
  final double fraction;

  const _CategoryItem({
    required this.category,
    required this.amount,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final categoryColor = Color(category.colorValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(category.iconCodePoint, // ignore: non_const_argument_for_const_parameter
                  fontFamily: 'MaterialIcons'),
              color: categoryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category.name,
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(formatCurrency(amount),
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: colors.surfaceContainerHighest,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(categoryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
