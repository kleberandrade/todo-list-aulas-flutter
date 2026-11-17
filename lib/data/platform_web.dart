import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'task_repository.dart';

TaskStore createTaskStore() =>
    TaskRepository(databaseFactoryFfiWeb, 'todo_list.db');
