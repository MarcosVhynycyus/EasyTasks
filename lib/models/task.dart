/// Uma tarefa pessoal. Classe de dados pura: sem lógica de UI nem de banco.
///
/// Converte a si mesma de/para o formato do SQLite (snake_case). Booleano vira
/// `INTEGER` 0/1 e datas viram texto ISO-8601 na borda do banco.
class Task {
  Task({
    this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.priority = 1,
    this.dueDate,
    this.categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final int? id;
  final String title;
  final String? description;
  final bool isDone;

  /// Prioridade: 1 (baixa), 2 (média) ou 3 (alta).
  final int priority;
  final DateTime? dueDate;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'is_done': isDone ? 1 : 0,
        'priority': priority,
        'due_date': dueDate?.toIso8601String(),
        'category_id': categoryId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Task.fromMap(Map<String, Object?> map) => Task(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String?,
        isDone: (map['is_done'] as int? ?? 0) == 1,
        priority: map['priority'] as int? ?? 1,
        dueDate: map['due_date'] == null
            ? null
            : DateTime.parse(map['due_date'] as String),
        categoryId: map['category_id'] as int?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    int? priority,
    DateTime? dueDate,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isDone: isDone ?? this.isDone,
        priority: priority ?? this.priority,
        dueDate: dueDate ?? this.dueDate,
        categoryId: categoryId ?? this.categoryId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
