import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_stage_transition.dart';

void main() {
  testWidgets(
    'Stage timeline settles reduced motion mid-exit and cancels on disposal',
    (tester) async {
      final reduced = ValueNotifier(false);
      addTearDown(reduced.dispose);
      final motion = GlobalKey<StaggerStageTransitionState>();
      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder(
            valueListenable: reduced,
            builder: (context, value, _) => MediaQuery(
              data: MediaQueryData(disableAnimations: value),
              child: StaggerStageTransition(
                key: motion,
                child: Column(
                  children: [
                    for (var i = 0; i < 4; i++)
                      StaggerStageItem(order: i, child: Text('group $i')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      double opacity(int group) => tester
          .widget<Opacity>(
            find.ancestor(
              of: find.text('group $group'),
              matching: find.byType(Opacity),
            ),
          )
          .opacity;
      final exiting = motion.currentState!.hide();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(opacity(3), lessThan(1));
      expect(opacity(0), 1);
      reduced.value = true;
      await tester.pumpAndSettle();
      expect(await exiting, isTrue);
      for (var i = 0; i < 4; i++) {
        expect(opacity(i), 0);
      }
      final entering = motion.currentState!.reveal();
      await tester.pumpAndSettle();
      expect(await entering, isTrue);
      for (var i = 0; i < 4; i++) {
        expect(opacity(i), 1);
      }
      reduced.value = false;
      await tester.pump();
      final cancelled = motion.currentState!.hide();
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      expect(await cancelled, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
