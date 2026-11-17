import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool busy;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const TaskCard({
    super.key,
    required this.task,
    required this.busy,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final high = task.priority >= 4;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E6DF)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 12, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              container: true,
              label: task.isDone
                  ? 'Reabrir ${task.title}'
                  : 'Concluir ${task.title}',
              child: Checkbox(
                value: task.isDone,
                onChanged: busy ? null : (_) => onToggle(),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isDone
                          ? const Color(0xFF5C6B62)
                          : const Color(0xFF1D342B),
                    ),
                  ),
                  if (task.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        task.description,
                        style: const TextStyle(
                          color: Color(0xFF536159),
                          height: 1.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: high
                              ? const Color(0xFFFFF0DC)
                              : const Color(0xFFEDF3EC),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'P${task.priority} · ${high ? 'Importante' : 'No seu ritmo'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: high
                                ? const Color(0xFF80500A)
                                : const Color(0xFF395A44),
                          ),
                        ),
                      ),
                      if (task.isDone)
                        const Text(
                          'Concluída',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF395A44),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar ${task.title}',
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
                IconButton(
                  tooltip: 'Excluir ${task.title}',
                  onPressed: busy ? null : onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
