import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/models/task.dart';

void main() {
  test('task rejects blank titles and priorities outside 1–5', () {
    expect(() => Task(title: ' \n '), throwsArgumentError);
    expect(() => Task(title: 'Study', priority: 0), throwsArgumentError);
    expect(() => Task(title: 'Study', priority: 6), throwsArgumentError);
    expect(() => Task(title: 'x' * 121), throwsArgumentError);
    expect(
      () => Task(title: 'Study', description: 'x' * 2001),
      throwsArgumentError,
    );
  });
  test('task normalizes input and round-trips all persisted fields', () {
    final task = Task(
      id: 7,
      title: '  Study  ',
      description: ' Notes ',
      priority: 5,
      isDone: true,
    );
    expect(task.title, 'Study');
    expect(task.description, 'Notes');
    expect(Task.fromMap(task.toMap()).toMap(), task.toMap());
    expect(task.copyWith(isDone: false).isDone, false);
    expect(task.isDone, true);
  });
  test('legacy nullable fields remain readable without discarding records', () {
    final task = Task.fromMap({
      'id': 9,
      'title': null,
      'description': null,
      'isDone': 0,
    });
    expect(task.id, 9);
    expect(task.title, 'Tarefa sem título');
    expect(task.description, '');
    expect(task.priority, 3);
  });
}
