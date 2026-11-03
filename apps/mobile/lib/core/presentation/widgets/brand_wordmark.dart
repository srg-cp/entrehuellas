import 'package:flutter/material.dart';

import 'brand_mark.dart';
import 'brand_name.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({this.iconSize = 52, this.textSize = 22, super.key})
    : revealProgress = null;

  /// One lockup for the startup motion and the pending account destination.
  const BrandWordmark.startup({this.revealProgress = 1, super.key})
    : iconSize = 80,
      textSize = 32;

  final double iconSize;
  final double textSize;
  final double? revealProgress;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Entre Huellas',
    child: ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: revealProgress != null
            ? _startupLockup(revealProgress!)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandMark(size: iconSize),
                  SizedBox(width: iconSize >= 76 ? 16 : 7),
                  BrandName(textSize: textSize),
                ],
              ),
      ),
    ),
  );

  Widget _startupLockup(double progress) {
    final textSizePixels = BrandName.sizeFor(textSize);
    final gap = iconSize >= 76 ? 16.0 : 7.0;
    final width = iconSize + gap + textSizePixels.width;
    final slide = Curves.easeOutBack.transform(progress);
    final iconLeft = (width - iconSize) / 2 * (1 - slide);
    final textLeft = (iconSize + gap) * slide;
    return SizedBox(
      width: width,
      height: iconSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRect(
              clipper: _BrandTextClipper(iconLeft + iconSize),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: textLeft,
                    top: (iconSize - textSizePixels.height) / 2,
                    child: Opacity(
                      opacity: Curves.easeOut.transform(progress),
                      child: BrandName(textSize: textSize),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: iconLeft,
            top: 0,
            child: BrandMark(size: iconSize),
          ),
        ],
      ),
    );
  }
}

class _BrandTextClipper extends CustomClipper<Rect> {
  const _BrandTextClipper(this.left);
  final double left;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(left, 0, size.width + 20, size.height);

  @override
  bool shouldReclip(_BrandTextClipper old) => old.left != left;
}
