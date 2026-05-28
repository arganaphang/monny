import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'monny.db';
  static const _dbVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('categories');
    await db.delete('accounts');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id             TEXT    PRIMARY KEY,
        name           TEXT    NOT NULL,
        balance        REAL    NOT NULL,
        type           TEXT    NOT NULL,
        colorValue     INTEGER NOT NULL,
        iconCodePoint  INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id             TEXT    PRIMARY KEY,
        name           TEXT    NOT NULL,
        type           TEXT    NOT NULL,
        iconCodePoint  INTEGER NOT NULL,
        colorValue     INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id          TEXT    PRIMARY KEY,
        title       TEXT    NOT NULL,
        amount      REAL    NOT NULL,
        type        TEXT    NOT NULL,
        categoryId  TEXT    NOT NULL,
        accountId   TEXT    NOT NULL,
        date        TEXT    NOT NULL,
        note        TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories(id),
        FOREIGN KEY (accountId)  REFERENCES accounts(id)
      )
    ''');

    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    await db.execute('''
      INSERT INTO categories (id, name, type, iconCodePoint, colorValue) VALUES
      ('seed_food',          'Food & Dining', 'expense', ${Icons.restaurant.codePoint},     ${0xFFE53935}),
      ('seed_transport',     'Transport',     'expense', ${Icons.directions_car.codePoint},  ${0xFF1E88E5}),
      ('seed_shopping',      'Shopping',      'expense', ${Icons.shopping_bag.codePoint},    ${0xFF8E24AA}),
      ('seed_health',        'Health',        'expense', ${Icons.local_hospital.codePoint},  ${0xFFE91E63}),
      ('seed_education',     'Education',     'expense', ${Icons.school.codePoint},          ${0xFF43A047}),
      ('seed_entertainment', 'Entertainment', 'expense', ${Icons.sports_esports.codePoint},  ${0xFFFF9800}),
      ('seed_utilities',     'Utilities',     'expense', ${Icons.bolt.codePoint},            ${0xFFFFC107}),
      ('seed_housing',       'Housing',       'expense', ${Icons.home.codePoint},            ${0xFF6D4C41}),
      ('seed_salary',        'Salary',        'income',  ${Icons.work.codePoint},            ${0xFF43A047}),
      ('seed_business',      'Business',      'income',  ${Icons.business_center.codePoint}, ${0xFF1E88E5}),
      ('seed_investment',    'Investment',    'income',  ${Icons.trending_up.codePoint},     ${0xFFFF9800}),
      ('seed_freelance',     'Freelance',     'income',  ${Icons.laptop.codePoint},          ${0xFF8E24AA}),
      ('seed_gift',          'Gift',          'income',  ${Icons.card_giftcard.codePoint},   ${0xFFE91E63})
    ''');
  }
}
