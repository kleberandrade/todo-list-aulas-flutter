import 'package:material_ui/material_ui.dart';

import '../models/task.dart';
import '../state/task_controller.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final TaskController controller;
  const TaskDialog({super.key, this.task, required this.controller});
  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late int _priority;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title ?? '');
    _description = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? 3;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.controller.save(
      Task(
        id: widget.task?.id,
        title: _title.text,
        description: _description.text,
        priority: _priority,
        isDone: widget.task?.isDone ?? false,
      ),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = widget.controller.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefa'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dê um nome ao próximo passo. Os detalhes ficam por sua conta.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _title,
                  autofocus: true,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'O que você quer fazer?',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: Task.validateTitle,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                  ),
                  minLines: 3,
                  maxLines: 6,
                  validator: (value) => (value?.trim().length ?? 0) > 2000
                      ? 'Use até 2000 caracteres na descrição.'
                      : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  enabled: !_saving,
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Prioridade'),
                  items: List.generate(
                    5,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        '${i + 1} · ${['Baixa', 'Tranquila', 'Normal', 'Importante', 'Alta'][i]}',
                      ),
                    ),
                  ),
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _priority = value!),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Salvando…' : 'Salvar tarefa'),
        ),
      ],
    ),
  );
}
