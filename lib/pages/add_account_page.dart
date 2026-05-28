import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/account_controller.dart';
import '../models/models.dart';
import '../utils/picker_options.dart';
import '../widgets/color_picker_row.dart';

class AddAccountPage extends StatefulWidget {
  final Account? account;
  const AddAccountPage({super.key, this.account});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();

  AccountType _accountType = AccountType.cash;
  int _colorValue = kPickerColors.first.toARGB32();
  int _iconCodePoint = kPickerIcons.first;
  bool _saving = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    if (a != null) {
      _nameCtrl.text = a.name;
      _balanceCtrl.text = a.balance % 1 == 0
          ? a.balance.toInt().toString()
          : a.balance.toString();
      _accountType = a.type;
      _colorValue = a.colorValue;
      _iconCodePoint = a.iconCodePoint;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final balance =
        double.tryParse(_balanceCtrl.text.replaceAll(',', '.')) ?? 0;
    final account = Account(
      id: _isEditing
          ? widget.account!.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      balance: balance,
      type: _accountType,
      colorValue: _colorValue,
      iconCodePoint: _iconCodePoint,
    );

    final ctrl = Get.find<AccountController>();
    _isEditing ? await ctrl.edit(account) : await ctrl.add(account);
    Get.back();
  }

  void _confirmDelete() {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_account'.tr),
        content: Text('delete_account_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await Get.find<AccountController>().delete(widget.account!.id);
              Get.back();
            },
            child: Text('delete'.tr, style: TextStyle(color: colors.onError)),
          ),
        ],
      ),
    );
  }

  void _showIconPicker() {
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
              child: Text(
                'pick_icon'.tr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: kPickerIcons.length,
                itemBuilder: (_, i) {
                  final cp = kPickerIcons[i];
                  final selected = cp == _iconCodePoint;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _iconCodePoint = cp);
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? colors.primary.withValues(alpha: 0.12)
                            : colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? Border.all(color: colors.primary, width: 2)
                            : null,
                      ),
                      child: Icon(
                        IconData(cp, fontFamily: 'MaterialIcons'), // ignore: non_const_argument_for_const_parameter
                        size: 22,
                        color: selected
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = Color(_colorValue);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        title: Text(_isEditing ? 'edit_account'.tr : 'add_account'.tr),
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
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: Text(
                'save'.tr,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Icon preview ─────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _showIconPicker,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconData(_iconCodePoint, fontFamily: 'MaterialIcons'), // ignore: non_const_argument_for_const_parameter
                    color: accent,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'pick_icon'.tr,
                style: TextStyle(color: colors.outline, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),

            // ── Name ─────────────────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                colors,
                'account_name'.tr,
                'account_name_hint'.tr,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'title_required'.tr : null,
            ),
            const SizedBox(height: 12),

            // ── Balance ──────────────────────────────────────────
            TextFormField(
              controller: _balanceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              decoration: _inputDecoration(colors, 'initial_balance'.tr, '0'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'amount_required'.tr;
                if (double.tryParse(v.replaceAll(',', '.')) == null) {
                  return 'amount_invalid'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Account type ─────────────────────────────────────
            Text(
              'account_type'.tr,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.outline),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AccountType.values.map((type) {
                final selected = _accountType == type;
                return ChoiceChip(
                  label: Text(_accountTypeLabel(type)),
                  selected: selected,
                  onSelected: (_) => setState(() => _accountType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Color picker ──────────────────────────────────────
            ColorPickerRow(
              selectedColorValue: _colorValue,
              onChanged: (v) => setState(() => _colorValue = v),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _accountTypeLabel(AccountType type) => switch (type) {
    AccountType.cash => 'account_type_cash'.tr,
    AccountType.bank => 'account_type_bank'.tr,
    AccountType.eWallet => 'account_type_ewallet'.tr,
    AccountType.other => 'account_type_other'.tr,
  };

  InputDecoration _inputDecoration(
    ColorScheme colors,
    String label,
    String hint,
  ) => InputDecoration(
    labelText: label,
    hintText: hint,
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
  );
}
