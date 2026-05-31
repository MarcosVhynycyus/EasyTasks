/// Categoria usada para organizar tarefas. Classe de dados pura: sem lógica de
/// UI nem de banco. Traduz a si mesma de/para o formato do SQLite (snake_case).
class Category {
  Category({
    this.id,
    required this.name,
    this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final int? id;
  final String name;

  /// Cor em hexadecimal (ex.: `#1565C0`). Opcional.
  final String? color;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'color': color,
        'created_at': createdAt.toIso8601String(),
      };

  factory Category.fromMap(Map<String, Object?> map) => Category(
        id: map['id'] as int?,
        name: map['name'] as String,
        color: map['color'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Category copyWith({
    int? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
      );
}
