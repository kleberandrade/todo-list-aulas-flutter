/// A task draft has no ID until SQLite assigns one. Priority 5 is highest.
class Task {
  final int? id;
  final String title;
  final String description;
  final bool isDone;
  final int priority;

  Task({
    this.id,
    required String title,
    String description = '',
    this.isDone = false,
    this.priority = 3,
  }) : title = title.trim(),
       description = description.trim() {
    final error = validateTitle(this.title);
    if (error != null) throw ArgumentError(error);
    if (this.description.length > 2000) {
      throw ArgumentError('Use até 2000 caracteres na descrição.');
    }
    if (priority < 1 || priority > 5) {
      throw ArgumentError('A prioridade deve estar entre 1 e 5.');
    }
  }

  // Legacy rows allowed null/blank and arbitrarily long titles. Preserve those
  // values on read; new/edited drafts must pass the validated constructor.
  Task._stored({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.priority,
  });

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe um título.';
    if (value.trim().length > 120) return 'Use até 120 caracteres no título.';
    return null;
  }

  factory Task.fromMap(Map<String, Object?> row) => Task._stored(
    id: row['id'] as int?,
    title: (row['title'] as String?)?.trim().isNotEmpty == true
        ? row['title'] as String
        : 'Tarefa sem título',
    description: row['description'] as String? ?? '',
    isDone: row['isDone'] == 1,
    priority: row['priority'] as int? ?? 3,
  );

  Task copyWith({int? id, bool? isDone}) => Task._stored(
    id: id ?? this.id,
    title: title,
    description: description,
    isDone: isDone ?? this.isDone,
    priority: priority,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'isDone': isDone ? 1 : 0,
    'priority': priority,
  };
}
