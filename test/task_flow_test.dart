import 'package:easy_tasks/core/database/app_database.dart';
import 'package:easy_tasks/main.dart';
import 'package:easy_tasks/repositories/category_repository.dart';
import 'package:easy_tasks/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    // Em widget tests (FakeAsync) usamos a fábrica sem isolate para que as
    // operações do banco resolvam dentro do pumpAndSettle.
    final db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: AppDatabase.onConfigure,
        onCreate: AppDatabase.onCreate,
      ),
    );
    appDatabase = AppDatabase.forTesting(db);
  });

  tearDown(() async {
    final db = await appDatabase.database;
    await db.close();
  });

  testWidgets('fluxo completo: criar, concluir, editar, filtrar e excluir',
      (tester) async {
    await tester.pumpWidget(
      TaskManagerApp(
        taskRepository: TaskRepository(appDatabase),
        categoryRepository: CategoryRepository(appDatabase),
      ),
    );
    await tester.pumpAndSettle();

    // A lista começa vazia (RF02).
    expect(find.textContaining('Nenhuma tarefa'), findsOneWidget);

    // RF01: criar tarefa.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Salvar'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Comprar leite');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Voltou para a lista com a tarefa criada (RF02).
    expect(find.text('Comprar leite'), findsOneWidget);

    // RF04: editar a tarefa (toque na linha).
    await tester.tap(find.text('Comprar leite'));
    await tester.pumpAndSettle();
    expect(find.text('Editar tarefa'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Comprar leite e pão');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar leite e pão'), findsOneWidget);

    // RF03: marcar como concluída.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // RF06: filtrar por status.
    await tester.tap(find.text('Concluídas'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar leite e pão'), findsOneWidget);

    await tester.tap(find.text('Pendentes'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar leite e pão'), findsNothing);

    // "Todas" existe no filtro de status e no de categorias; selecionamos o do
    // status (SegmentedButton) para voltar a ver todas as tarefas.
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<int>),
        matching: find.text('Todas'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Comprar leite e pão'), findsOneWidget);

    // RF05: excluir (com confirmação).
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar leite e pão'), findsNothing);
    expect(find.textContaining('Nenhuma tarefa'), findsOneWidget);
  });
}
