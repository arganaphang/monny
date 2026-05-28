import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:monny/controllers/category_controller.dart';
import 'package:monny/models/models.dart';
import 'package:monny/pages/add_category_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('categories'.tr),
          bottom: TabBar(
            tabs: [
              Tab(text: 'expense'.tr),
              Tab(text: 'income'.tr),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(() => const AddCategoryPage()),
          child: const Icon(Icons.add),
        ),
        body: const TabBarView(
          children: [
            _CategoryList(type: TransactionType.expense),
            _CategoryList(type: TransactionType.income),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final TransactionType type;
  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CategoryController>();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final items = ctrl.categories
          .where((c) => c.type == type)
          .toList();

      if (items.isEmpty) {
        return Center(
          child: Text('no_categories'.tr,
              style:
                  textTheme.bodyMedium?.copyWith(color: colors.outline)),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _CategoryTile(category: items[i]),
      );
    });
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = Color(category.colorValue);

    return ListTile(
      tileColor: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'), // ignore: non_const_argument_for_const_parameter
          color: accent,
          size: 20,
        ),
      ),
      title: Text(category.name,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () => Get.to(() => AddCategoryPage(category: category)),
    );
  }
}
