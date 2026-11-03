import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/presentation/widgets/stagger_stage_transition.dart';
import '../../../../core/presentation/widgets/bottom_content_layout.dart';
import 'onboarding_illustration.dart';
import 'onboarding_actions.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.page,
    required this.title,
    required this.description,
    required this.titleSamples,
    required this.descriptionSamples,
    required this.isBusy,
    required this.disabled,
    required this.pressScale,
    required this.onNext,
    super.key,
  });
  final int page;
  final String title;
  final String description;
  final List<String> titleSamples;
  final List<String> descriptionSamples;
  final bool isBusy;
  final bool disabled;
  final Animation<double> pressScale;
  final VoidCallback onNext;

  static const _descriptionStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.375,
    color: Color(0xFF71717A),
  );

  double _textHeight(
    BuildContext context,
    String text,
    TextStyle style,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = math.max(0.0, constraints.maxWidth - 48);
      final titleHeight = titleSamples
          .map(
            (text) => text
                .split('\n')
                .fold<double>(
                  0,
                  (height, line) =>
                      height +
                      _textHeight(
                        context,
                        line,
                        AppTypography.primaryTitle,
                        width,
                      ),
                ),
          )
          .reduce(math.max);
      final descriptionHeight = descriptionSamples
          .map((text) => _textHeight(context, text, _descriptionStyle, width))
          .reduce(math.max);
      return BottomContentLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StaggerStageItem(
              order: 0,
              child: SizedBox(
                height: math.min(
                  constraints.maxWidth - 48,
                  (constraints.maxHeight - 370).clamp(160.0, 460.0).toDouble(),
                ),
                width: double.infinity,
                child: OnboardingIllustration(page: page),
              ),
            ),
            const SizedBox(height: 32),
            StaggerStageItem(
              order: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: titleHeight),
                child: Semantics(
                  label: title,
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final line in title.split('\n'))
                          Text(
                            line,
                            style: AppTypography.primaryTitle,
                            textAlign: TextAlign.start,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            StaggerStageItem(
              order: 2,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: descriptionHeight),
                child: Text(
                  description,
                  textAlign: TextAlign.start,
                  style: _descriptionStyle,
                ),
              ),
            ),
            const SizedBox(height: 32),
            StaggerStageItem(
              order: 3,
              child: ScaleTransition(
                scale: pressScale,
                child: OnboardingActions(
                  page: page,
                  isBusy: isBusy,
                  disabled: disabled,
                  onNext: onNext,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
