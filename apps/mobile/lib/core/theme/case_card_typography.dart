import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Shared type hierarchy for the information cards in a public case.
abstract final class CaseCardTypography {
  static const label = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: Color(0xFF626975),
  );
  static const value = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: Color(0xFF111111),
  );
}
