import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/fading_header_scroll.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_header.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/liquid_navigation.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'Shared header fades every section and resets on switch; reduced=$reduced',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: const HomeScreen(
                  profileAvatar: SizedBox.square(dimension: 48),
                  exploreContent: SizedBox(height: 1600),
                  petsContent: SizedBox(height: 1600),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final header = tester.getRect(find.byType(HomeHeader));
        final navigation = tester.getRect(find.byType(LiquidNavigation));
        Future<int> topAlpha() async {
          final mask = tester.widget<ShaderMask>(
            find.descendant(
              of: find.byType(FadingHeaderScroll),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is ShaderMask && widget.blendMode == BlendMode.dstIn,
              ),
            ),
          );
          var alpha = -1;
          await tester.runAsync(() async {
            final recorder = ui.PictureRecorder();
            final canvas = Canvas(recorder);
            const bounds = Rect.fromLTWH(0, 0, 240, 240);
            canvas.drawRect(
              bounds,
              Paint()..shader = mask.shaderCallback(bounds),
            );
            final picture = recorder.endRecording();
            final image = await picture.toImage(240, 240);
            final bytes = (await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            alpha = bytes.getUint8(3);
            image.dispose();
            picture.dispose();
          });
          return alpha;
        }

        for (final section in [
          'Inicio',
          'Explorar',
          'Mis mascotas',
          'Inicio',
        ]) {
          await tester.tap(find.byTooltip(section));
          await tester.pumpAndSettle();
          expect(await topAlpha(), 255, reason: 'New section starts unmasked');
          tester
              .state<ScrollableState>(find.byType(Scrollable))
              .position
              .jumpTo(120);
          await tester.pumpAndSettle();
          expect(
            await topAlpha(),
            lessThanOrEqualTo(2),
            reason: '$section must fade beneath the same header',
          );
          expect(tester.getRect(find.byType(HomeHeader)), header);
          expect(tester.getRect(find.byType(LiquidNavigation)), navigation);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Fade has soft extensions with clear openings and preserves opaque content',
    (tester) async {
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: RepaintBoundary(
                key: boundary,
                child: const ColoredBox(
                  color: Colors.white,
                  child: FadingHeaderScroll(
                    header: SizedBox(height: 32),
                    child: RepaintBoundary(
                      child: SizedBox(
                        height: 1200,
                        child: ColoredBox(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -120),
      );
      await tester.pumpAndSettle();
      (boundary.currentContext!.findRenderObject() as RenderRepaintBoundary)
          .markNeedsPaint();
      await tester.pump();
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final pixels = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        int red(int x, int y) => pixels.getUint8((y * image.width + x) * 4);
        final samples = [for (var x = 10; x < 230; x += 10) red(x, 28)];
        final ordered = [...samples]..sort();
        expect(
          ordered.first,
          lessThan(35),
          reason: 'Openings must reveal the content between soft extensions',
        );
        expect(ordered.last, greaterThan(110));
        final peaks = [
          for (var i = 1; i < samples.length - 1; i++)
            if (samples[i] > samples[i - 1] && samples[i] > samples[i + 1]) i,
        ];
        expect(peaks.length, greaterThanOrEqualTo(3));
        expect(red(120, 0), greaterThan(245));
        expect(red(120, 100), 0);
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    },
  );
}
