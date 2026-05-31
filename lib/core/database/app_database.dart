import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Abre/cria o arquivo SQLite e guarda a única conexão do app (singleton).
///
/// Só os repositórios usam esta classe. O schema (tabelas, índices, seed) vive
/// nos métodos estáticos [onConfigure] e [onCreate], que também são reaproveitados
/// pelos testes para abrir um banco em memória com a mesma estrutura.
class AppDatabase {
  AppDatabase._();

  /// Instância usada pelo app em produção (banco em arquivo).
  static final AppDatabase instance = AppDatabase._();

  /// Cria uma instância sobre um [Database] já aberto. Usado só nos testes,
  /// onde injetamos um banco em memória (sqflite_common_ffi).
  @visibleForTesting
  AppDatabase.forTesting(Database db) : _db = db;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'task_manager.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: onConfigure,
      onCreate: onCreate,
    );
  }

  /// Liga as chaves estrangeiras nesta conexão (precisa ser feito a cada abertura).
  static Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Cria as tabelas, índices e categorias iniciais.
  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        is_done INTEGER NOT NULL DEFAULT 0 CHECK (is_done IN (0, 1)),
        priority INTEGER NOT NULL DEFAULT 1 CHECK (priority IN (1, 2, 3)),
        due_date TEXT,
        category_id INTEGER,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )''');

    await db.execute('CREATE INDEX idx_tasks_is_done ON tasks (is_done)');
    await db.execute('CREATE INDEX idx_tasks_priority ON tasks (priority)');
    await db.execute('CREATE INDEX idx_tasks_category_id ON tasks (category_id)');

    await _seedCategories(db);
  }

  static Future<void> _seedCategories(Database db) async {
    const seeds = [
      {'name': 'Trabalho', 'color': '#1565C0'},
      {'name': 'Pessoal', 'color': '#2E7D32'},
      {'name': 'Estudos', 'color': '#6A1B9A'},
      {'name': 'Casa', 'color': '#EF6C00'},
    ];
    final batch = db.batch();
    for (final seed in seeds) {
      batch.insert('categories', seed);
    }
    await batch.commit(noResult: true);
  }
}
