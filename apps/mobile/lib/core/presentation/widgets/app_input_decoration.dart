import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';

InputDecoration appInputDecoration(
  String? hint,
  IconData? icon, {
  Widget? suffix,
  bool invalid = false,
  double verticalPadding = 22,
}) => InputDecoration(
  hintText: hint,
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: const BorderSide(color: AppColors.error, width: 3.5),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: const BorderSide(color: AppColors.error, width: 3.5),
  ),
  hintStyle: const TextStyle(
    fontSize: 16,
    height: 27 / 16,
    color: AppColors.secondary,
  ),
  prefixIcon: icon == null
      ? null
      : Icon(
          icon,
          size: 22,
          color: invalid ? AppColors.error : AppColors.secondary,
        ),
  suffixIcon: suffix,
  filled: true,
  fillColor: AppColors.surface,
  contentPadding: EdgeInsets.symmetric(
    vertical: verticalPadding,
    horizontal: 16,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(
      color: invalid ? AppColors.error : AppColors.divider,
      width: invalid ? 3.5 : 1,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(
      color: invalid ? AppColors.error : AppColors.divider,
      width: invalid ? 3.5 : 1,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(
      color: invalid ? AppColors.error : AppColors.secondary,
      width: invalid ? 3.5 : 1.5,
    ),
  ),
);
