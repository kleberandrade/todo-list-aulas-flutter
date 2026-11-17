import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';
import '../models/task.dart';

enum TaskFilter { all, pending, done }

class TaskController extends ChangeNotifier {
  final TaskStore store;
  List<Task> _tasks = [];
  TaskFilter filter = TaskFilter.all;
  String query = '';
  bool loading = true;
  bool busy = false;
  bool _disposed = false;
  String? error;
  TaskController(this.store);
  List<Task> get tasks => List.unmodifiable(_tasks);
  int get completed => _tasks.where((t) => t.isDone).length;
  List<Task> get visible {
    final result = _tasks.where((task) {
      if (filter == TaskFilter.pending && task.isDone) return false;
      if (filter == TaskFilter.done && !task.isDone) return false;
      return '${task.title} ${task.description}'.toLowerCase().contains(query);
    }).toList();
    result.sort((a, b) {
      final status = (a.isDone ? 1 : 0).compareTo(b.isDone ? 1 : 0);
      if (status != 0) return status;
      final priority = b.priority.compareTo(a.priority);
      return priority != 0 ? priority : (a.id ?? 0).compareTo(b.id ?? 0);
    });
    return result;
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void setFilter(TaskFilter value) {
    filter = value;
    _emit();
  }

  void setQuery(String value) {
    query = value.trim().toLowerCase();
    _emit();
  }

  Future<void> load() async {
    if (busy) return;
    loading = true;
    error = null;
    _emit();
    try {
      _tasks = await store.all();
    } catch (_) {
      error = 'Não foi possível abrir suas tarefas. Tente novamente.';
    } finally {
      loading = false;
      _emit();
    }
  }

  Future<bool> _write(Future<void> Function() action) async {
    if (busy || loading) return false;
    busy = true;
    error = null;
    _emit();
    try {
      await action();
      _tasks = await store.all();
      return true;
    } catch (_) {
      error = 'Não foi possível salvar. Seus dados continuam no dispositivo. Tente novamente.';
      return false;
    } finally {
      busy = false;
      _emit();
    }
  }

  Future<bool> save(Task task) => _write(() async {
    await store.save(task);
  });
  Future<bool> delete(Task task) => _write(() => store.delete(task.id!));
  Future<bool> restore(Task task) => _write(() => store.restore(task));
  Future<bool> addExamples() => _write(store.addExamples);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
