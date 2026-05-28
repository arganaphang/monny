import 'package:get/get.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repo;

  CategoryController({CategoryRepository? repository})
      : _repo = repository ?? CategoryRepository();

  final categories = <Category>[].obs;
  final isLoading = false.obs;

  List<Category> get incomeCategories =>
      categories.where((c) => c.type == TransactionType.income).toList();

  List<Category> get expenseCategories =>
      categories.where((c) => c.type == TransactionType.expense).toList();

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    categories.value = await _repo.getAll();
    isLoading.value = false;
  }

  Future<void> add(Category category) async {
    await _repo.save(category);
    categories.add(category);
  }

  Future<void> edit(Category category) async {
    await _repo.update(category);
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) categories[index] = category;
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    categories.removeWhere((c) => c.id == id);
  }
}
