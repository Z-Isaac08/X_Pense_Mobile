import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/income_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE incomes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');
        }
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE categories(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE expenses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      note TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      categoryId INTEGER,
      FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
    )
  ''');

    // ✅ Ajout de la table incomes
    await db.execute('''
    CREATE TABLE incomes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      source TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL
    )
  ''');
  }

  /* CREATE METHODS */
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> insertIncome(Income income) async {
    final db = await database;
    return await db.insert('incomes', income.toMap());
  }

  /* GET METHODS */
  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Income>> getIncomes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('incomes');
    return List.generate(maps.length, (i) => Income.fromMap(maps[i]));
  }

  /* DELETE METHODS */
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    final expenses = await getExpensesByCategory(id);
    for(var expense in expenses) {
      await deleteExpense(expense.id!);
    }
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteIncome(int id) async {
    final db = await database;
    return await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }

  /* SEARCH METHODS */
  Future<List<Expense>> searchExpense(String searchTerm) async {
    final db = await database;
    final results = await db.query(
      'expenses',
      where: 'note LIKE ?',
      whereArgs: ['%$searchTerm%'],
    );
    return List.generate(results.length, (i) => Expense.fromMap(results[i]));
  }

  Future<List<Income>> searchIncome(String searchTerm) async {
    final db = await database;
    final results = await db.query(
      'incomes',
      where: 'source LIKE ?',
      whereArgs: ['%$searchTerm%'],
    );
    return List.generate(results.length, (i) => Income.fromMap(results[i]));
  }

  /* UTILS METHODS */
  Future<int?> getCategoryIdByName(String categoryName) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'categories',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [categoryName],
    );

    if (result.isNotEmpty) {
      return result.first['id'];
    } else {
      return null;
    }
  }

  Future<String?> getCategoryNameById(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'categories',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [categoryId],
    );

    if (result.isNotEmpty) {
      return result.first['name'];
    } else {
      return null;
    }
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    double total = result.first['total'] as double? ?? 0.0;
    return total;
  }

  Future<double> getTotalIncomes() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM incomes');
    double total = result.first['total'] as double? ?? 0.0;
    return total;
  }

  Future<List<Expense>> getExpensesByCategory(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> expenses = await db
        .query('expenses', where: 'categoryId = ?', whereArgs: [categoryId]);
    return List.generate(expenses.length, (i) => Expense.fromMap(expenses[i]));
  }
}
