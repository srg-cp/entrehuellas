import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_entrehuellas/app/navigation/entity_editor_page.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_action_button.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/collection_add_button.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/state/home_view_state.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_navigation.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/liquid_navigation.dart';
import 'case_journey_test.dart' show loadJourneyFonts;
import 'support/origin_visual_capture.dart';

void main() {
  for (final mode in ['normal', 'text200', 'reduced']) {
    for (final kind in [
      'utility',
      'sighting',
      'add',
      'accented',
      'description',
      'delegated',
      'nine',
    ]) {
      testWidgets('$kind preserves its complete source and return; $mode', (
        tester,
      ) async {
        tester.view.physicalSize = Size(mode == 'normal' ? 390 : 320, 844);
        tester.view.devicePixelRatio = 1;
        if (Platform.environment['CAPTURE_ORIGIN'] == '1') {
          await tester.runAsync(loadJourneyFonts);
        }
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final boundary = GlobalKey();
        const route = '/home/lost-cases/new';
        Widget trigger() => switch (kind) {
          'sighting' => const CaseUtilityButton(
            title: 'Reportar avistamiento',
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            icon: Icons.visibility_outlined,
            route: route,
          ),
          'utility' => const CaseUtilityButton(
            title: 'Crear cartel',
            subtitle: 'PDF con QR',
            icon: Icons.qr_code_2_rounded,
            route: route,
          ),
          'delegated' => CollectionAddButton(
            label: 'Nuevo reporte',
            compact: true,
            onAction: (source) => openLostReport(source),
          ),
          'nine' => LiquidNavigation(
            selected: HomeSection.home,
            onSelect: (_) {},
            onReport: (source) => openLostReport(source),
          ),
          _ => CollectionAddButton(
            label: 'Registrar mascota',
            route: route,
            accented: kind == 'accented',
            description: kind == 'description'
                ? 'Descripción del control'
                : null,
          ),
        };
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 280,
                    child: SingleChildScrollView(child: trigger()),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: route,
              pageBuilder: (context, state) => entityEditorPage(
                context: context,
                key: state.pageKey,
                source: state.extra,
                child: const Scaffold(body: Text('Destino')),
              ),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations: mode == 'reduced',
                textScaler: TextScaler.linear(mode == 'text200' ? 2 : 1),
              ),
              child: RepaintBoundary(key: boundary, child: child!),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final labels = [
          for (final text in tester.widgetList<Text>(find.byType(Text)))
            if (text.data != null) text.data!,
        ];
        final labelRects = {
          for (final label in labels) label: tester.getRect(find.text(label)),
        };
        final icons = [
          for (final icon in tester.widgetList<Icon>(find.byType(Icon)))
            icon.icon!,
        ];
        // The navigation's three other destinations remain outside the origin.
        final capturedIcons = kind == 'nine' ? <IconData>[] : icons;
        final iconRects = {
          for (final icon in capturedIcons)
            icon: tester.getRect(find.byIcon(icon)),
        };
        final target = kind == 'nine'
            ? find.byTooltip('Reportar')
            : kind == 'delegated'
            ? find.byTooltip('Nuevo reporte')
            : find.text(labels.first);
        await tester.tap(target);
        await tester.pump();
        await tester.pump();
        final copy = find.byKey(const ValueKey('origin-page-source'));
        if (mode == 'reduced') {
          expect(copy, findsNothing);
        } else {
          expect(copy, findsOneWidget);
          for (final label in labels) {
            final copied = find.descendant(
              of: copy,
              matching: find.text(label),
            );
            expect(copied, findsOneWidget);
            expect(tester.getRect(copied), labelRects[label]);
          }
          for (final icon in capturedIcons) {
            final copied = find.descendant(
              of: copy,
              matching: find.byIcon(icon),
            );
            expect(copied, findsOneWidget);
            expect(tester.getRect(copied), iconRects[icon]);
          }
          if (kind == 'nine') {
            expect(
              find.descendant(
                of: copy,
                matching: find.byType(ReportNavigationIdentity),
              ),
              findsOneWidget,
            );
            expect(
              find.descendant(of: copy, matching: find.byType(Icon)),
              findsNothing,
            );
          }
          await capture(tester, boundary, '$kind-$mode-start');
          await tester.pump(const Duration(milliseconds: 48));
          await capture(tester, boundary, '$kind-$mode-15');
        }
        await tester.pumpAndSettle();
        expect(find.text('Destino'), findsOneWidget);
        expect(copy, findsNothing);
        router.pop();
        await tester.pumpAndSettle();
        expect(target, findsOneWidget);
        expect(copy, findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
