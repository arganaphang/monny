import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:monny/controllers/dashboard_controller.dart';

class SpendingBarChart extends StatelessWidget {
  const SpendingBarChart({super.key});

  static const _incomeColor = Color(0xFF2ECC71);
  static const _expenseColor = Color(0xFFE74C3C);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Obx(() {
      final data = ctrl.chartData;
      final labels = ctrl.chartLabels;

      if (data.isEmpty) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text('no_data'.tr,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colors.outline)),
          ),
        );
      }

      final maxY = data.values.fold<double>(
            0,
            (m, v) => [m, v.$1, v.$2].reduce((a, b) => a > b ? a : b),
          ) *
          1.2;

      final barGroups = List.generate(labels.length, (i) {
        final pair = data[i] ?? (0.0, 0.0);
        return BarChartGroupData(
          x: i,
          barsSpace: 3,
          barRods: [
            BarChartRodData(
              toY: pair.$1,
              color: _incomeColor,
              width: 7,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: pair.$2,
              color: _expenseColor,
              width: 7,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4)),
            ),
          ],
        );
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                _LegendDot(color: _incomeColor,
                    label: 'income'.tr),
                const SizedBox(width: 16),
                _LegendDot(color: _expenseColor,
                    label: 'expense'.tr),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: colors.outlineVariant,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (value, _) => Text(
                          _formatAxis(value),
                          style: textTheme.labelSmall
                              ?.copyWith(color: colors.outline),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              labels[i],
                              style: textTheme.labelSmall
                                  ?.copyWith(color: colors.outline),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          colors.surfaceContainerHighest,
                      getTooltipItem: (group, _, rod, rodIndex) {
                        final label = rodIndex == 0
                            ? 'income'.tr
                            : 'expense'.tr;
                        return BarTooltipItem(
                          '$label\n${_formatAxis(rod.toY)}',
                          TextStyle(
                            color: rod.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  String _formatAxis(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
