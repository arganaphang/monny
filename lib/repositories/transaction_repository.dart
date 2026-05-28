import '../database/database.dart';
import '../models/models.dart';
import 'account_repository.dart';

class TransactionRepository {
  final TransactionDao _dao;
  final AccountRepository _accountRepository;

  TransactionRepository({
    TransactionDao? dao,
    AccountRepository? accountRepository,
  })  : _dao = dao ?? TransactionDao(),
        _accountRepository = accountRepository ?? AccountRepository();

  Future<List<Transaction>> getAll() => _dao.getAll();

  Future<List<Transaction>> getByAccount(String accountId) =>
      _dao.getByAccount(accountId);

  Future<List<Transaction>> getByDateRange(DateTime from, DateTime to) =>
      _dao.getByDateRange(from, to);

  Future<Transaction?> getById(String id) => _dao.getById(id);

  Future<void> save(Transaction transaction) async {
    await _dao.insert(transaction);
    await _applyBalanceDelta(
      transaction.accountId,
      _delta(transaction.type, transaction.amount),
    );
  }

  Future<void> update(Transaction transaction) async {
    final old = await _dao.getById(transaction.id);
    await _dao.update(transaction);

    if (old != null) {
      if (old.accountId == transaction.accountId) {
        final delta = _delta(transaction.type, transaction.amount) -
            _delta(old.type, old.amount);
        await _applyBalanceDelta(transaction.accountId, delta);
      } else {
        await _applyBalanceDelta(
            old.accountId, -_delta(old.type, old.amount));
        await _applyBalanceDelta(
            transaction.accountId, _delta(transaction.type, transaction.amount));
      }
    }
  }

  Future<void> delete(String id) async {
    final transaction = await _dao.getById(id);
    await _dao.delete(id);
    if (transaction != null) {
      await _applyBalanceDelta(
        transaction.accountId,
        -_delta(transaction.type, transaction.amount),
      );
    }
  }

  double _delta(TransactionType type, double amount) =>
      type == TransactionType.income ? amount : -amount;

  Future<void> _applyBalanceDelta(String accountId, double delta) async {
    final account = await _accountRepository.getById(accountId);
    if (account == null) return;
    await _accountRepository.updateBalance(accountId, account.balance + delta);
  }
}
