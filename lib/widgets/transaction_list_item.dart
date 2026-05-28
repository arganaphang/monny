import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/formatters.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isIncome = transaction.type == TransactionType.income;
    final amountColor =
        isIncome ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    final iconColor =
        category != null ? Color(category!.colorValue) : Colors.grey;
    final iconData = category != null
        ? IconData(category!.iconCodePoint, fontFamily: 'MaterialIcons') // ignore: non_const_argument_for_const_parameter
        : Icons.receipt_long;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, color: iconColor, size: 20),
      ),
      title: Text(
        transaction.title,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        category?.name ?? formatShortDate(transaction.date),
        style: textTheme.labelSmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isIncome ? '+' : '-'} ${formatCurrency(transaction.amount)}',
            style: textTheme.bodyMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatShortDate(transaction.date),
            style: textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
