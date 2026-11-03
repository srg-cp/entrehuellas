import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_page_background.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/startup_reveal.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/screens/access_screen.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';

import 'access_test.dart' show FakeAccess;

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'Login enters once without a background curtain, reduced=$reduced',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              accessRepositoryProvider.overrideWithValue(FakeAccess()),
            ],
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(disableAnimations: reduced),
                child: child!,
              ),
              home: const StartupReveal(child: AccessScreen()),
            ),
          ),
        );
        if (!reduced) {
          expect(find.byType(AccessScreen), findsNothing);
          await tester.pump(const Duration(milliseconds: 1101));
        }
        final timeline = tester.state(find.byType(StaggerReveal));
        final brand = tester.getTopLeft(
          find.byKey(const ValueKey('auth-brand')),
        );
        double titleOpacity() => tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.byKey(const ValueKey('auth-title')),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity;
        var previous = titleOpacity();
        expect(previous, reduced ? 1 : 0);
        for (var frame = 0; frame < 120; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(find.byType(CoverReveal), findsNothing);
          expect(find.byType(AppPageBackground), findsOneWidget);
          expect(tester.state(find.byType(StaggerReveal)), same(timeline));
          expect(
            tester.getTopLeft(find.byKey(const ValueKey('auth-brand'))),
            brand,
          );
          expect(titleOpacity(), greaterThanOrEqualTo(previous));
          previous = titleOpacity();
          if (frame == 20 && !reduced) expect(previous, inExclusiveRange(0, 1));
        }
        expect(titleOpacity(), 1);
        await tester.enterText(
          find.byKey(const ValueKey('login-email')),
          'user@example.com',
        );
        await tester.pump();
        expect(titleOpacity(), 1);
        expect(tester.state(find.byType(StaggerReveal)), same(timeline));
        expect(tester.takeException(), isNull);
        // The ambient background repeats indefinitely; unmount before settling.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
