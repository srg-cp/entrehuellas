import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'case_photo.dart';
import 'navigation_accent_surface.dart';

/// The case-map summary and details composition, shared without feature imports.
class MapCasePanel extends StatelessWidget {
  const MapCasePanel({
    required this.name,
    required this.traits,
    required this.details,
    this.photoUri,
    this.sectionTitle = 'Detalles del caso',
    this.scrollable = true,
    this.decorativeActions = false,
    this.onOpen,
    this.onSummaryHeight,
    super.key,
  });
  final String name, traits, sectionTitle;
  final Uri? photoUri;
  final Widget details;
  final bool scrollable, decorativeActions;
  final ValueChanged<BuildContext>? onOpen;
  final ValueChanged<double>? onSummaryHeight;
  @override
  Widget build(BuildContext context) {
    final photo = photoUri;
    final description = traits.trim();
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryMeasure(
            onHeight: onSummaryHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox.square(
                        key: const ValueKey('map-preview-photo'),
                        dimension: 112,
                        child: photo == null
                            ? const ColoredBox(
                                color: Color(0xFFF5F5F7),
                                child: Center(child: Icon(Icons.pets_outlined)),
                              )
                            : CasePhotoView.network(
                                photo,
                                semanticLabel: 'Foto principal del caso',
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'Sin nombre' : name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF171918),
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6E6E73),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ExcludeFocus(
                      excluding: decorativeActions,
                      child: ExcludeSemantics(
                        excluding: decorativeActions,
                        child: IgnorePointer(
                          ignoring: decorativeActions,
                          child: _OpenCaseButton(
                            onOpen: decorativeActions ? null : onOpen,
                            decorative: decorativeActions,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ExcludeFocus(
                  excluding: decorativeActions,
                  child: ExcludeSemantics(
                    excluding: decorativeActions,
                    child: IgnorePointer(
                      ignoring: decorativeActions,
                      child: Builder(
                        builder: (source) => TextButton.icon(
                          onPressed: decorativeActions || onOpen == null
                              ? null
                              : () => onOpen!(source),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF0F0F2),
                            foregroundColor: const Color(0xFF171918),
                            disabledForegroundColor: decorativeActions
                                ? const Color(0xFF171918)
                                : null,
                            disabledBackgroundColor: decorativeActions
                                ? const Color(0xFFF0F0F2)
                                : null,
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          icon: const Icon(Icons.pets_outlined, size: 20),
                          label: const Text('Ver ficha'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFE5E5EA)),
          ),
          Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171918),
            ),
          ),
          const SizedBox(height: 16),
          details,
        ],
      ),
    );
    return scrollable ? SingleChildScrollView(child: content) : content;
  }
}

class MapPanelFact extends StatelessWidget {
  const MapPanelFact({
    required this.label,
    required this.value,
    this.icon,
    this.leading,
    this.iconColor = const Color(0xFF8E8E93),
    super.key,
  }) : assert((icon == null) != (leading == null));
  static const labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF171918),
    height: 1.2,
  );
  final IconData? icon;
  final Widget? leading;
  final String label;
  final Widget value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExcludeSemantics(
        child:
            leading ??
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 22, color: iconColor),
            ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: 2),
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6E6E73),
                height: 1.2,
              ),
              child: value,
            ),
          ],
        ),
      ),
    ],
  );
}

class _OpenCaseButton extends StatefulWidget {
  const _OpenCaseButton({required this.onOpen, this.decorative = false});
  final bool decorative;
  final ValueChanged<BuildContext>? onOpen;
  @override
  State<_OpenCaseButton> createState() => _OpenCaseButtonState();
}

class _OpenCaseButtonState extends State<_OpenCaseButton> {
  bool _hovered = false, _focused = false, _pressed = false;
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: widget.onOpen == null && !widget.decorative ? .45 : 1,
    child: NavigationAccentSurface(
      engaged: widget.onOpen != null && (_hovered || _focused || _pressed),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onHover: (value) => setState(() => _hovered = value),
          onFocusChange: (value) => setState(() => _focused = value),
          onHighlightChanged: (value) => setState(() => _pressed = value),
          onTap: widget.onOpen == null ? null : () => widget.onOpen!(context),
          child: const Tooltip(
            message: 'Abrir ficha del caso',
            child: SizedBox.square(
              dimension: 48,
              child: Icon(
                Icons.north_east_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Reports the actual header/button height, independent of the sheet scroll.
class _SummaryMeasure extends SingleChildRenderObjectWidget {
  const _SummaryMeasure({required this.onHeight, required super.child});
  final ValueChanged<double>? onHeight;
  @override
  _SummaryMeasureRender createRenderObject(BuildContext context) =>
      _SummaryMeasureRender(onHeight);
  @override
  void updateRenderObject(
    BuildContext context,
    _SummaryMeasureRender renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _SummaryMeasureRender extends RenderProxyBox {
  _SummaryMeasureRender(this.onHeight);
  ValueChanged<double>? onHeight;
  double? _height;
  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (_height == height) return;
    _height = height;
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight?.call(height));
  }
}
