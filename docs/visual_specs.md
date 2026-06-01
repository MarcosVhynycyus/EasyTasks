# Especificações Visuais — TaskFy

Documento de referência de design para o app TaskFy. Toda decisão de cor,
tipografia, espaçamento e componente deve ser consultada aqui antes de
implementar qualquer widget.

---

## Identidade

- **Nome do produto:** TaskFy
- **Tema padrão:** Escuro (`ThemeMode.dark`)
- **Logotipo:** ícone de lista de tarefas com check em azul sobre fundo branco
  arredondado; wordmark com "Task" em cinza claro e "Fy" em azul primário.
  Asset localizado em `assets/images/logo_taskfy.png`.

---

## Paleta de Cores

### Cores base

| Token                | Hex       | Uso principal                                              |
|----------------------|-----------|------------------------------------------------------------|
| `colorBackground`    | `#1E1E1E` | Fundo de todas as telas e scaffolds                        |
| `colorPrimary`       | `#2C7DA0` | Ações primárias, FAB, chips selecionados, links, progress  |
| `colorSurface`       | `#2A2A2A` | Cards, bottom sheets, dialogs, campos de texto             |
| `colorOnSurface`     | `#D3D3D3` | Texto principal, ícones sobre superfícies escuras          |
| `colorBackgroundAlt` | `#F5F7FA` | **Reservado para tema claro** ou contrastes pontuais       |

> **Regra:** nunca use valores hex diretamente nos widgets. Sempre referencie
> via `Theme.of(context).colorScheme.*` ou a constante `AppColors.*` definida
> em `lib/core/theme/app_colors.dart`.

### Derivações semânticas

| Token semântico         | Cor base        | Hex sugerido | Uso                                      |
|-------------------------|-----------------|--------------|------------------------------------------|
| `colorPrimaryDark`      | Primary escuro  | `#1A5F7A`    | Estado pressed/hover do primário         |
| `colorPrimaryLight`     | Primary claro   | `#5BA4C8`    | Ícones e textos sobre fundo primário     |
| `colorError`            | Erro            | `#CF6679`    | Validações, snackbars de erro            |
| `colorSuccess`          | Sucesso         | `#4CAF50`    | Tarefa concluída (ícone check)           |
| `colorTextMuted`        | Texto suave     | `#7A7A7A`    | Placeholders, metadados, datas           |
| `colorDivider`          | Separador       | `#333333`    | Dividers entre itens da lista            |
| `colorChipUnselected`   | Chip inativo    | `#2E2E2E`    | Background de chips de filtro não ativos |

### Prioridades (badge de cor)

| Prioridade | Label  | Cor         |
|------------|--------|-------------|
| 1 — Baixa  | Baixa  | `#4CAF50`   |
| 2 — Média  | Média  | `#FFA726`   |
| 3 — Alta   | Alta   | `#EF5350`   |

### Categorias (seed inicial)

| Categoria | Cor       |
|-----------|-----------|
| Trabalho  | `#1565C0` |
| Pessoal   | `#2E7D32` |
| Estudos   | `#6A1B9A` |
| Casa      | `#EF6C00` |

---

## Tipografia

Família base: **Roboto** (padrão do Material3 no Android/Flutter).

| Estilo             | Uso                                  | Tamanho | Peso       |
|--------------------|--------------------------------------|---------|------------|
| `headlineMedium`   | Título da tela (AppBar)              | 22 sp   | Medium 500 |
| `titleMedium`      | Título da tarefa na lista            | 16 sp   | Medium 500 |
| `bodyMedium`       | Descrição, corpo de texto            | 14 sp   | Regular    |
| `labelSmall`       | Badge de prioridade, chip de filtro  | 11 sp   | Medium 500 |
| `bodySmall`        | Data de prazo, metadados             | 12 sp   | Regular    |

Cor de texto padrão: `colorOnSurface` (`#D3D3D3`).  
Texto sobre fundo primário: `colorPrimaryLight` (`#5BA4C8`) ou branco puro.

---

## Espaçamento e Grid

Sistema de 4 pt. Todos os valores de padding/margin são múltiplos de 4.

| Token           | Valor | Uso típico                                        |
|-----------------|-------|---------------------------------------------------|
| `spaceXS`       | 4 pt  | Espaço interno mínimo (ícone ↔ label)             |
| `spaceSM`       | 8 pt  | Padding horizontal de chips; gap entre badges     |
| `spaceMD`       | 16 pt | Padding horizontal de cards e telas               |
| `spaceLG`       | 24 pt | Margem entre seções                               |
| `spaceXL`       | 32 pt | Espaçamento de topo/base em telas de formulário   |

---

## Componentes

### AppBar

```dart
AppBar(
  backgroundColor: Color(0xFF1E1E1E), // colorBackground
  foregroundColor: Color(0xFFD3D3D3), // colorOnSurface
  elevation: 0,
  centerTitle: false,
  title: Text('TaskFy', style: Theme.of(context).textTheme.headlineMedium),
)
```

### Card de Tarefa

- Background: `colorSurface` (`#2A2A2A`)
- Border radius: `12 pt`
- Padding interno: `16 pt`
- Sombra: `BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))`
- Tarefa concluída: título com `TextDecoration.lineThrough` e opacidade `0.5`
- Indicador lateral de prioridade: barra de `4 pt` de largura na borda esquerda,
  cor conforme tabela de prioridades acima.

### Chips de Filtro

```dart
FilterChip(
  backgroundColor: Color(0xFF2E2E2E),         // colorChipUnselected
  selectedColor:   Color(0xFF2C7DA0),          // colorPrimary
  labelStyle: TextStyle(color: Color(0xFFD3D3D3)),
  checkmarkColor:  Colors.white,
  side: BorderSide.none,
  shape: StadiumBorder(),
)
```

### FAB (criar tarefa)

```dart
FloatingActionButton(
  backgroundColor: Color(0xFF2C7DA0), // colorPrimary
  foregroundColor: Colors.white,
  shape: CircleBorder(),
  child: Icon(Icons.add),
)
```

### Campo de Texto (formulário)

```dart
InputDecoration(
  filled: true,
  fillColor: Color(0xFF2A2A2A),            // colorSurface
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Color(0xFF333333)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Color(0xFF2C7DA0), width: 2),
  ),
  labelStyle: TextStyle(color: Color(0xFF7A7A7A)), // colorTextMuted
)
```

### SnackBar

- Background: `colorSurface` (`#2A2A2A`)
- Texto: `colorOnSurface` (`#D3D3D3`)
- Ação (ex.: "Desfazer"): `colorPrimary` (`#2C7DA0`)

---

## ThemeData recomendado

```dart
// lib/core/theme/app_theme.dart

ThemeData darkTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1E1E1E),
  colorScheme: const ColorScheme.dark(
    primary:    Color(0xFF2C7DA0),
    onPrimary:  Colors.white,
    surface:    Color(0xFF2A2A2A),
    onSurface:  Color(0xFFD3D3D3),
    error:      Color(0xFFCF6679),
  ),
  cardColor:    const Color(0xFF2A2A2A),
  dividerColor: const Color(0xFF333333),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF2E2E2E),
    selectedColor:   const Color(0xFF2C7DA0),
    labelStyle: const TextStyle(color: Color(0xFFD3D3D3)),
    side: BorderSide.none,
    shape: const StadiumBorder(),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2C7DA0),
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Color(0xFFD3D3D3),
    elevation: 0,
    centerTitle: false,
  ),
  useMaterial3: true,
);
```

Registre no `MaterialApp`:

```dart
MaterialApp(
  theme:     AppTheme.darkTheme(), // tema escuro como padrão
  themeMode: ThemeMode.dark,
  // ...
)
```

---

## Assets

```
assets/
└── images/
    └── logo_taskfy.png   # logotipo completo (ícone + wordmark)
```

Declare em `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/logo_taskfy.png
```

---

## Acessibilidade

- Contraste mínimo entre texto e fundo: **4.5 : 1** (WCAG AA).
  `#D3D3D3` sobre `#1E1E1E` atinge ≈ 10 : 1 — aprovado.
- Todos os ícones de ação devem ter `Tooltip` ou `semanticLabel`.
- Tamanho mínimo de área de toque: **48 × 48 pt** (Material guideline).
- Nunca transmita informação só por cor (ex.: use ícone + cor no badge de
  prioridade, não apenas a cor).
