import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';
import '../utils/formatters.dart';
import '../widgets/type_toggle.dart';

class AddTransactionPage extends StatefulWidget {
  final Transaction? transaction;
  const AddTransactionPage({super.key, this.transaction});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  String? _accountId;
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _type = tx.type;
      _categoryId = tx.categoryId;
      _accountId = tx.accountId;
      _date = tx.date;
      final amt = tx.amount % 1 == 0
          ? tx.amount.toInt().toString()
          : tx.amount.toString();
      _amountCtrl.text = amt;
      _titleCtrl.text = tx.title;
      _noteCtrl.text = tx.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Category? get _selectedCategory => Get.find<CategoryController>()
      .categories
      .firstWhereOrNull((c) => c.id == _categoryId);

  Account? get _selectedAccount => Get.find<AccountController>()
      .accounts
      .firstWhereOrNull((a) => a.id == _accountId);

  List<Category> get _filteredCategories => Get.find<CategoryController>()
      .categories
      .where((c) => c.type == _type)
      .toList();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      _snack('category_required'.tr);
      return;
    }
    if (_accountId == null) {
      _snack('account_required'.tr);
      return;
    }

    setState(() => _saving = true);

    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;

    final tx = Transaction(
      id: _isEditing
          ? widget.transaction!.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      amount: amount,
      type: _type,
      categoryId: _categoryId!,
      accountId: _accountId!,
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    final ctrl = Get.find<TransactionController>();
    if (_isEditing) {
      await ctrl.edit(tx);
    } else {
      await ctrl.add(tx);
    }
    Get.back();
  }

  void _confirmDelete() {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_transaction'.tr),
        content: Text('delete_transaction_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await Get.find<TransactionController>()
                  .delete(widget.transaction!.id);
              Get.back();
            },
            child: Text('delete'.tr,
                style: TextStyle(color: colors.onError)),
          ),
        ],
      ),
    );
  }

  void _snack(String message) => Get.snackbar(
        '',
        message,
        snackPosition: SnackPosition.BOTTOM,
        titleText: const SizedBox.shrink(),
        margin: const EdgeInsets.all(16),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _showCategoryPicker() {
    _showPicker(
      title: 'category'.tr,
      children: _filteredCategories.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                    child: Text('no_data'.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline))),
              ),
            ]
          : _filteredCategories
              .map(
                (cat) => ListTile(
                  leading: _ModelIcon(
                      colorValue: cat.colorValue,
                      codePoint: cat.iconCodePoint),
                  title: Text(cat.name),
                  trailing: _categoryId == cat.id
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _categoryId = cat.id);
                    Get.back();
                  },
                ),
              )
              .toList(),
    );
  }

  void _showAccountPicker() {
    final accounts = Get.find<AccountController>().accounts;
    _showPicker(
      title: 'account'.tr,
      children: accounts.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                    child: Text('no_data'.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline))),
              ),
            ]
          : accounts
              .map(
                (acc) => ListTile(
                  leading: _ModelIcon(
                      colorValue: acc.colorValue,
                      codePoint: acc.iconCodePoint),
                  title: Text(acc.name),
                  subtitle: Text(formatCurrency(acc.balance)),
                  trailing: _accountId == acc.id
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _accountId = acc.id);
                    Get.back();
                  },
                ),
              )
              .toList(),
    );
  }

  void _showPicker({
    required String title,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Flexible(child: ListView(shrinkWrap: true, children: children)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        title: Text(_isEditing ? 'edit_transaction'.tr : 'add_transaction'.tr),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: _confirmDelete,
            ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _submit,
              child: Text('save'.tr,
                  style: TextStyle(
                      color: colors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ── Type toggle ──────────────────────────────────────
            TypeToggle(
              value: _type,
              onChanged: (t) => setState(() {
                _type = t;
                _categoryId = null;
              }),
            ),
            const SizedBox(height: 24),

            // ── Amount ───────────────────────────────────────────
            _AmountInput(controller: _amountCtrl),
            const SizedBox(height: 20),

            // ── Title ────────────────────────────────────────────
            _InputField(
              controller: _titleCtrl,
              label: 'transaction_title'.tr,
              hint: 'transaction_title_hint'.tr,
              icon: Icons.title_outlined,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'title_required'.tr
                  : null,
            ),
            const SizedBox(height: 12),

            // ── Category ─────────────────────────────────────────
            _PickerRow(
              icon: _selectedCategory != null
                  ? IconData(_selectedCategory!.iconCodePoint, // ignore: non_const_argument_for_const_parameter
                      fontFamily: 'MaterialIcons')
                  : Icons.category_outlined,
              iconColor: _selectedCategory != null
                  ? Color(_selectedCategory!.colorValue)
                  : colors.outline,
              label: 'category'.tr,
              value: _selectedCategory?.name,
              placeholder: 'select_category'.tr,
              onTap: _showCategoryPicker,
            ),
            const SizedBox(height: 12),

            // ── Account ──────────────────────────────────────────
            _PickerRow(
              icon: _selectedAccount != null
                  ? IconData(_selectedAccount!.iconCodePoint, // ignore: non_const_argument_for_const_parameter
                      fontFamily: 'MaterialIcons')
                  : Icons.account_balance_wallet_outlined,
              iconColor: _selectedAccount != null
                  ? Color(_selectedAccount!.colorValue)
                  : colors.outline,
              label: 'account'.tr,
              value: _selectedAccount?.name,
              placeholder: 'select_account'.tr,
              onTap: _showAccountPicker,
            ),
            const SizedBox(height: 12),

            // ── Date ─────────────────────────────────────────────
            _PickerRow(
              icon: Icons.calendar_today_outlined,
              iconColor: colors.primary,
              label: 'date'.tr,
              value: formatShortDate(_date),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),

            // ── Note ─────────────────────────────────────────────
            _InputField(
              controller: _noteCtrl,
              label: 'note'.tr,
              hint: 'note_hint'.tr,
              icon: Icons.notes_outlined,
              maxLines: 3,
              required: false,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Amount input ─────────────────────────────────────────────────────────────

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  const _AmountInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final symbol = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().currencySymbol.value
        : 'Rp';

    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
      ],
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: colors.onSurface,
        letterSpacing: -1,
      ),
      decoration: InputDecoration(
        prefixText: '$symbol ',
        prefixStyle: TextStyle(
          fontSize: 24,
          color: colors.outline,
          fontWeight: FontWeight.w500,
        ),
        hintText: '0',
        hintStyle: TextStyle(
          fontSize: 40,
          color: colors.outlineVariant,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
        errorStyle: const TextStyle(fontSize: 12),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'amount_required'.tr;
        final val = double.tryParse(v.replaceAll(',', '.'));
        if (val == null || val <= 0) return 'amount_invalid'.tr;
        return null;
      },
    );
  }
}

// ─── Text input field ─────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final int maxLines;
  final bool required;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.maxLines = 1,
    this.required = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: colors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty)
                  ? 'title_required'.tr
                  : null
              : null),
    );
  }
}

// ─── Picker row ───────────────────────────────────────────────────────────────

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;

  const _PickerRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasValue = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: colors.outline)),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? value! : (placeholder ?? ''),
                    style: TextStyle(
                      color: hasValue
                          ? colors.onSurface
                          : colors.outlineVariant,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.outlineVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Shared icon widget ───────────────────────────────────────────────────────

class _ModelIcon extends StatelessWidget {
  final int colorValue;
  final int codePoint;

  const _ModelIcon({required this.colorValue, required this.codePoint});

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        IconData(codePoint, fontFamily: 'MaterialIcons'), // ignore: non_const_argument_for_const_parameter
        color: color,
        size: 18,
      ),
    );
  }
}
