import 'package:get/get.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';
import 'account_controller.dart';

class TransactionController extends GetxController {
  final TransactionRepository _repo;
  final AccountController _accountController;

  TransactionController({
    TransactionRepository? repository,
    AccountController? accountController,
  })  : _repo = repository ?? TransactionRepository(),
        _accountController = accountController ?? Get.find<AccountController>();

  final transactions = <Transaction>[].obs;
  final isLoading = false.obs;

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    transactions.value = await _repo.getAll();
    isLoading.value = false;
  }

  Future<void> fetchByDateRange(DateTime from, DateTime to) async {
    isLoading.value = true;
    transactions.value = await _repo.getByDateRange(from, to);
    isLoading.value = false;
  }

  Future<void> add(Transaction transaction) async {
    await _repo.save(transaction);
    transactions.insert(0, transaction);
    await _accountController.syncBalance(transaction.accountId);
  }

  Future<void> edit(Transaction transaction) async {
    final old = transactions.firstWhereOrNull((t) => t.id == transaction.id);
    await _repo.update(transaction);
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) transactions[index] = transaction;
    await _accountController.syncBalance(transaction.accountId);
    if (old != null && old.accountId != transaction.accountId) {
      await _accountController.syncBalance(old.accountId);
    }
  }

  Future<void> delete(String id) async {
    final transaction = transactions.firstWhereOrNull((t) => t.id == id);
    await _repo.delete(id);
    transactions.removeWhere((t) => t.id == id);
    if (transaction != null) {
      await _accountController.syncBalance(transaction.accountId);
    }
  }
}
