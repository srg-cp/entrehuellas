import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'navigation_accent_surface.dart';
import 'origin_page_transition.dart';

/// Compact case actions, preserving the existing navigation accent and origin.
class CaseActionButton extends StatefulWidget {
  const CaseActionButton({
    required this.label,
    required this.icon,
    required this.route,
    this.accented = false,
    this.onReturn,
    super.key,
  });
  final String label, route;
  final IconData icon;
  final bool accented;
  final VoidCallback? onReturn;
  @override
  State<CaseActionButton> createState() => _CaseActionButtonState();
}

class _CaseActionButtonState extends State<CaseActionButton> {
  final _surface = GlobalKey();
  bool _opening = false;
  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await pushCaseControl(
        context,
        widget.route,
        _surface,
        color: widget.accented
            ? const Color(0xFF2887EF)
            : const Color(0xFFEDF2F8),
        radius: 28,
        identity: Icon(
          widget.icon,
          size: 25,
          color: widget.accented ? Colors.white : const Color(0xFF171918),
        ),
      );
      if (mounted) widget.onReturn?.call();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    excludeSemantics: true,
    enabled: !_opening,
    onTap: _opening ? null : _open,
    child: InkWell(
      onTap: _opening ? null : _open,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: _surface,
              width: 56,
              height: 56,
              child: widget.accented
                  ? NavigationAccentSurface(
                      engaged: false,
                      child: Icon(widget.icon, color: Colors.white, size: 25),
                    )
                  : DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEDF2F8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: const Color(0xFF171918),
                        size: 25,
                      ),
                    ),
            ),
            const SizedBox(height: 9),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w400,
                color: Color(0xFF171918),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Geometry and identity are captured from the visible control, not its label.
Future<T?> pushCaseControl<T>(
  BuildContext context,
  String route,
  GlobalKey key, {
  required Color color,
  required double radius,
  required Widget identity,
}) {
  final sourceContext = key.currentContext;
  return context.push<T>(
    route,
    extra: sourceContext == null
        ? null
        : OriginPageSource.capture(
            sourceContext,
            color: color,
            radius: radius,
            child: identity,
          ),
  );
}

class CaseUtilityButton extends StatefulWidget {
  const CaseUtilityButton({
    required this.title,
    required this.icon,
    required this.route,
    this.subtitle,
    this.padding = const EdgeInsets.all(14),
    this.onReturn,
    super.key,
  });
  final String title, route;
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final IconData icon;
  final VoidCallback? onReturn;
  @override
  State<CaseUtilityButton> createState() => _CaseUtilityButtonState();
}

class _CaseUtilityButtonState extends State<CaseUtilityButton> {
  final _surface = GlobalKey();
  bool _opening = false;
  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await pushCaseControl(
        context,
        widget.route,
        _surface,
        color: const Color(0xFFF0F1F3),
        radius: 22,
        identity: _content(),
      );
      if (mounted) widget.onReturn?.call();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Widget _content() => Padding(
    padding: widget.padding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(widget.icon, size: 21, color: const Color(0xFF171918)),
        const SizedBox(height: 7),
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 14,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: Color(0xFF171918),
          ),
        ),
        if (widget.subtitle case final subtitle?) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              color: Color(0xFF6E6E73),
            ),
          ),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: [widget.title, ?widget.subtitle].join('. '),
    excludeSemantics: true,
    enabled: !_opening,
    onTap: _opening ? null : _open,
    child: Material(
      key: _surface,
      color: const Color(0xFFF0F1F3),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: _opening ? null : _open, child: _content()),
    ),
  );
}

/// Natural wrapping under text enlargement; no labels or actions are clipped.
class CaseActionLayout extends StatelessWidget {
  const CaseActionLayout({
    required this.children,
    this.utilities = false,
    super.key,
  });
  final List<Widget> children;
  final bool utilities;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final enlarged = MediaQuery.textScalerOf(context).scale(14) > 20;
      final columns = utilities
          ? (enlarged && c.maxWidth < 360 ? 1 : 2)
          : (enlarged
                ? (c.maxWidth < 360 ? 1 : 2)
                : c.maxWidth < 280
                ? 2
                : 3);
      final width = (c.maxWidth - 12 * (columns - 1)) / columns;
      if (utilities && columns == 2 && children.length == 2) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[0]),
              const SizedBox(width: 12),
              Expanded(child: children[1]),
            ],
          ),
        );
      }
      return Wrap(
        spacing: 12,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          for (final child in children)
            SizedBox(
              width: children.length == 1 && utilities ? c.maxWidth : width,
              child: child,
            ),
        ],
      );
    },
  );
}
