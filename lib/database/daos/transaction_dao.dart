import 'package:sqflite/sqflite.dart' hide Transaction;

import 'package:monny/models/models.dart';
import 'package:monny/database/database_helper.dart';

class TransactionDao {
  static const _table = 'transactions';

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<Transaction>> getAll() async {
    final rows = await (await _db).query(
      _table,
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromJson).toList();
  }

  Future<List<Transaction>> getByAccount(String accountId) async {
    final rows = await (await _db).query(
      _table,
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromJson).toList();
  }

  Future<List<Transaction>> getByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await (await _db).query(
      _table,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromJson).toList();
  }

  Future<Transaction?> getById(String id) async {
    final rows = await (await _db).query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Transaction.fromJson(rows.first);
  }

  Future<void> insert(Transaction transaction) async {
    await (await _db).insert(
      _table,
      transaction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Transaction transaction) async {
    await (await _db).update(
      _table,
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    await (await _db).delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
