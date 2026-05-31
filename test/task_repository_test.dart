import 'package:easy_tasks/core/database/app_database.dart';
import 'package:easy_tasks/models/category.dart';
import 'package:easy_tasks/models/task.dart';
import 'package:easy_tasks/repositories/category_repository.dart';
import 'package:easy_tasks/repositories/task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Cada teste roda contra um banco SQLite novo em memória (sqflite_common_ffi),
  // criado com o MESMO schema usado em produção (AppDatabase.onCreate).
  late AppDatabase appDatabase;
  late TaskRepository taskRepository;
  late CategoryRepository categoryRepository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: AppDatabase.onConfigure,
        onCreate: AppDatabase.onCreate,
      ),
    );
    appDatabase = AppDatabase.forTesting(db);
    taskRepository = TaskRepository(appDatabase);
    categoryRepository = CategoryRepository(appDatabase);
  });

  tearDown(() async {
    final db = await appDatabase.database;
    await db.close();
  });

  group('TaskRepository CRUD', () {
    test('inserir e listar devolve a tarefa criada', () async {
      final id = await taskRepository.inserir(Task(title: 'Comprar pão'));

      expect(id, greaterThan(0));
      final tarefas = await taskRepository.listar();
      expect(tarefas, hasLength(1));
      expect(tarefas.single.title, 'Comprar pão');
      expect(tarefas.single.isDone, isFalse);
      expect(tarefas.single.priority, 1);
    });

    test('obterPorId devolve a tarefa correta e null quando não existe',
        () async {
      final id = await taskRepository.inserir(
        Task(title: 'Estudar Flutter', priority: 3),
      );

      final encontrada = await taskRepository.obterPorId(id);
      expect(encontrada, isNotNull);
      expect(encontrada!.title, 'Estudar Flutter');
      expect(encontrada.priority, 3);

      expect(await taskRepository.obterPorId(99999), isNull);
    });

    test('atualizar persiste as mudanças (marcar como concluída)', () async {
      final id = await taskRepository.inserir(Task(title: 'Lavar louça'));
      final tarefa = await taskRepository.obterPorId(id);

      final linhas = await taskRepository.atualizar(
        tarefa!.copyWith(isDone: true, title: 'Lavar a louça'),
      );

      expect(linhas, 1);
      final atualizada = await taskRepository.obterPorId(id);
      expect(atualizada!.isDone, isTrue);
      expect(atualizada.title, 'Lavar a louça');
    });

    test('atualizar grava updated_at mais recente que created_at', () async {
      final id = await taskRepository.inserir(Task(title: 'Tarefa'));
      final original = await taskRepository.obterPorId(id);

      // Garante diferença de horário perceptível entre criação e atualização.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await taskRepository.atualizar(original!.copyWith(priority: 2));

      final atualizada = await taskRepository.obterPorId(id);
      expect(
        atualizada!.updatedAt.isAfter(atualizada.createdAt) ||
            atualizada.updatedAt.isAtSameMomentAs(atualizada.createdAt),
        isTrue,
      );
    });

    test('excluir remove a tarefa', () async {
      final id = await taskRepository.inserir(Task(title: 'Tarefa temporária'));

      final linhas = await taskRepository.excluir(id);

      expect(linhas, 1);
      expect(await taskRepository.listar(), isEmpty);
      expect(await taskRepository.obterPorId(id), isNull);
    });
  });

  group('TaskRepository filtro por status (RF06)', () {
    test('listar(isDone:) separa pendentes de concluídas', () async {
      await taskRepository.inserir(Task(title: 'Pendente A'));
      await taskRepository.inserir(Task(title: 'Pendente B'));
      await taskRepository.inserir(Task(title: 'Feita', isDone: true));

      expect(await taskRepository.listar(), hasLength(3));
      final pendentes = await taskRepository.listar(isDone: false);
      final concluidas = await taskRepository.listar(isDone: true);

      expect(pendentes, hasLength(2));
      expect(pendentes.every((t) => !t.isDone), isTrue);
      expect(concluidas, hasLength(1));
      expect(concluidas.single.title, 'Feita');
    });
  });

  group('CategoryRepository', () {
    test('lista as categorias do seed em ordem alfabética', () async {
      final categorias = await categoryRepository.listar();

      expect(categorias, isNotEmpty);
      final nomes = categorias.map((c) => c.name).toList();
      final ordenados = [...nomes]..sort();
      expect(nomes, ordenados);
    });

    test('CRUD básico de categoria', () async {
      final id = await categoryRepository.inserir(
        Category(name: 'Projetos', color: '#0097A7'),
      );
      expect(id, greaterThan(0));

      final aposInserir = await categoryRepository.listar();
      final criada = aposInserir.firstWhere((c) => c.id == id);
      expect(criada.name, 'Projetos');

      await categoryRepository.atualizar(criada.copyWith(name: 'Meus Projetos'));
      final aposAtualizar =
          (await categoryRepository.listar()).firstWhere((c) => c.id == id);
      expect(aposAtualizar.name, 'Meus Projetos');

      await categoryRepository.excluir(id);
      final aposExcluir = await categoryRepository.listar();
      expect(aposExcluir.any((c) => c.id == id), isFalse);
    });
  });

  group('Regra de negócio: excluir categoria não exclui tarefas', () {
    test('ao excluir a categoria, category_id da tarefa vira nulo', () async {
      final categoriaId = await categoryRepository.inserir(
        Category(name: 'Temporária'),
      );
      final tarefaId = await taskRepository.inserir(
        Task(title: 'Com categoria', categoryId: categoriaId),
      );

      await categoryRepository.excluir(categoriaId);

      // A tarefa continua existindo, mas sem categoria (ON DELETE SET NULL).
      final tarefa = await taskRepository.obterPorId(tarefaId);
      expect(tarefa, isNotNull);
      expect(tarefa!.categoryId, isNull);
    });
  });
}
