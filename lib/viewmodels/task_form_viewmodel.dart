import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/task.dart';
import '../repositories/category_repository.dart';
import '../repositories/task_repository.dart';

/// Estado e validação do formulário de criar/editar tarefa (RF01, RF04).
///
/// Recebe uma tarefa em [existing] para editar, ou `null` para criar.
/// Não importa widgets do Flutter.
class TaskFormViewModel extends ChangeNotifier {
  TaskFormViewModel(
    this._taskRepo,
    this._categoryRepo, {
    Task? existing,
  })  : _existing = existing,
        _title = existing?.title ?? '',
        _description = existing?.description ?? '',
        _priority = existing?.priority ?? 1,
        _dueDate = existing?.dueDate,
        _categoryId = existing?.categoryId;

  final TaskRepository _taskRepo;
  final CategoryRepository _categoryRepo;
  final Task? _existing;

  String _title;
  String _description;
  int _priority;
  DateTime? _dueDate;
  int? _categoryId;

  List<Category> _categories = [];
  bool _loading = true;
  bool _saving = false;
  String? _titleError;

  bool get isEditing => _existing != null;
  String get title => _title;
  String get description => _description;
  int get priority => _priority;
  DateTime? get dueDate => _dueDate;
  int? get categoryId => _categoryId;
  List<Category> get categories => List.unmodifiable(_categories);
  bool get loading => _loading;
  bool get saving => _saving;
  String? get titleError => _titleError;

  /// Carrega as categorias disponíveis para o seletor (RF07).
  Future<void> carregarCategorias() async {
    _loading = true;
    notifyListeners();
    _categories = await _categoryRepo.listar();
    // Se a categoria da tarefa não existe mais, trata como "sem categoria".
    if (_categoryId != null && !_categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }
    _loading = false;
    notifyListeners();
  }

  void setTitle(String value) {
    _title = value;
    // Limpa o erro assim que o usuário corrige o título.
    if (_titleError != null && value.trim().isNotEmpty) {
      _titleError = null;
    }
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setPriority(int value) {
    if (value < 1 || value > 3) return;
    _priority = value;
    notifyListeners();
  }

  void setDueDate(DateTime? value) {
    _dueDate = value;
    notifyListeners();
  }

  void setCategoryId(int? value) {
    _categoryId = value;
    notifyListeners();
  }

  /// Valida e persiste a tarefa. Retorna `true` se salvou.
  ///
  /// Regras: título não pode ser vazio; prioridade ∈ {1,2,3}; categoria deve
  /// ser nula ou uma categoria existente.
  Future<bool> salvar() async {
    if (_title.trim().isEmpty) {
      _titleError = 'Informe um título.';
      notifyListeners();
      return false;
    }
    if (_priority < 1 || _priority > 3) {
      _priority = 1;
    }
    if (_categoryId != null && !_categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }

    _saving = true;
    notifyListeners();

    final description = _description.trim();
    final task = Task(
      id: _existing?.id,
      title: _title.trim(),
      description: description.isEmpty ? null : description,
      isDone: _existing?.isDone ?? false,
      priority: _priority,
      dueDate: _dueDate,
      categoryId: _categoryId,
      createdAt: _existing?.createdAt,
    );

    try {
      if (isEditing) {
        await _taskRepo.atualizar(task);
      } else {
        await _taskRepo.inserir(task);
      }
      return true;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
