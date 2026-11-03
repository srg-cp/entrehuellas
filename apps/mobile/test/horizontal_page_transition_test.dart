import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';

void main() {
  for (final pending in [false, true]) {
    for (final reduced in [false, true]) {
      testWidgets(
        'A horizontal route owns initial content, then a discrete stage can reveal; pending=$pending reduced=$reduced',
        (tester) async {
          var loading = pending;
          var stage = 'list';
          late StateSetter update;
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: PageEntranceScope(
                  routeOwnsEntrance: true,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      update = setState;
                      return AuthStageTransition(
                        enabled: !loading,
                        stage: stage,
                        builder: (play) => ContentReveal(
                          loading: loading,
                          play: play,
                          count: 1,
                          child: StaggerRevealItem(
                            order: 0,
                            child: Text(loading ? 'Skeleton' : stage),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
          double opacity() =>
              tester.widget<Opacity>(find.byType(Opacity)).opacity;
          expect(opacity(), 1);
          await tester.pump(const Duration(milliseconds: 80));
          update(() => loading = false);
          await tester.pump();
          expect(opacity(), 1);
          expect(find.text('list'), findsOneWidget);
          update(() {});
          await tester.pump();
          expect(opacity(), 1);
          update(() => stage = 'editor');
          await tester.pump();
          expect(opacity(), reduced ? 1 : 0);
          await tester.pump(const Duration(milliseconds: 100));
          if (!reduced) expect(opacity(), inExclusiveRange(0, 1));
          await tester.pumpAndSettle();
          expect(opacity(), 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
