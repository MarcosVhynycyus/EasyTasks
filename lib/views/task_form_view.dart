import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/task_form_viewmodel.dart';

/// Formulário de criar/editar tarefa (RF01, RF04). Lê e dispara ações somente
/// pelo [TaskFormViewModel] via Provider.
class TaskFormView extends StatefulWidget {
  const TaskFormView({super.key});

  static const routeName = '/task-form';

  @override
  State<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<TaskFormView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<TaskFormViewModel>();
    _titleController = TextEditingController(text: vm.title);
    _descriptionController = TextEditingController(text: vm.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskFormViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(vm.isEditing ? 'Editar tarefa' : 'Nova tarefa'),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Título *',
                      hintText: 'O que precisa ser feito?',
                      border: const OutlineInputBorder(),
                      errorText: vm.titleError,
                    ),
                    onChanged: (value) =>
                        context.read<TaskFormViewModel>().setTitle(value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        context.read<TaskFormViewModel>().setDescription(value),
                  ),
                  const SizedBox(height: 24),
                  const _FieldLabel('Prioridade'),
                  const SizedBox(height: 8),
                  _PrioritySelector(selected: vm.priority),
                  const SizedBox(height: 24),
                  const _FieldLabel('Prazo'),
                  _DueDateField(dueDate: vm.dueDate),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    initialValue: vm.categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Sem categoria'),
                      ),
                      for (final category in vm.categories)
                        DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: (value) =>
                        context.read<TaskFormViewModel>().setCategoryId(value),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: vm.saving ? null : () => _salvar(context),
                    icon: const Icon(Icons.save),
                    label: Text(vm.saving ? 'Salvando...' : 'Salvar'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _salvar(BuildContext context) async {
    final ok = await context.read<TaskFormViewModel>().salvar();
    if (ok && context.mounted) {
      Navigator.pop(context, true);
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}

/// Seletor de prioridade 1/2/3 (RF01 / regra de negócio).
class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 1, label: Text('Baixa')),
        ButtonSegment(value: 2, label: Text('Média')),
        ButtonSegment(value: 3, label: Text('Alta')),
      ],
      selected: {selected},
      onSelectionChanged: (selection) =>
          context.read<TaskFormViewModel>().setPriority(selection.first),
    );
  }
}

class _DueDateField extends StatelessWidget {
  const _DueDateField({required this.dueDate});

  final DateTime? dueDate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event),
      title: Text(dueDate == null ? 'Sem prazo' : _formatDate(dueDate!)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dueDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Remover prazo',
              onPressed: () =>
                  context.read<TaskFormViewModel>().setDueDate(null),
            ),
          TextButton(
            onPressed: () => _escolherData(context),
            child: const Text('Escolher'),
          ),
        ],
      ),
    );
  }

  Future<void> _escolherData(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && context.mounted) {
      context.read<TaskFormViewModel>().setDueDate(picked);
    }
  }
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}
