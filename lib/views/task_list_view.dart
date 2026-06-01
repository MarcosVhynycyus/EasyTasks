import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'task_form_view.dart';

/// Tela principal: lista de tarefas com filtros (status, categoria e
/// prioridade), conclusão, edição e exclusão (RF02–RF06).
class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/TaskFy_logo.png',
          height: 40,
          fit: BoxFit.contain,
          semanticLabel: 'TaskFy',
          errorBuilder: (context, _, _) => Text(
            'TaskFy',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      body: Column(
        children: [
          const _FilterSection(),
          Expanded(child: _buildBody(context, vm)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        tooltip: 'Nova tarefa',
        child: const Icon(Icons.add),
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
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: vm.tasks.length,
      itemBuilder: (context, index) {
        final task = vm.tasks[index];
        return _TaskCard(task: task, category: vm.categoriaDe(task));
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
      await context.read<TaskListViewModel>().inicializar();
    }
  }
}

/// Seção de filtros acima da lista: status, categoria e prioridade. Lê o estado
/// do ViewModel e dispara `filtrar*`/`limparFiltros` — nunca usa `setState`.
class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskListViewModel>();
    final temFiltroAtivo =
        vm.categoryId != null || vm.priority != null || vm.isDone != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status: todas / pendentes / concluídas (RF06).
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Todas')),
              ButtonSegment(value: 1, label: Text('Pendentes')),
              ButtonSegment(value: 2, label: Text('Concluídas')),
            ],
            selected: {_statusSegment(vm.isDone)},
            onSelectionChanged: (selection) => context
                .read<TaskListViewModel>()
                .filtrarStatus(_statusFromSegment(selection.first)),
          ),
          const SizedBox(height: 12),
          // Categorias: "Todas" + um chip por categoria.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: vm.categoryId == null,
                  onSelected: (_) =>
                      context.read<TaskListViewModel>().filtrarCategoria(null),
                ),
                ...vm.categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(cat.name),
                      selected: vm.categoryId == cat.id,
                      onSelected: (_) => context
                          .read<TaskListViewModel>()
                          .filtrarCategoria(cat.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Prioridades: baixa / média / alta (toggle).
          Row(
            children: [
              _PriorityFilterChip(label: 'Baixa', value: 1, current: vm.priority),
              const SizedBox(width: 8),
              _PriorityFilterChip(label: 'Média', value: 2, current: vm.priority),
              const SizedBox(width: 8),
              _PriorityFilterChip(label: 'Alta', value: 3, current: vm.priority),
            ],
          ),
          // Limpar filtros: visível só quando há filtro ativo.
          if (temFiltroAtivo)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    context.read<TaskListViewModel>().limparFiltros(),
                icon: const Icon(Icons.filter_alt_off, size: 18),
                label: const Text('Limpar filtros'),
              ),
            ),
        ],
      ),
    );
  }

  /// Mapeia o status (`bool?`) para o índice do [SegmentedButton].
  static int _statusSegment(bool? isDone) => switch (isDone) {
        null => 0,
        false => 1,
        true => 2,
      };

  static bool? _statusFromSegment(int value) => switch (value) {
        1 => false,
        2 => true,
        _ => null,
      };
}

/// Chip de prioridade com padrão toggle: toca de novo no selecionado limpa.
class _PriorityFilterChip extends StatelessWidget {
  const _PriorityFilterChip({
    required this.label,
    required this.value,
    required this.current,
  });

  final String label;
  final int value;
  final int? current;

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => context
          .read<TaskListViewModel>()
          .filtrarPrioridade(selected ? null : value),
    );
  }
}

/// Card de uma tarefa: barra de prioridade à esquerda, checkbox para concluir,
/// toque para editar e lixeira para excluir.
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.category});

  final Task task;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = task.isDone
        ? theme.textTheme.titleMedium?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: AppColors.onSurface.withValues(alpha: 0.5),
          )
        : theme.textTheme.titleMedium;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra lateral de prioridade (4 pt).
            Container(width: 4, color: _priorityColor(task.priority)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Checkbox(
                      value: task.isDone,
                      onChanged: (_) => context
                          .read<TaskListViewModel>()
                          .alternarConclusao(task),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _abrirEdicao(context, task),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(task.title, style: titleStyle),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _PriorityBadge(priority: task.priority),
                                if (category != null)
                                  _CategoryChip(category: category!),
                                if (task.dueDate != null)
                                  _MetaText(
                                    icon: Icons.event,
                                    text: _formatDate(task.dueDate!),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Excluir',
                      onPressed: () => _confirmarExclusao(context, task),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirEdicao(BuildContext context, Task task) async {
    await Navigator.pushNamed(
      context,
      TaskFormView.routeName,
      arguments: task,
    );
    if (context.mounted) {
      await context.read<TaskListViewModel>().inicializar();
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

/// Cor da prioridade conforme `docs/visual_specs.md` (1=baixa, 2=média, 3=alta).
Color _priorityColor(int priority) => switch (priority) {
      3 => AppColors.priorityHigh,
      2 => AppColors.priorityMedium,
      _ => AppColors.priorityLow,
    };

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final int priority;

  @override
  Widget build(BuildContext context) {
    final label = switch (priority) {
      3 => 'Alta',
      2 => 'Média',
      _ => 'Baixa',
    };
    return _MetaText(icon: Icons.flag, text: label, color: _priorityColor(priority));
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
    final effectiveColor = color ?? AppColors.textMuted;
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
    const color = AppColors.textMuted;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: color),
            ),
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
