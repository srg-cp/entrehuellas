import 'package:flutter/material.dart';

/// A single accessible target for a profile destination, including its chevron.
class ProfileNavigationRow extends StatelessWidget {
  const ProfileNavigationRow({
    required this.leading,
    required this.child,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    this.semanticLabel,
    super.key,
  });
  final Widget leading;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    button: true,
    enabled: onTap != null,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: padding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Give enlarged labels the full column before breaking a word.
              // The material and text size never depend on the chosen layout.
              final content = child;
              var stacked = false;
              if (content is Text && content.data != null) {
                final measure = TextPainter(
                  text: TextSpan(
                    text: content.data!.split(RegExp(r'\s+')).join('\n'),
                    style: DefaultTextStyle.of(
                      context,
                    ).style.merge(content.style),
                  ),
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout();
                stacked = measure.width > constraints.maxWidth - 74;
                measure.dispose();
              }
              return Row(
                children: [
                  if (!stacked) ...[
                    ExcludeSemantics(child: leading),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: stacked
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExcludeSemantics(child: leading),
                              const SizedBox(height: 12),
                              child,
                            ],
                          )
                        : child,
                  ),
                  const SizedBox(width: 12),
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: Color(0xFF6E6E73),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
