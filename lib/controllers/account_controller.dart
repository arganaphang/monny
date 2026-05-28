import 'package:get/get.dart';

import 'package:monny/models/models.dart';
import 'package:monny/repositories/repositories.dart';

class AccountController extends GetxController {
  final AccountRepository _repo;

  AccountController({AccountRepository? repository})
      : _repo = repository ?? AccountRepository();

  final accounts = <Account>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    accounts.value = await _repo.getAll();
    isLoading.value = false;
  }

  Future<void> add(Account account) async {
    await _repo.save(account);
    accounts.add(account);
  }

  Future<void> edit(Account account) async {
    await _repo.update(account);
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) accounts[index] = account;
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    accounts.removeWhere((a) => a.id == id);
  }

  Future<void> syncBalance(String id) async {
    final account = await _repo.getById(id);
    if (account == null) return;
    final index = accounts.indexWhere((a) => a.id == id);
    if (index != -1) accounts[index] = account;
  }
}
