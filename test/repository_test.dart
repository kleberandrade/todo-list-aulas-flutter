import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_list/data/task_repository.dart';
import 'package:todo_list/models/task.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late String path;
  late TaskRepository repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('task-test-');
    path = p.join(directory.path, 'todo_list.db');
    repository = TaskRepository(databaseFactoryFfi, path);
  });
  tearDown(() async {
    await repository.close();
    await directory.delete(recursive: true);
  });

  test(
    'upgrades actual v1 database without losing IDs, completion or nullable fields',
    () async {
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) => db.execute(
            'CREATE TABLE task(id INTEGER PRIMARY KEY, title TEXT, description TEXT, isDone INTEGER)',
          ),
        ),
      );
      await old.insert('task', {
        'id': 42,
        'title': 'Old task',
        'description': 'Keep me',
        'isDone': 1,
      });
      await old.insert('task', {
        'id': 43,
        'title': null,
        'description': null,
        'isDone': 0,
      });
      await old.close();
      final rows = await repository.all();
      expect(rows.map((t) => t.id), [43, 42]);
      expect(rows.last.toMap(), {
        'id': 42,
        'title': 'Old task',
        'description': 'Keep me',
        'isDone': 1,
        'priority': 3,
      });
      expect(rows.first.title, 'Tarefa sem título');
      await repository.close();
      expect((await repository.all()).length, 2);
    },
  );

  test(
    'create edit complete delete and undo survive reopening with stable order',
    () async {
      final low = await repository.save(Task(title: 'Low', priority: 1));
      final high = await repository.save(Task(title: 'High', priority: 5));
      final tie = await repository.save(Task(title: 'Tie', priority: 5));
      expect((await repository.all()).map((t) => t.id), [
        high.id,
        tie.id,
        low.id,
      ]);
      await repository.save(
        Task(
          id: high.id,
          title: 'Edited',
          description: 'Two\nlines',
          priority: 5,
          isDone: true,
        ),
      );
      await repository.delete(tie.id!);
      await repository.restore(tie);
      await repository.close();
      final reopened = await repository.all();
      expect(reopened.map((t) => t.id), [tie.id, low.id, high.id]);
      expect(reopened.last.title, 'Edited');
      expect(reopened.last.description, 'Two\nlines');
      expect(reopened.last.isDone, true);
      await repository.restore(tie); // idempotent retry does not duplicate rows
      expect((await repository.all()).length, 3);
    },
  );

  test(
    'examples are explicit and never duplicate or overwrite user tasks',
    () async {
      await repository.addExamples();
      expect((await repository.all()).length, 3);
      await repository.addExamples();
      expect((await repository.all()).length, 3);
    },
  );
  test(
    'opening failure can be retried after storage becomes available',
    () async {
      await File(path).writeAsString('not a SQLite database');
      await expectLater(repository.all(), throwsA(isA<DatabaseException>()));
      await File(path).delete();
      expect(await repository.all(), isEmpty);
    },
  );
  test(
    'undo remains possible after a new task is created after deletion',
    () async {
      final deleted = await repository.save(Task(title: 'Restore me'));
      await repository.delete(deleted.id!);
      final replacement = await repository.save(Task(title: 'New task'));
      expect(replacement.id, isNot(deleted.id));
      await repository.restore(deleted);
      expect((await repository.all()).map((t) => t.title), [
        'Restore me',
        'New task',
      ]);
    },
  );
}
