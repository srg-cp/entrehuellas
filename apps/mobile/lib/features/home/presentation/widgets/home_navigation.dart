import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/origin_page_transition.dart';
import 'liquid_navigation.dart';

void openLostReport(
  BuildContext context, {
  VoidCallback? onReturn,
  Color color = const Color(0xFF111111),
  double radius = 32,
  Widget? identity,
}) {
  context
      .push(
        '/home/lost-cases/new',
        extra: OriginPageSource.capture(
          context,
          color: color,
          radius: radius,
          child:
              identity ??
              OriginTriggerIdentity.maybeOf(context) ??
              const Center(child: ReportNavigationIdentity()),
        ),
      )
      .then((_) => onReturn?.call());
}

void openHomeAction(
  BuildContext context,
  String path,
  Widget identity, {
  Color color = const Color(0xFF111111),
  double radius = 22,
}) => context.push(
  path,
  extra: OriginPageSource.capture(
    context,
    color: color,
    radius: radius,
    child: identity,
  ),
);
