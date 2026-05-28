import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:monny/controllers/dashboard_controller.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();
    final colors = Theme.of(context).colorScheme;

    final labels = {
      DashboardPeriod.week: 'period_week'.tr,
      DashboardPeriod.month: 'period_month'.tr,
      DashboardPeriod.year: 'period_year'.tr,
    };

    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: DashboardPeriod.values.map((period) {
              final selected = ctrl.selectedPeriod.value == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.selectedPeriod.value = period,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? colors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      labels[period]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}
