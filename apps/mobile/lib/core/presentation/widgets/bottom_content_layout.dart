import 'package:flutter/material.dart';

/// Keeps a short content/action group at the bottom, scrolling when it grows.
/// Place persistent navigation/branding outside this layout.
class BottomContentLayout extends StatelessWidget {
  const BottomContentLayout({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: (constraints.maxHeight - 84).clamp(0, double.infinity),
        ),
        child: Column(
          mainAxisAlignment: MediaQuery.sizeOf(context).width >= 640
              ? MainAxisAlignment.center
              : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [child],
        ),
      ),
    ),
  );
}
