import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/task.dart';
import '../repositories/category_repository.dart';
import '../repositories/task_repository.dart';

/// Estado e lógica de apresentação da tela de lista de tarefas.
///
/// Guarda os filtros ativos (categoria, prioridade e status) e dispara a
/// recarga sempre que algum muda. Conversa só com os repositórios e avisa a
/// View via [notifyListeners]. Não importa widgets do Flutter.
class TaskListViewModel extends ChangeNotifier {
  TaskListViewModel(this._taskRepo, this._categoryRepo);

  final TaskRepository _taskRepo;
  final CategoryRepository _categoryRepo;

  // ── estado da lista ─────────────────────────────────────────────
  List<Task> _tasks = [];
  List<Category> _categories = [];
  Map<int, Category> _categoriesById = {};
  bool _loading = false;
  String? _error;

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Category> get categories => List.unmodifiable(_categories);
  bool get loading => _loading;
  String? get error => _error;
  bool get isEmpty => !_loading && _tasks.isEmpty;

  /// Categoria de uma tarefa, ou `null` se ela não tem categoria.
  Category? categoriaDe(Task task) =>
      task.categoryId == null ? null : _categoriesById[task.categoryId];

  // ── filtros ativos ──────────────────────────────────────────────
  int? _categoryId; // null = todas as categorias
  int? _priority; // null = todas as prioridades
  bool? _isDone; // null = todas; false = pendentes; true = concluídas

  int? get categoryId => _categoryId;
  int? get priority => _priority;
  bool? get isDone => _isDone;

  // ── aplicar filtros ─────────────────────────────────────────────

  /// Filtra por categoria; passe `null` para limpar este filtro.
  void filtrarCategoria(int? id) {
    _categoryId = id;
    _recarregar();
  }

  /// Filtra por prioridade (1, 2 ou 3); passe `null` para limpar este filtro.
  void filtrarPrioridade(int? p) {
    _priority = p;
    _recarregar();
  }

  /// Filtra por status; `null` = todas, `false` = pendentes, `true` = concluídas.
  void filtrarStatus(bool? done) {
    _isDone = done;
    _recarregar();
  }

  /// Limpa todos os filtros de uma vez.
  void limparFiltros() {
    _categoryId = null;
    _priority = null;
    _isDone = null;
    _recarregar();
  }

  // ── carregamento ────────────────────────────────────────────────

  /// Carrega as categorias e, em seguida, a lista de tarefas com os filtros
  /// atuais. Também é reusado pela View para recarregar ao voltar do formulário.
  Future<void> inicializar() async {
    try {
      _categories = await _categoryRepo.listar();
      _categoriesById = {
        for (final c in _categories)
          if (c.id != null) c.id!: c,
      };
    } catch (_) {
      _categories = [];
      _categoriesById = {};
    }
    await _recarregar();
  }

  Future<void> _recarregar() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await _taskRepo.listarFiltrado(
        categoryId: _categoryId,
        priority: _priority,
        isDone: _isDone,
      );
    } catch (e) {
      _error = 'Não foi possível carregar as tarefas.';
      _tasks = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Marca/desmarca a tarefa como concluída (RF03).
  Future<void> alternarConclusao(Task task) async {
    await _taskRepo.atualizar(task.copyWith(isDone: !task.isDone));
    await _recarregar();
  }

  /// Exclui a tarefa (RF05).
  Future<void> excluir(Task task) async {
    final id = task.id;
    if (id == null) return;
    await _taskRepo.excluir(id);
    await _recarregar();
  }
}
