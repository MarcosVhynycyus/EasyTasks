import '../core/database/app_database.dart';
import '../models/task.dart';

/// Acesso às tarefas no SQLite. Única camada que conhece o banco para tarefas:
/// recebe e devolve [Task], escondendo o SQL do resto do app.
class TaskRepository {
  /// Em produção usa o banco singleton; nos testes recebe um [AppDatabase]
  /// apontando para um banco em memória.
  TaskRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<int> inserir(Task task) async {
    final db = await _db.database;
    return db.insert('tasks', task.toMap());
  }

  Future<Task?> obterPorId(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Task.fromMap(rows.first);
  }

  /// Lista tarefas. Sem [isDone] traz todas; com `true`/`false` filtra por status.
  Future<List<Task>> listar({bool? isDone}) async {
    final db = await _db.database;
    final rows = await db.query(
      'tasks',
      where: isDone == null ? null : 'is_done = ?',
      whereArgs: isDone == null ? null : [isDone ? 1 : 0],
      orderBy: 'is_done ASC, priority DESC, created_at DESC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<int> atualizar(Task task) async {
    final db = await _db.database;
    final data = task.toMap()
      ..['updated_at'] = DateTime.now().toIso8601String();
    return db.update('tasks', data, where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> excluir(int id) async {
    final db = await _db.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
