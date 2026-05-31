import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/task.dart';
import '../repositories/category_repository.dart';
import '../repositories/task_repository.dart';

/// Filtro de status aplicado à lista de tarefas (RF06).
enum TaskFilter { todas, pendentes, concluidas }

/// Estado e lógica de apresentação da tela de lista de tarefas.
///
/// Conversa só com os repositórios e avisa a View via [notifyListeners].
/// Não importa widgets do Flutter.
class TaskListViewModel extends ChangeNotifier {
  TaskListViewModel(this._taskRepo, this._categoryRepo);

  final TaskRepository _taskRepo;
  final CategoryRepository _categoryRepo;

  List<Task> _tasks = [];
  Map<int, Category> _categoriesById = {};
  bool _loading = false;
  TaskFilter _filter = TaskFilter.todas;
  String? _error;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get loading => _loading;
  TaskFilter get filter => _filter;
  String? get error => _error;
  bool get isEmpty => !_loading && _tasks.isEmpty;

  /// Categoria de uma tarefa, ou `null` se ela não tem categoria.
  Category? categoriaDe(Task task) =>
      task.categoryId == null ? null : _categoriesById[task.categoryId];

  /// Carrega tarefas (respeitando o filtro atual) e categorias.
  Future<void> carregar() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final bool? isDone = switch (_filter) {
        TaskFilter.todas => null,
        TaskFilter.pendentes => false,
        TaskFilter.concluidas => true,
      };
      _tasks = await _taskRepo.listar(isDone: isDone);
      final categories = await _categoryRepo.listar();
      _categoriesById = {
        for (final c in categories)
          if (c.id != null) c.id!: c,
      };
    } catch (e) {
      _error = 'Não foi possível carregar as tarefas.';
      _tasks = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Troca o filtro de status e recarrega (RF06).
  Future<void> aplicarFiltro(TaskFilter novo) async {
    if (_filter == novo) return;
    _filter = novo;
    await carregar();
  }

  /// Marca/desmarca a tarefa como concluída (RF03).
  Future<void> alternarConclusao(Task task) async {
    await _taskRepo.atualizar(task.copyWith(isDone: !task.isDone));
    await carregar();
  }

  /// Exclui a tarefa (RF05).
  Future<void> excluir(Task task) async {
    final id = task.id;
    if (id == null) return;
    await _taskRepo.excluir(id);
    await carregar();
  }
}
