# Task Manager

App Flutter de gerenciamento de tarefas pessoais. **100% local, sem backend** —
os dados ficam num banco SQLite no próprio dispositivo.

## Funcionalidades

- Criar tarefa (título obrigatório; descrição, prioridade, prazo e categoria opcionais)
- Listar tarefas, com indicação visual das concluídas
- Marcar / desmarcar como concluída
- Editar e excluir tarefas
- Filtrar por **todas / pendentes / concluídas**
- Organizar tarefas por categoria

## Stack

- **Flutter** (Dart)
- Estado com **provider** (`ChangeNotifier`)
- Persistência com **sqflite** + **path** (SQLite local)
- Testes com **sqflite_common_ffi** (banco em memória)

## Arquitetura

MVVM em 4 camadas, com dependência sempre num sentido:

```text
View → ViewModel → Repository → Database
```

- **models/** — classes de dados puras (sem UI, sem banco)
- **repositories/** — única camada que executa SQL; recebe e devolve Models
- **viewmodels/** — estado e regras de apresentação (`ChangeNotifier`)
- **views/** — telas; leem o estado via `context.watch` e disparam ações via `context.read`

## Estrutura do projeto

```text
lib/
├── main.dart                     # entrada + registro dos ViewModels (Provider)
├── core/database/
│   └── app_database.dart         # abre/cria o SQLite (singleton)
├── models/                       # task.dart, category.dart
├── repositories/                 # task_repository.dart, category_repository.dart
├── viewmodels/                   # task_list_viewmodel.dart, task_form_viewmodel.dart
└── views/                        # task_list_view.dart, task_form_view.dart
```

## Como rodar

```bash
flutter pub get      # instala as dependências
flutter run          # roda o app
```

## Desenvolvimento

```bash
flutter test         # roda os testes
flutter analyze      # análise estática (lint)
```

## Documentação

- [docs/specs.md](docs/specs.md) — especificação (requisitos e regras de negócio)
