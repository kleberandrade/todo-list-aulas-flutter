import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/data/task_repository.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/state/task_controller.dart';

class MemoryStore implements TaskStore {
  List<Task> rows = [];
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<List<Task>> all() async {
    if (fail) throw StateError('disk unavailable');
    return List.of(rows);
  }

  @override
  Future<Task> save(Task task) async {
    await gate?.future;
    if (fail) throw StateError('disk full');
    final saved = task.copyWith(id: task.id ?? rows.length + 1);
    rows.removeWhere((t) => t.id == saved.id);
    rows.add(saved);
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    if (fail) throw StateError('disk full');
    rows.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> restore(Task task) async {
    rows.add(task);
  }

  @override
  Future<void> addExamples() async {
    rows.add(Task(id: 8, title: 'Example'));
  }
}

void main() {
  test('filters and query combine; order is pending, priority descending, stable ID', () async {
    final store = MemoryStore()
      ..rows = [
        Task(id: 1, title: 'Aula', priority: 2),
        Task(id: 2, title: 'Aula pronta', isDone: true),
        Task(id: 3, title: 'Café', priority: 5),
      ];
    final c = TaskController(store);
    await c.load();
    expect(c.visible.map((t) => t.id), [3, 1, 2]);
    expect(c.completed, 1);
    c.setFilter(TaskFilter.pending);
    c.setQuery(' AULA ');
    expect(c.visible.single.id, 1);
    c.setFilter(TaskFilter.done);
    expect(c.visible.single.id, 2);
    c.setQuery('missing');
    expect(c.visible, isEmpty);
    c.dispose();
  });
  test('failed writes keep visible state and allow retry', () async {
    final store = MemoryStore();
    final c = TaskController(store);
    await c.load();
    store.fail = true;
    expect(await c.save(Task(title: 'Draft')), false);
    expect(c.tasks, isEmpty);
    expect(c.error, isNotNull);
    expect(c.busy, false);
    store.fail = false;
    expect(await c.save(Task(title: 'Draft')), true);
    expect(c.tasks.single.title, 'Draft');
    expect(c.error, isNull);
    store.fail = true;
    expect(await c.delete(c.tasks.single), false);
    expect(c.tasks.length, 1);
    c.dispose();
  });
  test(
    'duplicate writes are blocked while saving; disposal during write is safe',
    () async {
      final store = MemoryStore()..gate = Completer<void>();
      final c = TaskController(store);
      await c.load();
      final saving = c.save(Task(title: 'Once'));
      expect(c.busy, true);
      expect(await c.save(Task(title: 'Twice')), false);
      c.dispose();
      store.gate!.complete();
      await saving;
      expect(store.rows.length, 1);
    },
  );
  test('writes wait for initial load', () async {
    final c = TaskController(MemoryStore());
    expect(await c.save(Task(title: 'Too soon')), false);
    expect(c.tasks, isEmpty);
    c.dispose();
  });
  test('load failure has retry state and restores data after retry', () async {
    final store = MemoryStore()..fail = true;
    final c = TaskController(store);
    await c.load();
    expect(c.error, isNotNull);
    expect(c.loading, false);
    store.fail = false;
    await c.load();
    expect(c.error, isNull);
    c.dispose();
  });
}
