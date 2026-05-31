# Especificação — Task Manager

## Objetivo

Cadastrar, listar, editar, concluir e excluir tarefas pessoais,
organizadas por categoria. Tudo offline.

## Escopo (intencionalmente reduzido)

Inclui: CRUD de tarefas, marcar como concluída, filtrar por status, categoria.
Fora de escopo: login, sincronização, notificações, anexos.

## Requisitos funcionais

- RF01: Criar tarefa (título obrigatório; descrição, prioridade, prazo e
  categoria opcionais).
- RF02: Listar tarefas, com indicação visual de concluídas.
- RF03: Marcar/desmarcar como concluída.
- RF04: Editar tarefa.   - RF05: Excluir tarefa.
- RF06: Filtrar por "todas / pendentes / concluídas".
- RF07: Listar e usar categorias.

## Regras de negócio

- Título não pode ser vazio.
- Prioridade ∈ {1 baixa, 2 média, 3 alta}.
- Excluir categoria não exclui tarefas (category_id vira nulo).
