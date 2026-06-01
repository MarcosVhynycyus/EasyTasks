import 'package:flutter/painting.dart';

/// Tokens de cor do TaskFy (tema escuro). Único lugar do app onde valores
/// hexadecimais podem aparecer — todo widget referencia estas constantes ou
/// `Theme.of(context).colorScheme.*`, nunca um `Color(0x...)` solto.
///
/// Os valores seguem `docs/visual_specs.md`.
abstract final class AppColors {
  // ── Cores base ────────────────────────────────────────────────────
  static const Color background = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFF2C7DA0);
  static const Color primaryDark = Color(0xFF1A5F7A);
  static const Color primaryLight = Color(0xFF5BA4C8);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color onSurface = Color(0xFFD3D3D3);
  static const Color backgroundAlt = Color(0xFFF5F7FA);

  // ── Derivações semânticas ─────────────────────────────────────────
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
  static const Color textMuted = Color(0xFF7A7A7A);
  static const Color divider = Color(0xFF333333);
  static const Color chipUnselected = Color(0xFF2E2E2E);

  // ── Prioridades ───────────────────────────────────────────────────
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFFA726);
  static const Color priorityHigh = Color(0xFFEF5350);
}
