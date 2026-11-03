import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_entrehuellas/app/navigation/entity_editor_page.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_action_button.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/glass_surface.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/brand_map_pin.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_page_background.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/pull_to_refresh.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/map_case_panel.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/map_case_sheet.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/map_sheet_header.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/widgets/recovery_case_actions.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/providers/case_timeline_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_journey/domain/entities/case_journey.dart';
import 'package:flutter_application_entrehuellas/features/case_journey/domain/use_cases/read_case_journey.dart';
import 'package:flutter_application_entrehuellas/features/case_journey/presentation/view_models/case_journey_view_model.dart';
import 'package:flutter_application_entrehuellas/features/case_journey/presentation/widgets/case_journey_card.dart';
import 'package:flutter_application_entrehuellas/features/case_journey/presentation/widgets/journey_map.dart';
import 'package:flutter_application_entrehuellas/features/case_journey/presentation/screens/case_journey_screen.dart';
import 'found_cases_test.dart' show FakeFoundCases;
import 'lost_cases_test.dart' show FakeCases;
import 'alert_preferences_test.dart' show loadFonts;

const target = (id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', community: true);
PublicFoundCase notice(
  String id,
  int day, {
  String kind = 'sighting',
  bool community = true,
}) => PublicFoundCase(
  id: id,
  targetId: target.id,
  communityTarget: community,
  reportKind: kind,
  status: 'active',
  occurredAt: DateTime(2026, 10, day, 18, 40),
  latitude: -12.105 - day * .002,
  longitude: -77.035 + day * .002,
  species: 'dog',
  traits: 'Avistamiento',
  photos: [],
);

class JourneyFoundCases extends FakeFoundCases {
  int reads = 0;
  @override
  Future<PublicFoundCase?> readPublic(String id) {
    reads++;
    if (failRead) throw const FoundFailure(FoundFailureKind.unavailable);
    return super.readPublic(id);
  }
}

JourneyFoundCases found() => JourneyFoundCases()
  ..publicCase = PublicFoundCase(
    id: target.id,
    reportKind: 'possible_loss',
    status: 'active',
    occurredAt: DateTime(2026, 10, 15, 21, 19),
    latitude: -12.105,
    longitude: -77.035,
    species: 'dog',
    traits: 'Caso',
    photos: [],
  );

void main() {
  test(
    'Owned-pet search uses its own public origin and linked public notices',
    () async {
      final l = FakeCases()
        ..publicCase = PublicLostCase(
          id: target.id,
          status: 'active',
          occurredAt: DateTime(2026, 10, 15),
          latitude: -12.105,
          longitude: -77.035,
          fields: const PetFields(
            name: 'Luna',
            species: PetSpecies.dog,
            traits: 'Blanca y pequeña',
          ),
          photos: [
            const CasePhoto(id: 'pending'),
            CasePhoto(
              id: 'public',
              uri: Uri.parse('https://example.com/luna.jpg'),
            ),
          ],
        );
      final f = FakeFoundCases()
        ..observations.add(notice('seen', 16, community: false));
      final value = await ReadCaseJourney(l, f)('reader', (
        id: target.id,
        community: false,
      ));
      expect(value.origin.time, DateTime(2026, 10, 15));
      expect(value.summary.name, 'Luna');
      expect(value.summary.traits, 'Blanca y pequeña');
      expect(value.summary.photoUri, Uri.parse('https://example.com/luna.jpg'));
      expect(value.points.single.id, 'seen');
      expect(value.target.community, false);
    },
  );
  test(
    'Public readers get chronological public zones, no private calls or invented counts',
    () async {
      final f = found()
        ..observations.addAll([notice('b', 18), notice('a', 16)]);
      final result = await ReadCaseJourney(FakeCases(), f)('reader', target);
      expect(result.points.map((p) => p.id), ['a', 'b']);
      expect(result.latest, DateTime(2026, 10, 18, 18, 40));
      expect(result.countLabel, '2 avistamientos');
      expect(result.summary.name, isEmpty);
      expect(result.summary.traits, f.publicCase!.traits);
      expect(result.summary.photoUri, isNull);
    },
  );
  test(
    'Unavailable origin and a failed access check never become a confirmed empty journey',
    () async {
      final f = found()..publicCase = null;
      await expectLater(
        ReadCaseJourney(FakeCases(), f)('owner', target),
        throwsA(isA<FoundFailure>()),
      );
      final empty = await ReadCaseJourney(FakeCases(), found())(
        'reader',
        target,
      );
      expect(empty.points, isEmpty);
      expect(empty.latest, isNull);
      expect(empty.countLabel, 'Sin avistamientos');
    },
  );
  test(
    'Account change discards the previous journey and rebuilds from authorized projections',
    () async {
      final sessions = StreamController<AuthSession?>();
      final scope = ProviderContainer(
        overrides: [
          foundCaseRepositoryProvider.overrideWithValue(found()),
          lostCaseRepositoryProvider.overrideWithValue(FakeCases()),
          timelineSessionProvider.overrideWith((ref) => sessions.stream),
        ],
      );
      final subscription = scope.listen(
        caseJourneyViewModelProvider(target),
        (_, _) {},
      );
      sessions.add(const AuthSession(userId: 'owner'));
      final first = await scope.read(
        caseJourneyViewModelProvider(target).future,
      );
      expect(first.journey.points, isEmpty);
      sessions.add(const AuthSession(userId: 'reader'));
      await Future<void>.delayed(Duration.zero);
      final second = await scope.read(
        caseJourneyViewModelProvider(target).future,
      );
      expect(second.journey.points, isEmpty);
      subscription.close();
      scope.dispose();
      await sessions.close();
    },
  );

  test(
    'Refresh retains content on transient failure and removes it after forbidden origin',
    () async {
      final f = found();
      final scope = ProviderContainer(
        overrides: [
          foundCaseRepositoryProvider.overrideWithValue(f),
          lostCaseRepositoryProvider.overrideWithValue(FakeCases()),
          timelineSessionProvider.overrideWith(
            (ref) => Stream.value(const AuthSession(userId: 'owner')),
          ),
        ],
      );
      final sub = scope.listen(caseJourneyViewModelProvider(target), (_, _) {});
      final initial = await scope.read(
        caseJourneyViewModelProvider(target).future,
      );
      final model = scope.read(caseJourneyViewModelProvider(target).notifier);
      f.failRead = true;
      final refresh = model.refresh();
      expect(
        scope
            .read(caseJourneyViewModelProvider(target))
            .requireValue
            .refreshing,
        true,
      );
      await refresh;
      final failed = scope
          .read(caseJourneyViewModelProvider(target))
          .requireValue;
      expect(failed.refreshFailed, true);
      expect(failed.journey, same(initial.journey));
      f.failRead = false;
      f.publicCase = null;
      await model.refresh();
      expect(scope.read(caseJourneyViewModelProvider(target)).hasError, true);
      expect(scope.read(caseJourneyViewModelProvider(target)).asData, isNull);
      sub.close();
      scope.dispose();
    },
  );

  for (final small in [false, true]) {
    for (final reduced in [false, true]) {
      testWidgets(
        'Approved actions and card: normal/small text200%, source and return; small=$small reduced=$reduced',
        (tester) async {
          await tester.runAsync(loadJourneyFonts);
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = small
              ? const Size(320, 600)
              : const Size(390, 844);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final value = await ReadCaseJourney(
            FakeCases(),
            found()..observations.add(notice('a', 16)),
          )('reader', target);
          final boundary = GlobalKey();
          final router = GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          RecoveryCaseActions(
                            id: target.id,
                            community: target.community,
                            open: true,
                            canResolve: true,
                            onChanged: () {},
                            utilities: const CaseActionLayout(
                              utilities: true,
                              children: [
                                CaseUtilityButton(
                                  title: 'Ver seguimiento',
                                  subtitle: 'Historial del caso',
                                  icon: Icons.route_outlined,
                                  route: '/action',
                                ),
                                CaseUtilityButton(
                                  title: 'Crear cartel',
                                  subtitle: 'PDF con QR',
                                  icon: Icons.qr_code_2_rounded,
                                  route: '/action',
                                ),
                              ],
                            ),
                            journey: JourneySummaryCard(value: value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GoRoute(
                path: '/action',
                pageBuilder: (context, state) => entityEditorPage(
                  context: context,
                  key: state.pageKey,
                  source: state.extra,
                  child: const Scaffold(body: Text('Destino')),
                ),
              ),
              for (final path in [
                '/home/sightings/:source/:id',
                '/home/found-cases/new',
              ])
                GoRoute(
                  path: path,
                  pageBuilder: (context, state) => entityEditorPage(
                    context: context,
                    key: state.pageKey,
                    source: state.extra,
                    child: const Scaffold(body: Text('Destino')),
                  ),
                ),
              GoRoute(
                path: '/home/journey/:source/:id',
                pageBuilder: (context, state) => entityEditorPage(
                  context: context,
                  key: state.pageKey,
                  source: state.extra,
                  child: const Scaffold(body: Text('Mapa y cronología')),
                ),
              ),
            ],
          );
          addTearDown(router.dispose);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                foundSessionProvider.overrideWith(
                  (ref) => Stream.value(const AuthSession(userId: 'reader')),
                ),
                foundCaseRepositoryProvider.overrideWithValue(found()),
              ],
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                routerConfig: router,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(small ? 2 : 1),
                    disableAnimations: reduced,
                  ),
                  child: RepaintBoundary(
                    key: boundary,
                    child: AppPageBackground(child: child!),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.runAsync(
            () => precacheImage(
              const AssetImage(JourneySummaryCard.art),
              tester.element(find.byType(JourneySummaryCard)),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (!small) {
            final semantics = tester.ensureSemantics();
            expect(
              tester
                  .getSemantics(find.bySemanticsLabel('La vi o la encontré'))
                  .getSemanticsData()
                  .hasAction(ui.SemanticsAction.tap),
              true,
            );
            expect(
              tester
                  .getSemantics(
                    find.bySemanticsLabel(
                      'Ver seguimiento. Historial del caso',
                    ),
                  )
                  .getSemanticsData()
                  .hasAction(ui.SemanticsAction.tap),
              true,
            );
            final buttons = find.byType(CaseUtilityButton);
            semantics.dispose();
            expect(
              tester.getSize(buttons.at(1)).height,
              tester.getSize(buttons.at(2)).height,
            );
          }
          final surfaces = tester.widgetList<GlassSurface>(
            find.byType(GlassSurface),
          );
          expect(surfaces.single.finish, GlassSurfaceFinish.frosted);
          expect(surfaces.single.showRim, false);
          expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
          expect(find.text('Ver mapa y cronología'), findsNothing);
          expect(find.text('Avisos de esta búsqueda'), findsNothing);
          expect(find.text('1 avistamiento'), findsOneWidget);
          expect(find.byIcon(Icons.north_east_rounded), findsOneWidget);
          if (Platform.environment['CAPTURE_CASE_JOURNEY'] == '1') {
            await capture(
              tester,
              boundary,
              small ? 'acciones-small' : 'acciones-normal',
            );
          }
          await tester.ensureVisible(find.byIcon(Icons.north_east_rounded));
          await tester.pumpAndSettle();
          if (small && Platform.environment['CAPTURE_CASE_JOURNEY'] == '1') {
            await capture(tester, boundary, 'acciones-small-tarjeta');
          }
          final originalTitle = tester.getRect(
            find.text('Recorrido de la búsqueda'),
          );
          final originalImage = tester.getRect(
            find.descendant(
              of: find.byType(JourneySummaryCard),
              matching: find.byType(Image),
            ),
          );
          await tester.tap(find.byIcon(Icons.north_east_rounded));
          await tester.pump();
          await tester.pump();
          if (!reduced) {
            final copy = find.byKey(const ValueKey('origin-page-source'));
            for (final label in [
              'Recorrido de la búsqueda',
              '1 avistamiento',
              'Inicio de la búsqueda',
              'Último aviso',
            ]) {
              expect(
                find.descendant(of: copy, matching: find.text(label)),
                findsOneWidget,
              );
            }
            expect(
              tester.getRect(
                find.descendant(
                  of: copy,
                  matching: find.text('Recorrido de la búsqueda'),
                ),
              ),
              originalTitle,
            );
            expect(
              tester.getRect(
                find.descendant(of: copy, matching: find.byType(Image)),
              ),
              originalImage,
            );
            if (Platform.environment['CAPTURE_CASE_JOURNEY'] == '1') {
              await capture(tester, boundary, 'apertura-origen-completo');
            }
          }
          await tester.pump(const Duration(milliseconds: 100));
          if (!reduced) {
            final transition = tester
                .widgetList<OriginPageTransition>(
                  find.byType(OriginPageTransition),
                )
                .last;
            expect(transition.source, isNotNull);
            expect(transition.source!.radius, 28);
            if (Platform.environment['CAPTURE_CASE_JOURNEY'] == '1') {
              await capture(tester, boundary, 'apertura-normal');
            }
          }
          await tester.pumpAndSettle();
          expect(find.text('Mapa y cronología'), findsOneWidget);
          router.pop();
          await tester.pump();
          if (!reduced) {
            await tester.pump(const Duration(milliseconds: 80));
            if (Platform.environment['CAPTURE_CASE_JOURNEY'] == '1') {
              await capture(tester, boundary, 'retorno-normal');
            }
          }
          await tester.pumpAndSettle();
          expect(find.byType(JourneySummaryCard), findsOneWidget);
          expect(find.text('Reportar avistamiento'), findsNothing);
          await tester.ensureVisible(find.text('La vi o la encontré'));
          await tester.tap(find.text('La vi o la encontré'));
          await tester.pumpAndSettle();
          expect(find.text('Destino'), findsOneWidget);
          expect(
            GoRouterState.of(
              tester.element(find.text('Destino')),
            ).uri.queryParameters,
            {'case': target.id, 'community': 'true'},
          );
          router.pop();
          await tester.pumpAndSettle();
          expect(find.byType(RecoveryCaseActions), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'Actual map groups coincident points and opens all entries without moving their coordinates',
    (tester) async {
      final value = CaseJourney(
        target: target,
        origin: JourneyPoint(
          id: target.id,
          time: DateTime(2026, 10, 15),
          latitude: -12.105,
          longitude: -77.035,
        ),
        points: [
          for (var i = 0; i < 3; i++)
            JourneyPoint(
              id: '$i',
              time: DateTime(2026, 10, 16 + i),
              latitude: i < 2 ? -12.115 : -12.125,
              longitude: -77.025,
            ),
        ],
      );
      List<JourneyPoint>? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JourneyMap(
              value: value,
              onSelect: (points) => selected = points,
              createTileProvider: tiles,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final map = tester.widget<ZoneMapPicker>(find.byType(ZoneMapPicker));
      expect(map.markers.length, 3);
      expect(map.polylines.single.points.length, 4);
      final pins = tester
          .widgetList<BrandMapPin>(find.byType(BrandMapPin))
          .toList();
      expect(pins.first.color, JourneyMap.originColor);
      expect(pins[1].color, JourneyMap.sightingColor);
      expect(pins[1].count, 2);
      pins[1].onTap!();
      expect(selected!.map((p) => p.id), ['0', '1']);
      expect(tester.takeException(), isNull);
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Real journey screen renders chronological authorized data; small=$small',
      (tester) async {
        await tester.runAsync(loadJourneyFonts);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = small
            ? const Size(320, 600)
            : const Size(390, 844);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final boundary = GlobalKey();
        final repository = found()
          ..observations.addAll([notice('b', 18), notice('a', 16)]);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              foundCaseRepositoryProvider.overrideWithValue(repository),
              lostCaseRepositoryProvider.overrideWithValue(FakeCases()),
              timelineSessionProvider.overrideWith(
                (ref) => Stream.value(const AuthSession(userId: 'reader')),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(small ? 2 : 1),
                  disableAnimations: small,
                ),
                child: child!,
              ),
              home: RepaintBoundary(
                key: boundary,
                child: CaseJourneyScreen(
                  target: target,
                  createTileProvider: tiles,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Avistamiento 1'), findsOneWidget);
        expect(find.text('Avistamiento 2'), findsOneWidget);
        expect(find.text('Actualizar recorrido'), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text && (widget.data ?? '').startsWith('Origen ·'),
          ),
          findsNothing,
        );
        expect(find.byType(PullToRefresh), findsOneWidget);
        expect(find.byType(MapCaseSheet), findsOneWidget);
        expect(find.byType(MapSheetHeader), findsOneWidget);
        expect(find.text('Recorrido'), findsOneWidget);
        expect(find.text('Ubicaciones'), findsOneWidget);
        expect(find.text('Cronología'), findsNothing);
        final panel = tester.widget<MapCasePanel>(find.byType(MapCasePanel));
        expect(panel.decorativeActions, true);
        expect(panel.onOpen, isNull);
        expect(panel.traits, repository.publicCase!.traits);
        final semantics = tester.ensureSemantics();
        try {
          await tester.pump();
          expect(find.bySemanticsLabel(RegExp('.*Ver ficha.*')), findsNothing);
          expect(find.bySemanticsLabel('Abrir ficha del caso'), findsNothing);
        } finally {
          semantics.dispose();
        }
        final openButton = tester.widget<TextButton>(
          find.ancestor(
            of: find.text('Ver ficha'),
            matching: find.byWidgetPredicate((widget) => widget is TextButton),
          ),
        );
        expect(openButton.onPressed, isNull);
        expect(
          openButton.style!.backgroundColor!.resolve({WidgetState.disabled}),
          const Color(0xFFF0F0F2),
        );
        expect(
          openButton.style!.foregroundColor!.resolve({WidgetState.disabled}),
          const Color(0xFF171918),
        );
        final mapSize = tester.getSize(find.byType(FlutterMap));
        expect(mapSize, tester.view.physicalSize);
        expect(tester.takeException(), isNull);
        if (Platform.environment['CAPTURE_CASE_JOURNEY'] == '1') {
          await capture(tester, boundary, small ? 'mapa-small' : 'mapa-normal');
        }
        final pending = Completer<void>();
        repository.pendingRead = pending;
        final reads = repository.reads;
        final sheet = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        sheet.controller!.jumpTo(sheet.minChildSize);
        await tester.pumpAndSettle();
        final surface = find.byKey(const ValueKey('map-case-surface'));
        final pullStart = tester.getTopLeft(surface) + const Offset(40, 48);
        await tester.dragFrom(pullStart, const Offset(0, 180));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        final scope = ProviderScope.containerOf(
          tester.element(find.byType(CaseJourneyScreen)),
        );
        expect(repository.reads, reads + 1);
        expect(
          scope
              .read(caseJourneyViewModelProvider(target))
              .requireValue
              .refreshing,
          true,
        );
        final refreshing = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Actualizando contenido',
        );
        expect(refreshing, findsOneWidget);
        expect(find.text('Avistamiento 1'), findsOneWidget);
        await tester.dragFrom(pullStart, const Offset(0, 180));
        await tester.pump(const Duration(milliseconds: 600));
        expect(repository.reads, reads + 1);
        repository.observations.add(notice('c', 19));
        repository.pendingRead = null;
        pending.complete();
        await tester.pumpAndSettle();
        expect(find.text('Avistamiento 3'), findsOneWidget);
        expect(refreshing, findsNothing);
        expect(
          scope
              .read(caseJourneyViewModelProvider(target))
              .requireValue
              .refreshing,
          false,
        );
        expect(tester.takeException(), isNull);
        sheet.controller!.jumpTo(.9);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Ver ficha'));
        await tester.tap(find.text('Ver ficha'), warnIfMissed: false);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byIcon(Icons.north_east_rounded));
        await tester.tap(
          find.byIcon(Icons.north_east_rounded),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        expect(find.byType(CaseJourneyScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        await Scrollable.ensureVisible(
          tester.element(find.text('Avistamiento 2')),
          alignment: .5,
        );
        await tester.pump();
        if (Platform.environment['CAPTURE_CASE_JOURNEY'] == '1') {
          await capture(
            tester,
            boundary,
            small ? 'ubicaciones-small' : 'ubicaciones-normal',
          );
        }
        await tester.tap(find.text('Avistamiento 2'));
        await tester.pumpAndSettle();
        final selected = tester.widget<Material>(
          find
              .ancestor(
                of: find.text('Avistamiento 2'),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(selected.color, const Color(0xFFE8F3FF));
        expect(tester.takeException(), isNull);
        sheet.controller!.jumpTo(.9);
        await tester.pumpAndSettle();
        final publicCase = repository.publicCase;
        repository.publicCase = null;
        await scope
            .read(caseJourneyViewModelProvider(target).notifier)
            .refresh();
        await tester.pumpAndSettle();
        expect(find.byType(MapCaseSheet), findsNothing);
        expect(find.text('Avistamiento 2'), findsNothing);
        // Let the shared error toast retract before checking the header hit area.
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
        expect(
          find.byTooltip('Volver a la ficha').hitTestable(),
          findsOneWidget,
        );
        repository.publicCase = publicCase;
        await tester.tap(find.text('Reintentar recorrido'));
        await tester.pumpAndSettle();
        expect(find.byType(MapCaseSheet), findsOneWidget);
        expect(find.text('Ubicaciones'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

TileProvider tiles() => _JourneyTiles();

class _JourneyTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(TileProvider.transparentImage);
}

Future<void> loadJourneyFonts() async {
  await loadFonts();
  final loader = FontLoader('Poppins');
  for (final font in ['Poppins-Regular', 'Poppins-SemiBold']) {
    loader.addFont(
      File('assets/fonts/$font.ttf').readAsBytes().then(ByteData.sublistView),
    );
  }
  await loader.load();
}

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory('build/ui-preview/case-journey').createSync(recursive: true);
    File(
      'build/ui-preview/case-journey/$name.png',
    ).writeAsBytesSync(data!.buffer.asUint8List());
    image.dispose();
  });
}
