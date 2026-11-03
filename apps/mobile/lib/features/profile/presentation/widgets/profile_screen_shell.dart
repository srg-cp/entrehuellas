import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/glass_navigation_bar.dart';
import '../../../../core/presentation/widgets/scroll_safe_area.dart';
import '../../../../core/theme/app_typography.dart';

/// Shared composition for the account overview and its data editor.
class ProfileScreenShell extends StatelessWidget {
  const ProfileScreenShell({
    required this.title,
    required this.child,
    required this.onBack,
    this.close = false,
    this.navigationEnabled = true,
    super.key,
  });
  final String title;
  final Widget child;
  final VoidCallback onBack;
  final bool close;
  final bool navigationEnabled;

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: ScrollSafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  GlassNavigationBar.topOf(context),
                  24,
                  ScrollSafeArea.bottomPadding(context, 32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final measure = TextPainter(
                          text: TextSpan(
                            text: title,
                            style: AppTypography.primaryTitle,
                          ),
                          textScaler: MediaQuery.textScalerOf(context),
                          textDirection: Directionality.of(context),
                        )..layout();
                        final inline =
                            measure.width + 68 <= constraints.maxWidth;
                        measure.dispose();
                        return Padding(
                          padding: EdgeInsets.only(
                            left: inline ? 68 : 0,
                            top: inline ? 0 : 72,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 52),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Semantics(
                                header: true,
                                child: Text(
                                  title,
                                  style: AppTypography.primaryTitle,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    child,
                  ],
                ),
              ),
              GlassNavigationBar(
                icon: close ? Icons.close_rounded : Icons.chevron_left_rounded,
                tooltip: close ? 'Cerrar perfil' : 'Volver al perfil',
                enabled: navigationEnabled,
                onBack: onBack,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
