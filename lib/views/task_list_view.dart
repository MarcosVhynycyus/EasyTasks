import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'task_form_view.dart';

/// Tela principal: lista de tarefas com filtro, conclusão, edição e exclusão
/// (RF02, RF03, RF04, RF05, RF06).
class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskListViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Tarefas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: _FilterControl(current: vm.filter),
          ),
          Expanded(child: _buildBody(context, vm)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TaskListViewModel vm) {
    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null) {
      return _Message(icon: Icons.error_outline, text: vm.error!);
    }
    if (vm.isEmpty) {
      return const _Message(
        icon: Icons.checklist_rtl,
        text: 'Nenhuma tarefa por aqui.\nToque em "Nova tarefa" para começar.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: vm.tasks.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = vm.tasks[index];
        return _TaskTile(task: task, category: vm.categoriaDe(task));
      },
    );
  }

  Future<void> _abrirFormulario(BuildContext context, [Task? task]) async {
    await Navigator.pushNamed(
      context,
      TaskFormView.routeName,
      arguments: task,
    );
    if (context.mounted) {
      await context.read<TaskListViewModel>().carregar();
    }
  }
}

/// Controle de filtro "Todas / Pendentes / Concluídas" (RF06).
class _FilterControl extends StatelessWidget {
  const _FilterControl({required this.current});

  final TaskFilter current;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TaskFilter>(
      segments: const [
        ButtonSegment(value: TaskFilter.todas, label: Text('Todas')),
        ButtonSegment(value: TaskFilter.pendentes, label: Text('Pendentes')),
        ButtonSegment(value: TaskFilter.concluidas, label: Text('Concluídas')),
      ],
      selected: {current},
      onSelectionChanged: (selection) =>
          context.read<TaskListViewModel>().aplicarFiltro(selection.first),
    );
  }
}

/// Linha de uma tarefa: checkbox para concluir, toque para editar, lixeira
/// para excluir.
class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.category});

  final Task task;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = task.isDone
        ? theme.textTheme.bodyLarge?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: theme.disabledColor,
          )
        : theme.textTheme.bodyLarge;

    return ListTile(
      leading: Checkbox(
        value: task.isDone,
        onChanged: (_) =>
            context.read<TaskListViewModel>().alternarConclusao(task),
      ),
      title: Text(task.title, style: titleStyle),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _PriorityBadge(priority: task.priority),
            if (category != null) _CategoryChip(category: category!),
            if (task.dueDate != null)
              _MetaText(
                icon: Icons.event,
                text: _formatDate(task.dueDate!),
              ),
          ],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Excluir',
        onPressed: () => _confirmarExclusao(context, task),
      ),
      onTap: () => _abrirEdicao(context, task),
    );
  }

  Future<void> _abrirEdicao(BuildContext context, Task task) async {
    await Navigator.pushNamed(
      context,
      TaskFormView.routeName,
      arguments: task,
    );
    if (context.mounted) {
      await context.read<TaskListViewModel>().carregar();
    }
  }

  Future<void> _confirmarExclusao(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TaskListViewModel>().excluir(task);
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final int priority;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      3 => ('Alta', Colors.red),
      2 => ('Média', Colors.orange),
      _ => ('Baixa', Colors.green),
    };
    return _MetaText(icon: Icons.flag, text: label, color: color);
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return _MetaText(
      icon: Icons.label_outline,
      text: category.name,
      color: _parseColor(category.color),
    );
  }
}

/// Pequeno par ícone + texto usado nos metadados da tarefa.
class _MetaText extends StatelessWidget {
  const _MetaText({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: effectiveColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: effectiveColor),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}

/// Converte uma cor hexadecimal (`#RRGGBB`) em [Color]; devolve `null` se não
/// reconhecer o formato.
Color? _parseColor(String? hex) {
  if (hex == null) return null;
  final value = hex.replaceFirst('#', '');
  if (value.length != 6) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(0xFF000000 | parsed);
}
