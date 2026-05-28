import '../database/database.dart';
import '../models/models.dart';

class AccountRepository {
  final AccountDao _dao;

  AccountRepository({AccountDao? dao}) : _dao = dao ?? AccountDao();

  Future<List<Account>> getAll() => _dao.getAll();

  Future<Account?> getById(String id) => _dao.getById(id);

  Future<void> save(Account account) => _dao.insert(account);

  Future<void> update(Account account) => _dao.update(account);

  Future<void> delete(String id) => _dao.delete(id);

  Future<void> updateBalance(String id, double newBalance) async {
    final account = await _dao.getById(id);
    if (account == null) return;
    await _dao.update(account.copyWith(balance: newBalance));
  }
}
