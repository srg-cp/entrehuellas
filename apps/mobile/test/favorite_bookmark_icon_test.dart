import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/panel_action_button.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/presentation/widgets/favorite_bookmark_icon.dart';
import 'alert_preferences_test.dart' show loadFonts;

void main() {
  setUpAll(loadFonts);
  for (final reduced in [false, true]) {
    for (final small in [false, true]) {
      testWidgets('confirmed favorite small=$small reduced=$reduced', (
        tester,
      ) async {
        tester.view.physicalSize = small
            ? const Size(320, 600)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final boundary = GlobalKey();
        Future<void> render(bool saved, int id) => tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                disableAnimations: reduced,
                textScaler: TextScaler.linear(small ? 2 : 1),
              ),
              child: Scaffold(
                body: Center(
                  child: RepaintBoundary(
                    key: boundary,
                    child: SizedBox(
                      width: 180,
                      height: 150,
                      child: Center(
                        child: PanelActionButton(
                          label: saved
                              ? 'Quitar de favoritos'
                              : 'Añadir a favoritos',
                          icon: Icons.bookmark_border_rounded,
                          onPressed: () {},
                          iconWidget: FavoriteBookmarkIcon(
                            saved: saved,
                            celebrationId: id,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        Transform transform() => tester.widget<Transform>(
          find.descendant(
            of: find.byType(FavoriteBookmarkIcon),
            matching: find.byType(Transform),
          ),
        );
        await render(false, 0);
        await render(true, 0); // Reading an existing favorite never celebrates.
        await tester.pump(const Duration(milliseconds: 140));
        expect(transform().transform.storage[0], 1);
        expect(
          tester.widget<Icon>(find.byIcon(Icons.bookmark_rounded)).color,
          FavoriteBookmarkIcon.yellow,
        );
        await render(false, 1);
        await render(false, 1); // A failed/pending save keeps the outline.
        expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
        await render(true, 2); // Confirmed save.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 140));
        expect(transform().transform.storage[0], reduced ? 1 : greaterThan(1));
        if (const bool.fromEnvironment('CAPTURE_FAVORITE')) {
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 3);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final folder = Directory('build/ui-preview/favorite')
              ..createSync(recursive: true);
            await File(
              '${folder.path}/${small ? 'small' : 'normal'}-${reduced ? 'reduced' : 'burst'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await render(true, 2); // Rebuilding cannot restart the burst.
        await tester.pump(const Duration(milliseconds: 650));
        expect(transform().transform.storage[0], 1);
        await render(false, 3);
        expect(
          tester.widget<Icon>(find.byIcon(Icons.bookmark_border_rounded)).color,
          isNull,
        );
        expect(tester.takeException(), isNull);
        // Disposing during a second burst releases its ticker.
        await render(true, 4);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpWidget(const SizedBox());
        expect(tester.takeException(), isNull);
      });
    }
  }
}
