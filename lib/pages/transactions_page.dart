import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:monny/controllers/controllers.dart';
import 'package:monny/models/models.dart';
import 'package:monny/widgets/transaction_list_item.dart';
import 'package:monny/pages/add_transaction_page.dart';

class _FilterState {
  TransactionType? type;
  Set<String> categoryIds;
  Set<String> accountIds;
  DateTime? dateFrom;
  DateTime? dateTo;
  _FilterState({
    this.type,
    Set<String>? categoryIds,
    Set<String>? accountIds,
    this.dateFrom,
    this.dateTo,
  })  : categoryIds = categoryIds ?? {},
        accountIds = accountIds ?? {};

  _FilterState copyWith({
    Object? type = _sentinel,
    Set<String>? categoryIds,
    Set<String>? accountIds,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
  }) =>
      _FilterState(
        type: type == _sentinel ? this.type : type as TransactionType?,
        categoryIds: categoryIds ?? Set.from(this.categoryIds),
        accountIds: accountIds ?? Set.from(this.accountIds),
        dateFrom: dateFrom == _sentinel ? this.dateFrom : dateFrom as DateTime?,
        dateTo: dateTo == _sentinel ? this.dateTo : dateTo as DateTime?,
      );

  int get activeCount =>
      (type != null ? 1 : 0) +
      (categoryIds.isNotEmpty ? 1 : 0) +
      (accountIds.isNotEmpty ? 1 : 0) +
      (dateFrom != null || dateTo != null ? 1 : 0);

  bool get isEmpty => activeCount == 0;
}

const _sentinel = Object();

class TransactionsPage extends StatefulWidget {
  final TransactionType? initialFilter;

  const TransactionsPage({super.key, this.initialFilter});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late _FilterState _filter;

  @override
  void initState() {
    super.initState();
    _filter = _FilterState(type: widget.initialFilter);
  }

  List<Transaction> _applyFilters(List<Transaction> all) {
    return all.where((t) {
      if (_filter.type != null && t.type != _filter.type) return false;
      if (_filter.categoryIds.isNotEmpty && !_filter.categoryIds.contains(t.categoryId)) return false;
      if (_filter.accountIds.isNotEmpty && !_filter.accountIds.contains(t.accountId)) return false;
      if (_filter.dateFrom != null && t.date.isBefore(_filter.dateFrom!)) return false;
      if (_filter.dateTo != null) {
        final endOfDay = DateTime(_filter.dateTo!.year, _filter.dateTo!.month, _filter.dateTo!.day, 23, 59, 59);
        if (t.date.isAfter(endOfDay)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_FilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(current: _filter),
    );
    if (result != null) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txCtrl = Get.find<TransactionController>();
    final categoryCtrl = Get.find<CategoryController>();
    final textTheme = Theme.of(context).textTheme;
    final activeCount = _filter.activeCount;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('recent_transactions'.tr),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: _openFilterSheet,
              ),
              if (activeCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$activeCount',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final filtered = _applyFilters(txCtrl.transactions.toList());

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              'no_transactions'.tr,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          );
        }

        final grouped = <String, List<Transaction>>{};
        for (final tx in filtered) {
          final key = DateFormat('yyyy-MM-dd').format(tx.date);
          grouped.putIfAbsent(key, () => []).add(tx);
        }
        final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: sortedKeys.length,
          itemBuilder: (context, sectionIndex) {
            final key = sortedKeys[sectionIndex];
            final items = grouped[key]!;
            final date = DateTime.parse(key);
            final dateLabel = DateFormat(
              'EEEE, d MMMM yyyy',
              Get.locale?.languageCode ?? 'en',
            ).format(date);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    dateLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                ...List.generate(items.length, (i) {
                  final tx = items[i];
                  final category = categoryCtrl.categories
                      .firstWhereOrNull((c) => c.id == tx.categoryId);
                  return Column(
                    children: [
                      TransactionListItem(
                        transaction: tx,
                        category: category,
                        onTap: () => Get.to(() => AddTransactionPage(transaction: tx)),
                      ),
                      if (i < items.length - 1)
                        const Divider(height: 1, indent: 72, endIndent: 16),
                    ],
                  );
                }),
              ],
            );
          },
        );
      }),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final _FilterState current;
  const _FilterSheet({required this.current});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _FilterState _local;

  @override
  void initState() {
    super.initState();
    _local = widget.current.copyWith();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom
        ? (_local.dateFrom ?? DateTime.now())
        : (_local.dateTo ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _local = isFrom
            ? _local.copyWith(dateFrom: picked)
            : _local.copyWith(dateTo: picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final categoryCtrl = Get.find<CategoryController>();
    final accountCtrl = Get.find<AccountController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                children: [
                  Text('filter'.tr, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _local = _FilterState();
                      });
                    },
                    child: Text('reset'.tr),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // --- Type ---
                  _SectionLabel(label: 'transaction_type'.tr, textTheme: textTheme),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _FilterChip(
                        label: 'all'.tr,
                        selected: _local.type == null,
                        onTap: () => setState(() {
                          _local = _local.copyWith(type: null);
                        }),
                      ),
                      _FilterChip(
                        label: 'income'.tr,
                        selected: _local.type == TransactionType.income,
                        onTap: () => setState(() {
                          final categoryCtrl = Get.find<CategoryController>();
                          final validIds = categoryCtrl.categories
                              .where((c) => c.type == TransactionType.income)
                              .map((c) => c.id)
                              .toSet();
                          _local = _local.copyWith(
                            type: TransactionType.income,
                            categoryIds: Set.from(_local.categoryIds.intersection(validIds)),
                          );
                        }),
                      ),
                      _FilterChip(
                        label: 'expense'.tr,
                        selected: _local.type == TransactionType.expense,
                        onTap: () => setState(() {
                          final categoryCtrl = Get.find<CategoryController>();
                          final validIds = categoryCtrl.categories
                              .where((c) => c.type == TransactionType.expense)
                              .map((c) => c.id)
                              .toSet();
                          _local = _local.copyWith(
                            type: TransactionType.expense,
                            categoryIds: Set.from(_local.categoryIds.intersection(validIds)),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Category ---
                  _SectionLabel(label: 'category'.tr, textTheme: textTheme),
                  const SizedBox(height: 8),
                  Obx(() {
                    final cats = _local.type == null
                        ? categoryCtrl.categories.toList()
                        : categoryCtrl.categories.where((c) => c.type == _local.type).toList();
                    if (cats.isEmpty) {
                      return Text('no_categories'.tr, style: textTheme.bodySmall);
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: cats.map((c) {
                        final selected = _local.categoryIds.contains(c.id);
                        return _FilterChip(
                          label: c.name,
                          selected: selected,
                          onTap: () {
                            final ids = Set<String>.from(_local.categoryIds);
                            selected ? ids.remove(c.id) : ids.add(c.id);
                            setState(() => _local = _local.copyWith(categoryIds: ids));
                          },
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),

                  // --- Account ---
                  _SectionLabel(label: 'account'.tr, textTheme: textTheme),
                  const SizedBox(height: 8),
                  Obx(() {
                    final accs = accountCtrl.accounts;
                    if (accs.isEmpty) {
                      return Text('no_accounts'.tr, style: textTheme.bodySmall);
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: accs.map((a) {
                        final selected = _local.accountIds.contains(a.id);
                        return _FilterChip(
                          label: a.name,
                          selected: selected,
                          onTap: () {
                            final ids = Set<String>.from(_local.accountIds);
                            selected ? ids.remove(a.id) : ids.add(a.id);
                            setState(() => _local = _local.copyWith(accountIds: ids));
                          },
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),

                  // --- Date range ---
                  _SectionLabel(label: 'date_range'.tr, textTheme: textTheme),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: 'date_from'.tr,
                          date: _local.dateFrom,
                          onTap: () => _pickDate(isFrom: true),
                          onClear: _local.dateFrom != null
                              ? () => setState(() => _local = _local.copyWith(dateFrom: null))
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateButton(
                          label: 'date_to'.tr,
                          date: _local.dateTo,
                          onTap: () => _pickDate(isFrom: false),
                          onClear: _local.dateTo != null
                              ? () => setState(() => _local = _local.copyWith(dateTo: null))
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _local),
                  child: Text('apply'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final TextTheme textTheme;
  const _SectionLabel({required this.label, required this.textTheme});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.onPrimary : colors.onSurface,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  const _DateButton({required this.label, required this.date, required this.onTap, this.onClear});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasDate = date != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: hasDate ? colors.primary : colors.outline),
          borderRadius: BorderRadius.circular(12),
          color: hasDate ? colors.primary.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: hasDate ? colors.primary : colors.outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasDate ? DateFormat('d MMM yyyy').format(date!) : label,
                style: textTheme.bodySmall?.copyWith(
                  color: hasDate ? colors.primary : colors.outline,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 16, color: colors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
