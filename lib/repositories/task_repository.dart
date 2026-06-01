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

  /// Lista tarefas. Sem [isDone] traz todas; com `true`/`false` filtra por
  /// status. Mantido por compatibilidade — delega a [listarFiltrado].
  Future<List<Task>> listar({bool? isDone}) => listarFiltrado(isDone: isDone);

  /// Lista tarefas aplicando filtros opcionais e independentes. Qualquer
  /// parâmetro `null` significa "sem filtro" naquele eixo.
  ///
  /// - [categoryId]: traz só as tarefas da categoria informada.
  /// - [priority]: traz só as tarefas da prioridade (1=baixa, 2=média, 3=alta).
  /// - [isDone]: `false` traz pendentes, `true` concluídas, `null` traz todas.
  ///
  /// O `where`/`whereArgs` é montado de forma incremental e nunca interpola
  /// valores na string SQL (sempre `?` + [whereArgs]).
  Future<List<Task>> listarFiltrado({
    int? categoryId,
    int? priority,
    bool? isDone,
  }) async {
    final db = await _db.database;

    final conditions = <String>[];
    final args = <Object?>[];

    if (isDone != null) {
      conditions.add('is_done = ?');
      args.add(isDone ? 1 : 0);
    }
    if (categoryId != null) {
      conditions.add('category_id = ?');
      args.add(categoryId);
    }
    if (priority != null) {
      conditions.add('priority = ?');
      args.add(priority);
    }

    final rows = await db.query(
      'tasks',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
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
