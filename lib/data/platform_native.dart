import 'package:sqflite/sqflite.dart';
import 'task_repository.dart';

TaskStore createTaskStore() => TaskRepository(databaseFactory, 'todo_list.db');
