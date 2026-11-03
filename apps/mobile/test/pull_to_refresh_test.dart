import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/pull_to_refresh.dart';

Finder get glyph => find.byIcon(Icons.refresh_rounded);
Transform rotation(WidgetTester tester) => tester.widget<Transform>(
  find.ancestor(of: glyph, matching: find.byType(Transform)).first,
);

void main() {
  testWidgets(
    'Long slow pull keeps turning before release without refreshing',
    (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      var calls = 0;
      await tester.pumpWidget(
        _screen(scroll, false, false, () async => calls++),
      );
      final gesture = await tester.startGesture(const Offset(160, 70));
      await gesture.moveBy(const Offset(0, 260));
      await tester.pump(const Duration(milliseconds: 200));
      final before = rotation(tester).transform.clone();
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 200));
      expect(rotation(tester).transform, isNot(before));
      expect(calls, 0);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, 1);
    },
  );

  for (final bouncing in [false, true]) {
    testWidgets(
      'Reversing retracts overlay without scrolling; bounce=$bouncing',
      (tester) async {
        final scroll = ScrollController();
        addTearDown(scroll.dispose);
        var calls = 0;
        await tester.pumpWidget(
          _screen(scroll, bouncing, false, () async => calls++),
        );
        final gesture = await tester.startGesture(const Offset(160, 150));
        await gesture.moveBy(const Offset(0, 30));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 250));
        await tester.pump();
        final before = tester.getCenter(glyph).dy;
        await gesture.moveBy(const Offset(0, -200));
        await tester.pump();
        expect(tester.getCenter(glyph).dy, lessThan(before));
        expect(scroll.offset, 0);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(calls, 0);
        expect(scroll.offset, 0);
      },
    );

    testWidgets(
      'Drag starting inside content cannot acquire refresh at top; bounce=$bouncing',
      (tester) async {
        final scroll = ScrollController(initialScrollOffset: 80);
        addTearDown(scroll.dispose);
        var calls = 0;
        await tester.pumpWidget(
          _screen(scroll, bouncing, false, () async => calls++),
        );
        final gesture = await tester.startGesture(const Offset(160, 150));
        await gesture.moveBy(const Offset(0, 30));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 300));
        await tester.pump();
        await gesture.moveBy(const Offset(0, -15));
        await tester.pump();
        expect(
          tester
              .widget<Opacity>(
                find.ancestor(of: glyph, matching: find.byType(Opacity)).first,
              )
              .opacity,
          0,
        );
        await gesture.up();
        await tester.pumpAndSettle();
        expect(calls, 0);
      },
    );

    testWidgets('Canceled armed pointer never refreshes; bounce=$bouncing', (
      tester,
    ) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      var calls = 0;
      await tester.pumpWidget(
        _screen(scroll, bouncing, false, () async => calls++),
      );
      final gesture = await tester.startGesture(const Offset(160, 150));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 300));
      await tester.pump();
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(scroll.offset, 0);
      await tester.dragFrom(const Offset(160, 300), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(0));
    });

    for (final reduced in [false, true]) {
      testWidgets(
        'Partial pull retracts to top; bounce=$bouncing reduced=$reduced',
        (tester) async {
          final scroll = ScrollController();
          addTearDown(scroll.dispose);
          var calls = 0;
          await tester.pumpWidget(
            _screen(scroll, bouncing, reduced, () async => calls++),
          );
          final gesture = await tester.startGesture(const Offset(160, 150));
          await gesture.moveBy(const Offset(0, 25));
          await tester.pump(const Duration(milliseconds: 100));
          await gesture.moveBy(const Offset(0, 25));
          await tester.pump(const Duration(milliseconds: 100));
          final before = rotation(tester).transform.clone();
          await gesture.moveBy(const Offset(0, 20));
          await tester.pump(const Duration(milliseconds: 100));
          expect(rotation(tester).transform == before, reduced);
          await gesture.up();
          await tester.pumpAndSettle();
          expect(calls, 0);
          expect(scroll.offset, closeTo(scroll.position.minScrollExtent, .01));
          final opacity = tester.widget<Opacity>(
            find.ancestor(of: glyph, matching: find.byType(Opacity)).first,
          );
          expect(opacity.opacity, 0);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'Full pull refreshes once and rests at top; bounce=$bouncing reduced=$reduced',
        (tester) async {
          final scroll = ScrollController();
          addTearDown(scroll.dispose);
          var calls = 0;
          final pending = Completer<void>();
          await tester.pumpWidget(
            _screen(scroll, bouncing, reduced, () async {
              calls++;
              await pending.future;
            }),
          );
          await tester.dragFrom(const Offset(160, 130), const Offset(0, 420));
          await tester.pump();
          for (var frame = 0; frame < 20; frame++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
          await tester.pump(const Duration(milliseconds: 300));
          expect(calls, 1);
          expect(scroll.offset, closeTo(scroll.position.minScrollExtent, .01));
          final before = rotation(tester).transform.clone();
          await tester.pump(const Duration(milliseconds: 100));
          expect(rotation(tester).transform == before, reduced);
          await tester.dragFrom(const Offset(160, 130), const Offset(0, 300));
          await tester.pump(const Duration(milliseconds: 500));
          expect(calls, 1);
          pending.complete();
          await tester.pumpAndSettle();
          expect(scroll.offset, closeTo(scroll.position.minScrollExtent, .01));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Small viewport with large text retracts in reduced motion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    var calls = 0;
    await tester.pumpWidget(
      _screen(scroll, false, true, () async => calls++, textScale: 2),
    );
    final gesture = await tester.startGesture(const Offset(160, 200));
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 180));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -230));
    await tester.pump();
    expect(scroll.offset, 0);
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(of: glyph, matching: find.byType(Opacity)).first,
          )
          .opacity,
      0,
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Upward start cannot turn into refresh within the same drag', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    var calls = 0;
    await tester.pumpWidget(_screen(scroll, false, false, () async => calls++));
    final gesture = await tester.startGesture(const Offset(160, 200));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 300));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -10));
    await tester.pump();
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(of: glyph, matching: find.byType(Opacity)).first,
          )
          .opacity,
      0,
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('Removing an active pull releases its scroll hold', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    var calls = 0;
    await tester.pumpWidget(_screen(scroll, false, false, () async => calls++));
    final gesture = await tester.startGesture(const Offset(160, 200));
    await gesture.moveBy(const Offset(0, 200));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Scrolling inside content does not refresh or jump to top', (
    tester,
  ) async {
    final scroll = ScrollController(initialScrollOffset: 500);
    addTearDown(scroll.dispose);
    var calls = 0;
    await tester.pumpWidget(_screen(scroll, false, false, () async => calls++));
    await tester.timedDragFrom(
      const Offset(160, 200),
      const Offset(0, 100),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(scroll.offset, greaterThan(300));
  });
}

Widget _screen(
  ScrollController scroll,
  bool bouncing,
  bool reduced,
  Future<void> Function() refresh, {
  double textScale = 1,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      disableAnimations: reduced,
      textScaler: TextScaler.linear(textScale),
    ),
    child: Scaffold(
      body: PullToRefresh(
        onRefresh: refresh,
        child: SingleChildScrollView(
          controller: scroll,
          physics: bouncing
              ? const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                )
              : const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
          child: const SizedBox(height: 2400, child: Text('Contenido actual')),
        ),
      ),
    ),
  ),
);
