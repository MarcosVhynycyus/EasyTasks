import '../core/database/app_database.dart';
import '../models/category.dart';

/// Acesso às categorias no SQLite. Recebe e devolve [Category].
///
/// Excluir uma categoria não apaga as tarefas: a coluna `category_id` das
/// tarefas vira nula por causa do `ON DELETE SET NULL` definido no schema.
class CategoryRepository {
  CategoryRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<List<Category>> listar() async {
    final db = await _db.database;
    final rows = await db.query('categories', orderBy: 'name ASC');
    return rows.map(Category.fromMap).toList();
  }

  Future<int> inserir(Category category) async {
    final db = await _db.database;
    return db.insert('categories', category.toMap());
  }

  Future<int> atualizar(Category category) async {
    final db = await _db.database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> excluir(int id) async {
    final db = await _db.database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
