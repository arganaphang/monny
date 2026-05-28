import 'package:sqflite/sqflite.dart';

import 'package:monny/models/models.dart';
import 'package:monny/database/database_helper.dart';

class AccountDao {
  static const _table = 'accounts';

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<Account>> getAll() async {
    final rows = await (await _db).query(_table);
    return rows.map(Account.fromJson).toList();
  }

  Future<Account?> getById(String id) async {
    final rows = await (await _db).query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Account.fromJson(rows.first);
  }

  Future<void> insert(Account account) async {
    await (await _db).insert(
      _table,
      account.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Account account) async {
    await (await _db).update(
      _table,
      account.toJson(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> delete(String id) async {
    await (await _db).delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
