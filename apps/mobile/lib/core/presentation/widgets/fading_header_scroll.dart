import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Persistent header with a soft, irregular transition over its live scroll.
/// Owns the overlap and compensating padding for every section using it.
class FadingHeaderScroll extends StatelessWidget {
  const FadingHeaderScroll({
    required this.header,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.scrollKey,
    this.physics = const AlwaysScrollableScrollPhysics(),
    super.key,
  });

  final Widget header, child;
  final EdgeInsets padding;
  final Key? scrollKey;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) => _FadingHeaderLayout(
    header: header,
    child: _ScrollFade(
      key: scrollKey,
      child: SingleChildScrollView(
        key: scrollKey,
        physics: physics,
        child: Padding(
          padding: padding.copyWith(
            top: padding.top + _FadingHeaderLayout.overlap,
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// Starts the scrolling viewport inside the header's lower margin, while
/// reserving the same space for the initial content and painting chrome last.
class _FadingHeaderLayout extends StatelessWidget {
  const _FadingHeaderLayout({required this.header, required this.child});

  static const overlap = 32.0;
  final Widget header, child;

  @override
  Widget build(BuildContext context) => CustomMultiChildLayout(
    delegate: _FadingHeaderLayoutDelegate(),
    children: [
      LayoutId(id: 'content', child: child),
      LayoutId(id: 'header', child: header),
    ],
  );
}

class _FadingHeaderLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final header = layoutChild(
      'header',
      BoxConstraints.tightFor(width: size.width),
    );
    final top = math.max(0.0, header.height - _FadingHeaderLayout.overlap);
    layoutChild(
      'content',
      BoxConstraints.tight(Size(size.width, math.max(0, size.height - top))),
    );
    positionChild('content', Offset(0, top));
    positionChild('header', Offset.zero);
  }

  @override
  bool shouldRelayout(_FadingHeaderLayoutDelegate oldDelegate) => false;
}

/// Dissolves scrolling content into the actual ambient background.
/// The header and navigation remain outside this layer and fully sharp.
class _ScrollFade extends StatefulWidget {
  const _ScrollFade({required this.child, super.key});

  final Widget child;

  @override
  State<_ScrollFade> createState() => _ScrollFadeState();
}

class _ScrollFadeState extends State<_ScrollFade> {
  double _extent = 0;
  ui.Image? _maskImage;
  ui.Shader? _maskShader;
  Size? _maskSize;
  double? _maskExtent;

  @override
  void dispose() {
    _maskShader?.dispose();
    _maskImage?.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final metrics = notification.metrics;
    // Grow continuously with the real scroll, without veiling the initial
    // title or adding a separate animation (including with reduced motion).
    final extent = (metrics.pixels - metrics.minScrollExtent).clamp(0.0, 48.0);
    if (extent != _extent) setState(() => _extent = extent);
    return false; // Keep pull-to-refresh and other scroll observers working.
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) {
            final height = math.min(_extent, bounds.height * .4);
            if (height <= 0) {
              return const LinearGradient(
                colors: [Colors.white, Colors.white],
              ).createShader(bounds);
            }
            if (_maskSize == bounds.size && _maskExtent == _extent) {
              return _maskShader!;
            }
            const gradient = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00FFFFFF),
                Color(0x0AFFFFFF),
                Color(0x26FFFFFF),
                Color(0x66FFFFFF),
                Color(0xCCFFFFFF),
                Colors.white,
              ],
              stops: [0, .18, .4, .65, .86, 1],
            );
            final width = bounds.width.ceil();
            final stripHeight = (height + 8).ceil();
            final recorder = ui.PictureRecorder();
            final canvas = Canvas(recorder);
            // Unequal soft extensions separated by clearer openings, rather
            // than a filled band with a wavy lower edge. No smoke texture.
            // The approved32px overlap and maximum48px depth stay intact.
            for (var x = 0; x < width; x++) {
              final t = (x + .5) / width;
              double extension(double center, double spread, double strength) {
                final distance = (t - center) / spread;
                return math.exp(-.5 * distance * distance) * strength;
              }

              final extensions =
                  (extension(.10, .065, .75) +
                          extension(.39, .085, .58) +
                          extension(.70, .07, 1) +
                          extension(.96, .075, .72))
                      .clamp(0.0, 1.0);
              final localHeight = height * (.50 + .50 * extensions);
              canvas.drawRect(
                Rect.fromLTWH(x.toDouble(), 0, 1, stripHeight.toDouble()),
                Paint()
                  ..shader = gradient.createShader(
                    Rect.fromLTWH(0, 0, width.toDouble(), localHeight),
                  ),
              );
            }
            final picture = recorder.endRecording();
            final image = picture.toImageSync(width, stripHeight);
            picture.dispose();
            final shader = ui.ImageShader(
              image,
              TileMode.clamp,
              TileMode.clamp,
              Matrix4.identity().storage,
              filterQuality: FilterQuality.low,
            );
            _maskShader?.dispose();
            _maskImage?.dispose();
            _maskShader = shader;
            _maskImage = image;
            _maskSize = bounds.size;
            _maskExtent = _extent;
            return shader;
          },
          child: widget.child,
        ),
      );
}
