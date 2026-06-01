import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema visual do TaskFy. Centraliza o [ThemeData] escuro do app para que os
/// widgets consumam cores via `Theme.of(context)` em vez de repetir valores.
abstract final class AppTheme {
  /// Tema escuro padrão do app, conforme `docs/visual_specs.md`.
  static ThemeData darkTheme() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          error: AppColors.error,
        ),
        cardColor: AppColors.surface,
        dividerColor: AppColors.divider,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.chipUnselected,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(color: AppColors.onSurface),
          checkmarkColor: Colors.white,
          side: BorderSide.none,
          shape: StadiumBorder(),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: TextStyle(color: AppColors.textMuted),
        ),
      );
}
