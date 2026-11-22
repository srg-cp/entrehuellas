import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';

class PhotoAddTile extends StatelessWidget {
  const PhotoAddTile({
    required this.size,
    required this.onTap,
    required this.semanticLabel,
    this.invalid = false,
    super.key,
  });
  final double size;
  final VoidCallback? onTap;
  final String semanticLabel;
  final bool invalid;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(
        color: invalid ? AppColors.error : AppColors.divider,
        width: invalid ? 3.5 : 1,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Semantics(
          label: semanticLabel,
          button: true,
          child: Center(
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: invalid ? AppColors.error : AppColors.secondary,
            ),
          ),
        ),
      ),
    ),
  );
}
