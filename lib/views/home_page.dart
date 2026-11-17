import 'package:flutter/material.dart';
import '../models/task.dart';
import '../state/task_controller.dart';
import 'task_card.dart';
import 'task_dialog.dart';

class HomePage extends StatefulWidget {
  final TaskController controller;
  const HomePage({super.key, required this.controller});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TaskController get c => widget.controller;
  void _edit([Task? task]) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TaskDialog(task: task, controller: c),
    );
  }

  Future<void> _delete(Task task) async {
    final ok = await c.delete(task);
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('“${task.title}” excluída.'),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => c.restore(task),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: c,
    builder: (context, _) {
      return Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: CustomScrollView(
                slivers: [
                  if (c.error != null)
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverToBoxAdapter(child: _error()),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    sliver: SliverToBoxAdapter(child: _header()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverToBoxAdapter(child: _overview()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(child: _controls()),
                  ),
                  if (c.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (c.visible.isEmpty)
                    SliverFillRemaining(hasScrollBody: false, child: _empty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      sliver: SliverList.separated(
                        itemCount: c.visible.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final task = c.visible[index];
                          return TaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            busy: c.busy,
                            onToggle: () =>
                                c.save(task.copyWith(isDone: !task.isDone)),
                            onEdit: () => _edit(task),
                            onDelete: () => _delete(task),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _header() => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 24,
    runSpacing: 16,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF285D4B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'lista',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                  Text(
                    'MENOS PRESSA. MAIS FOCO.',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: Color(0xFF536159),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      FilledButton.icon(
        onPressed: c.loading || c.busy ? null : () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    ],
  );

  Widget _overview() {
    final total = c.tasks.length;
    final fraction = total == 0 ? 0.0 : c.completed / total;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDE3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SEU ESPAÇO PARA ORGANIZAR',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF395A44),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Um passo de cada vez.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              const Text(
                'Tire as ideias da cabeça. Escolha uma tarefa e comece.',
                style: TextStyle(color: Color(0xFF42584A), height: 1.6),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    '${total - c.completed} pendentes',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('${c.completed} concluídas'),
                ],
              ),
            ],
          );
          final progress = Semantics(
            label: 'Progresso: ${(fraction * 100).round()} por cento',
            child: SizedBox(
              width: 108,
              height: 108,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: fraction,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFC9D8C7),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(fraction * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
          if (constraints.maxWidth < 620) return heading;
          return Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 24),
              progress,
            ],
          );
        },
      ),
    );
  }

  Widget _controls() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 24,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Suas tarefas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Text(
            'Pendentes primeiro · maior prioridade',
            style: TextStyle(fontSize: 12, color: Color(0xFF536159)),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final filter in TaskFilter.values)
            ChoiceChip(
              label: Text(switch (filter) {
                TaskFilter.all => 'Todas',
                TaskFilter.pending => 'Pendentes',
                TaskFilter.done => 'Concluídas',
              }),
              selected: c.filter == filter,
              onSelected: (_) => c.setFilter(filter),
            ),
        ],
      ),
      const SizedBox(height: 16),
      TextField(
        onChanged: c.setQuery,
        decoration: const InputDecoration(
          labelText: 'Buscar tarefas',
          prefixIcon: Icon(Icons.search),
          hintText: 'Título ou descrição',
        ),
      ),
      if (c.busy)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(),
        ),
    ],
  );

  Widget _error() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(c.error!, semanticsLabel: c.error),
        TextButton(
          onPressed: c.busy ? null : c.load,
          child: const Text('Tentar novamente'),
        ),
      ],
    ),
  );

  Widget _empty() => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.task_alt_outlined, size: 46, color: Color(0xFF5D7C65)),
        const SizedBox(height: 16),
        Text(
          c.tasks.isEmpty
              ? 'Tudo começa com uma tarefa.'
              : 'Nenhuma tarefa por aqui.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          c.tasks.isEmpty
              ? 'Crie a sua primeira tarefa ou experimente com exemplos.'
              : 'Experimente outro filtro ou busca.',
          textAlign: TextAlign.center,
        ),
        if (c.tasks.isEmpty && c.error == null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: OutlinedButton.icon(
              onPressed: c.busy ? null : c.addExamples,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Experimentar exemplos'),
            ),
          ),
        const SizedBox(height: 24),
        const Text(
          'Salvo neste dispositivo • Sem conta, sem complicação',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF536159)),
        ),
      ],
    ),
  );
}
