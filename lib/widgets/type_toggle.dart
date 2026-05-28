import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/transaction_type.dart';

class TypeToggle extends StatelessWidget {
  final TransactionType value;
  final void Function(TransactionType) onChanged;

  const TypeToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TransactionType.values.map((type) {
          final selected = value == type;
          final isIncome = type == TransactionType.income;
          const incomeColor = Color(0xFF43A047);
          const expenseColor = Color(0xFFE53935);
          final activeColor = isIncome ? incomeColor : expenseColor;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color:
                          selected ? Colors.white : colors.onSurfaceVariant,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isIncome ? 'income'.tr : 'expense'.tr,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : colors.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
