import 'package:sqflite_common/sqlite_api.dart';
import '../models/task.dart';

abstract interface class TaskStore {
  Future<List<Task>> all();
  Future<Task> save(Task task);
  Future<void> delete(int id);
  Future<void> restore(Task task);
  Future<void> addExamples();
}

class TaskRepository implements TaskStore {
  final DatabaseFactory factory;
  final String path;
  Future<Database>? _opening;
  TaskRepository(this.factory, this.path);

  Future<Database> get _database => _opening ??= _open();

  Future<Database> _open() async {
    try {
      return await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, _) => db.execute(_schema('task')),
          onUpgrade: (db, old, _) async {
            if (old < 2) {
              await db.execute(_schema('task_upgrade'));
              await db.execute(
                'INSERT INTO task_upgrade(id, title, description, isDone, priority) SELECT id, title, description, isDone, 3 FROM task',
              );
              await db.execute('DROP TABLE task');
              await db.execute('ALTER TABLE task_upgrade RENAME TO task');
            }
          },
        ),
      );
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  static String _schema(String table) =>
      'CREATE TABLE $table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, isDone INTEGER, '
      'priority INTEGER NOT NULL DEFAULT 3 CHECK(priority BETWEEN 1 AND 5))';

  @override
  Future<List<Task>> all() async => (await (await _database).query(
    'task',
    orderBy: 'isDone ASC, priority DESC, id ASC',
  )).map(Task.fromMap).toList();

  @override
  Future<Task> save(Task task) async {
    // Revalidate editable values at the storage boundary, not just in widgets.
    final validated = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      isDone: task.isDone,
      priority: task.priority,
    );
    final db = await _database;
    if (validated.id == null) {
      final id = await db.insert('task', validated.toMap());
      return validated.copyWith(id: id);
    }
    final count = await db.update(
      'task',
      validated.toMap(),
      where: 'id = ?',
      whereArgs: [validated.id],
    );
    if (count != 1) throw StateError('Task no longer exists');
    return validated;
  }

  @override
  Future<void> delete(int id) async {
    await (await _database).delete('task', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> restore(Task task) async {
    if (task.id == null) throw ArgumentError('Cannot restore an unsaved task');
    await (await _database).insert(
      'task',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<void> addExamples() async {
    await (await _database).transaction((txn) async {
      if ((await txn.query('task', limit: 1)).isNotEmpty) return;
      for (final task in [
        Task(
          title: 'Preparar a próxima aula',
          description:
              'Revisar os exemplos de Flutter e separar as dúvidas da turma.',
          priority: 5,
        ),
        Task(
          title: 'Fazer uma pausa',
          description:
              'Um café, um pouco de ar fresco e energia para continuar.',
          priority: 2,
        ),
        Task(
          title: 'Experimentar a lista',
          description:
              'Esta tarefa já está concluída. Você pode editá-la ou reabri-la.',
          isDone: true,
        ),
      ]) {
        await txn.insert('task', task.toMap());
      }
    });
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }
}
