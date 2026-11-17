import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/state/task_controller.dart';
import 'controller_test.dart' show MemoryStore;

void main() {
  Future<TaskController> start(
    WidgetTester tester, {
    MemoryStore? store,
    Size size = const Size(1000, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = TaskController(store ?? MemoryStore());
    await c.load();
    await tester.pumpWidget(TaskApp(controller: c));
    await tester.pumpAndSettle();
    addTearDown(c.dispose);
    return c;
  }

  testWidgets(
    'empty state, validation, create, edit, completion, delete and undo',
    (tester) async {
      final c = await start(tester);
      expect(find.text('Um passo de cada vez.'), findsOneWidget);
      await tester.tap(find.text('Nova tarefa').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();
      expect(find.text('Informe um título.'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Título'),
        'Minha tarefa',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Descrição (opcional)'),
        'Primeira linha\nSegunda linha',
      );
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5 · Alta').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();
      expect(c.tasks.single.title, 'Minha tarefa');
      expect(c.tasks.single.priority, 5);
      await tester.tap(find.byTooltip('Editar Minha tarefa'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Título'),
        'Tarefa revisada',
      );
      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();
      expect(c.tasks.single.title, 'Tarefa revisada');
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(c.tasks.single.isDone, true);
      await tester.tap(find.byTooltip('Excluir Tarefa revisada'));
      await tester.pumpAndSettle();
      expect(c.tasks, isEmpty);
      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();
      expect(c.tasks.single.isDone, true);
    },
  );
  testWidgets('mobile layout and enlarged text fit without overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(
      tester,
      size: const Size(390, 844),
      store: MemoryStore()
        ..rows = [
          Task(
            id: 1,
            title: 'Uma tarefa com título maior para testar a quebra de linha',
            description: 'Descrição de exemplo',
            priority: 5,
          ),
        ],
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('save failure keeps dialog draft and displays recovery message', (
    tester,
  ) async {
    final store = MemoryStore();
    await start(tester, store: store);
    await tester.tap(find.text('Nova tarefa').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título'),
      'Keep draft',
    );
    store.fail = true;
    await tester.tap(find.text('Salvar tarefa'));
    await tester.pumpAndSettle();
    expect(find.text('Keep draft'), findsOneWidget);
    expect(find.textContaining('Não foi possível salvar.'), findsWidgets);
    store.fail = false;
    await tester.tap(find.text('Salvar tarefa'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
  testWidgets('examples, visible filters and search work together', (
    tester,
  ) async {
    final c = await start(tester);
    await tester.tap(find.text('Experimentar exemplos'));
    await tester.pumpAndSettle();
    expect(c.tasks.single.title, 'Example');
    await tester.tap(find.text('Concluídas'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma tarefa por aqui.'), findsOneWidget);
    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar tarefas'),
      'missing',
    );
    await tester.pumpAndSettle();
    expect(find.text('Example'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar tarefas'),
      'example',
    );
    await tester.pumpAndSettle();
    expect(find.text('Example'), findsOneWidget);
  });
  testWidgets(
    'loading disables creation and failed loading exposes a working retry',
    (tester) async {
      final store = MemoryStore()..fail = true;
      final c = TaskController(store);
      addTearDown(c.dispose);
      await tester.pumpWidget(TaskApp(controller: c));
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
        isNull,
      );
      await c.load();
      await tester.pumpAndSettle();
      expect(find.textContaining('Não foi possível abrir'), findsOneWidget);
      store.fail = false;
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Não foi possível abrir'), findsNothing);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('Tudo começa com uma tarefa.'), findsOneWidget);
    },
  );
  testWidgets('completion control has its own accessible action label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await start(
        tester,
        store: MemoryStore()..rows = [Task(id: 1, title: 'Example')],
      );
      expect(
        tester.getSemantics(find.byType(Checkbox)).label,
        'Concluir Example',
      );
    } finally {
      semantics.dispose();
    }
  });
}
