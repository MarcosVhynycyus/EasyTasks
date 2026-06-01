import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'models/task.dart';
import 'repositories/category_repository.dart';
import 'repositories/task_repository.dart';
import 'viewmodels/task_form_viewmodel.dart';
import 'viewmodels/task_list_viewmodel.dart';
import 'views/task_form_view.dart';
import 'views/task_list_view.dart';

void main() {
  runApp(const TaskManagerApp());
}

/// Raiz do app. Registra os ViewModels (Provider), monta o [MaterialApp] e
/// resolve a rota do formulário.
///
/// Os repositórios são injetáveis apenas para os testes; em produção ficam
/// `null` e são criados sobre o banco singleton.
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({
    super.key,
    this.taskRepository,
    this.categoryRepository,
  });

  final TaskRepository? taskRepository;
  final CategoryRepository? categoryRepository;

  @override
  Widget build(BuildContext context) {
    final taskRepo = taskRepository ?? TaskRepository();
    final categoryRepo = categoryRepository ?? CategoryRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              TaskListViewModel(taskRepo, categoryRepo)..inicializar(),
        ),
      ],
      child: MaterialApp(
        title: 'TaskFy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        home: const TaskListView(),
        onGenerateRoute: (settings) {
          if (settings.name == TaskFormView.routeName) {
            final task = settings.arguments as Task?;
            return MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) =>
                    TaskFormViewModel(taskRepo, categoryRepo, existing: task)
                      ..carregarCategorias(),
                child: const TaskFormView(),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
