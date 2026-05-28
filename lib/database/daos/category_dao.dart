import 'package:sqflite/sqflite.dart';

import 'package:monny/models/models.dart';
import 'package:monny/database/database_helper.dart';

class CategoryDao {
  static const _table = 'categories';

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<Category>> getAll() async {
    final rows = await (await _db).query(_table);
    return rows.map(Category.fromJson).toList();
  }

  Future<List<Category>> getByType(TransactionType type) async {
    final rows = await (await _db).query(
      _table,
      where: 'type = ?',
      whereArgs: [type.name],
    );
    return rows.map(Category.fromJson).toList();
  }

  Future<Category?> getById(String id) async {
    final rows = await (await _db).query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Category.fromJson(rows.first);
  }

  Future<void> insert(Category category) async {
    await (await _db).insert(
      _table,
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Category category) async {
    await (await _db).update(
      _table,
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> delete(String id) async {
    await (await _db).delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
