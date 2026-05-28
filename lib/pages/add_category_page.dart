import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:monny/controllers/category_controller.dart';
import 'package:monny/models/models.dart';
import 'package:monny/utils/picker_options.dart';
import 'package:monny/widgets/color_picker_row.dart';
import 'package:monny/widgets/type_toggle.dart';

class AddCategoryPage extends StatefulWidget {
  final Category? category;
  const AddCategoryPage({super.key, this.category});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  int _colorValue = kPickerColors.first.toARGB32();
  int _iconCodePoint = kPickerIcons.first;
  bool _saving = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    if (c != null) {
      _nameCtrl.text = c.name;
      _type = c.type;
      _colorValue = c.colorValue;
      _iconCodePoint = c.iconCodePoint;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final category = Category(
      id: _isEditing
          ? widget.category!.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      type: _type,
      colorValue: _colorValue,
      iconCodePoint: _iconCodePoint,
    );

    final ctrl = Get.find<CategoryController>();
    _isEditing ? await ctrl.edit(category) : await ctrl.add(category);
    Get.back();
  }

  void _confirmDelete() {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_category'.tr),
        content: Text('delete_category_confirm'.tr),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('cancel'.tr)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await Get.find<CategoryController>().delete(widget.category!.id);
              Get.back();
            },
            child: Text('delete'.tr,
                style: TextStyle(color: colors.onError)),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('pick_icon'.tr,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
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
            icon: const Icon(Icons.close), onPressed: () => Get.back()),
        title: Text(_isEditing ? 'edit_category'.tr : 'add_category'.tr),
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
          padding: const EdgeInsets.all(16),
          children: [
            // ── Type toggle ──────────────────────────────────────
            TypeToggle(
              value: _type,
              onChanged: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: 20),

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
              child: Text('pick_icon'.tr,
                  style: TextStyle(color: colors.outline, fontSize: 12)),
            ),
            const SizedBox(height: 20),

            // ── Name ─────────────────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'category_name'.tr,
                hintText: 'category_name_hint'.tr,
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
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'title_required'.tr
                  : null,
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
}
