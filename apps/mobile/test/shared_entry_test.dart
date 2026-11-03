import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_page_background.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_public_screen_shell.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/entity_screen_shell.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';

void main() {
  for (final publicCase in [false, true]) {
    for (final reduced in [false, true]) {
      testWidgets(
        'Cached ${publicCase ? 'public case' : 'entity'} enters once, reduced=$reduced',
        (tester) async {
          tester.view.physicalSize = Size(
            reduced ? 320 : 390,
            reduced ? 600 : 844,
          );
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          late StateSetter update;
          var stage = 'Formulario';
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  disableAnimations: reduced,
                  textScaler: TextScaler.linear(reduced ? 2 : 1),
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    update = setState;
                    final content = StaggerRevealItem(
                      order: 0,
                      child: Text(stage),
                    );
                    return publicCase
                        ? CasePublicScreenShell(loading: false, child: content)
                        : EntityScreenShell(
                            loading: false,
                            stage: stage,
                            child: content,
                          );
                  },
                ),
              ),
            ),
          );
          double opacity() => tester
              .widget<Opacity>(
                find
                    .ancestor(
                      of: find.text(stage),
                      matching: find.byType(Opacity),
                    )
                    .first,
              )
              .opacity;
          Future<void> checkEntrance() async {
            expect(opacity(), reduced ? 1 : 0);
            var previous = opacity();
            final timeline = tester.state(find.byType(ContentReveal));
            for (var frame = 0; frame < 120; frame++) {
              await tester.pump(const Duration(milliseconds: 16));
              expect(find.byType(CoverReveal), findsNothing);
              expect(find.byType(AppPageBackground), findsOneWidget);
              expect(tester.state(find.byType(ContentReveal)), same(timeline));
              expect(opacity(), greaterThanOrEqualTo(previous));
              previous = opacity();
              if (frame == 10 && !reduced) {
                expect(previous, inExclusiveRange(0, 1));
              }
            }
            expect(opacity(), 1);
            update(() {});
            await tester.pump();
            expect(tester.state(find.byType(ContentReveal)), same(timeline));
            expect(opacity(), 1);
          }

          await checkEntrance();
          if (!publicCase) {
            update(() => stage = 'Vista previa');
            await tester.pump();
            expect(find.text('Formulario'), findsNothing);
            await checkEntrance();
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}
