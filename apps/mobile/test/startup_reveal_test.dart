import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/startup_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/brand_mark.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/brand_name.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/brand_wordmark.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_scaffold.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/presentation/screens/entry_screen.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/presentation/state/entry_destination.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/presentation/view_models/entry_view_model.dart';

class _PendingEntry extends EntryViewModel {
  final pending = Completer<EntryDestination>();

  @override
  Future<EntryDestination> build() => pending.future;
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (Platform.environment['CAPTURE_STARTUP'] != '1') return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/ui-preview/startup')
      ..createSync(recursive: true);
    File(
      '${directory.path}/$name.png',
    ).writeAsBytesSync(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  for (final layout in [
    (
      name: 'iphone',
      size: const Size(414, 896),
      top: 47.0,
      bottom: 34.0,
      side: 0.0,
      scale: 1.0,
    ),
    (
      name: 'android',
      size: const Size(390, 844),
      top: 24.0,
      bottom: 24.0,
      side: 0.0,
      scale: 1.0,
    ),
    (
      name: 'small-text200',
      size: const Size(320, 350),
      top: 24.0,
      bottom: 16.0,
      side: 0.0,
      scale: 2.0,
    ),
    (
      name: 'narrow-text200',
      size: const Size(160, 320),
      top: 24.0,
      bottom: 16.0,
      side: 0.0,
      scale: 2.0,
    ),
    (
      name: 'landscape',
      size: const Size(844, 390),
      top: 0.0,
      bottom: 21.0,
      side: 44.0,
      scale: 1.0,
    ),
  ]) {
    for (final reduced in [false, true]) {
      testWidgets(
        'Startup and a slow account share exact brand bounds: ${layout.name}, reduced=$reduced',
        (tester) async {
          tester.view.physicalSize = layout.size;
          tester.view.devicePixelRatio = 1;
          tester.view.padding = FakeViewPadding(
            top: layout.top,
            bottom: layout.bottom,
            left: layout.side,
            right: layout.side,
          );
          tester.platformDispatcher.textScaleFactorTestValue = layout.scale;
          tester.platformDispatcher.accessibilityFeaturesTestValue =
              FakeAccessibilityFeatures(disableAnimations: reduced);
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          final captureKey = GlobalKey();
          Future<void> mount(Widget child) => tester.pumpWidget(
            MaterialApp(
              home: RepaintBoundary(key: captureKey, child: child),
            ),
          );

          // Keep the existing static waiting composition as the visual target.
          await mount(
            const AppScaffold(
              body: SafeArea(
                child: Center(child: BrandWordmark(iconSize: 80, textSize: 32)),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final expectedIcon = tester.getRect(find.byType(BrandMark));
          final expectedName = tester.getRect(find.byType(BrandName));
          expect(
            expectedIcon.expandToInclude(expectedName).center.dx,
            closeTo(layout.size.width / 2, .001),
          );
          expect(
            expectedIcon.center.dy,
            closeTo(
              (layout.size.height + layout.top - layout.bottom) / 2,
              .001,
            ),
          );

          final entry = _PendingEntry();
          await mount(
            ProviderScope(
              overrides: [entryViewModelProvider.overrideWith(() => entry)],
              child: const StartupReveal(child: EntryScreen()),
            ),
          );
          if (!reduced) {
            expect(
              tester.getCenter(find.byType(BrandMark)).dx,
              closeTo(layout.size.width / 2, .001),
            );
            await tester.pump(const Duration(milliseconds: 550));
            await _capture(tester, captureKey, '${layout.name}-middle');
            await tester.pump(const Duration(milliseconds: 400));
          }

          void expectSameBounds() {
            expect(
              tester.getRect(find.byType(BrandMark)),
              rectMoreOrLessEquals(expectedIcon, epsilon: .001),
            );
            expect(
              tester.getRect(find.byType(BrandName)),
              rectMoreOrLessEquals(expectedName, epsilon: .001),
            );
            expect(tester.takeException(), isNull);
          }

          expectSameBounds();
          final settledIcon = tester.getRect(find.byType(BrandMark));
          final settledName = tester.getRect(find.byType(BrandName));
          final suffix = reduced ? '-reduced' : '';
          await _capture(tester, captureKey, '${layout.name}$suffix-settled');
          if (!reduced) await tester.pump(const Duration(milliseconds: 151));
          expect(find.byType(EntryScreen), findsOneWidget);
          expect(find.bySemanticsLabel('Preparando tu cuenta'), findsOneWidget);
          expectSameBounds();
          expect(tester.getRect(find.byType(BrandMark)), settledIcon);
          expect(tester.getRect(find.byType(BrandName)), settledName);
          await tester.pump(const Duration(seconds: 5));
          expectSameBounds();
          await _capture(tester, captureKey, '${layout.name}$suffix-waiting');
          entry.pending.complete(EntryDestination.home);
          await tester.pumpAndSettle();
          expectSameBounds();
        },
      );
    }
  }

  testWidgets(
    'Startup moves the icon left, reveals text, then starts stagger directly',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartupReveal(
            child: AuthStageTransition(
              stage: 'login',
              builder: (play) => StaggerReveal(
                play: play,
                count: 3,
                child: const StaggerRevealItem(
                  order: 2,
                  child: Text('Iniciar sesión'),
                ),
              ),
            ),
          ),
        ),
      );
      final iconStart = tester.getTopLeft(find.byType(BrandMark));
      expect(find.text('Iniciar sesión'), findsNothing);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
      await tester.pump(const Duration(milliseconds: 550));
      expect(
        tester.getTopLeft(find.byType(BrandMark)).dx,
        lessThan(iconStart.dx),
      );
      final opacity = tester.widget<Opacity>(find.byType(Opacity)).opacity;
      expect(opacity, inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 200));
      final iconOvershoot = tester.getTopLeft(find.byType(BrandMark));
      final textOvershoot = tester.getTopLeft(find.byType(BrandName));
      await tester.pump(const Duration(milliseconds: 200));
      final iconSettled = tester.getTopLeft(find.byType(BrandMark));
      final textSettled = tester.getTopLeft(find.byType(BrandName));
      expect(iconOvershoot.dx, lessThan(iconSettled.dx));
      expect(textOvershoot.dx, greaterThan(textSettled.dx));
      expect(iconOvershoot.dy, iconStart.dy);
      expect(iconSettled.dy, iconStart.dy);
      expect(textOvershoot.dy, textSettled.dy);
      expect(find.text('Iniciar sesión'), findsNothing);
      await tester.pump(const Duration(milliseconds: 151));
      expect(find.byType(BrandMark), findsNothing);
      expect(
        tester.widget<StaggerReveal>(find.byType(StaggerReveal)).play,
        true,
      );
      expect(find.byType(CoverReveal), findsNothing);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 321));
      expect(
        tester.widget<StaggerReveal>(find.byType(StaggerReveal)).play,
        true,
      );
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    },
  );

  testWidgets(
    'Startup skips motion when requested and fits small enlarged layout',
    (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        const MaterialApp(home: StartupReveal(child: Text('Destino'))),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: StartupReveal(key: ValueKey('reduced'), child: Text('Destino')),
        ),
      );
      expect(find.text('Destino'), findsOneWidget);
      expect(find.byType(BrandMark), findsNothing);
    },
  );
}
