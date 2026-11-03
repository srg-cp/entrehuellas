import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'explore_test.dart' show SearchFake;
import 'alert_preferences_test.dart' show loadFonts;
import 'support/fake_current_location.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'access_test.dart' show FakeAccess;
import 'support/fake_password_recovery.dart';
import 'support/fake_profile.dart';
import 'support/fake_profile_photo.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/widgets/profile_summary.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/presentation/screens/local_drafts_screen.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/presentation/screens/submission_queue_screen.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/presentation/screens/user_blocks_screen.dart';
import 'package:flutter_application_entrehuellas/features/moderation_appeals/presentation/screens/appeals_screen.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/providers/interest_zone_providers.dart';
import 'interest_zones_test.dart' show FakeZones;
import 'package:flutter_application_entrehuellas/features/alert_preferences/providers/alert_preference_providers.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/presentation/view_models/alert_preferences_view_model.dart';
import 'support/fake_alert_preferences.dart';

void main() {
  for (final (small, reduced) in [
    (false, false),
    (true, false),
    (true, true),
  ]) {
    testWidgets(
      'Profile overview, horizontal editor and protected destinations; small=$small reduced=$reduced',
      (tester) async {
        await tester.runAsync(() async {
          await loadFonts();
          await (FontLoader('Poppins')
                ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf')))
              .load();
        });
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: reduced);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        final onboarding = FakeOnboarding(auth)..completed.add('one');
        final recovery = FakePasswordRecovery();
        final profiles = FakeProfile();
        final container = ProviderContainer(
          overrides: [
            exploreRepositoryProvider.overrideWithValue(SearchFake()),
            currentLocationRepositoryProvider.overrideWithValue(
              const FakeCurrentLocation(),
            ),
            startupStateProvider.overrideWithValue(
              const StartupState(StartupStatus.ready),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            accessRepositoryProvider.overrideWithValue(FakeAccess()),
            onboardingRepositoryProvider.overrideWithValue(onboarding),
            passwordRecoveryRepositoryProvider.overrideWithValue(recovery),
            profileRepositoryProvider.overrideWithValue(profiles),
            profilePhotoRepositoryProvider.overrideWithValue(
              FakeProfilePhoto(profiles),
            ),
            interestZoneRepositoryProvider.overrideWithValue(FakeZones()),
            alertPreferenceRepositoryProvider.overrideWithValue(
              FakeAlertPreferences(),
            ),
          ],
        );
        addTearDown(() async {
          container.dispose();
          await auth.controller.close();
          await recovery.events.close();
        });
        final capture = GlobalKey();
        final variant =
            '${small ? 'small' : 'normal'}${reduced ? '-reduced' : ''}';
        await tester.pumpWidget(
          RepaintBoundary(
            key: capture,
            child: UncontrolledProviderScope(
              container: container,
              child: const EntreHuellasApp(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byTooltip('Perfil'), findsNothing);
        expect(find.byTooltip('Abrir perfil'), findsOneWidget);
        await tester.tap(find.byTooltip('Explorar'));
        await tester.pumpAndSettle();
        final avatarBounds = tester.getRect(find.byTooltip('Abrir perfil'));
        await tester.tap(find.byTooltip('Abrir perfil'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));

        final transition = tester.widget<OriginPageTransition>(
          find.byType(OriginPageTransition),
        );
        expect(transition.origin, avatarBounds);
        await tester.pumpAndSettle();
        expect(find.text('Perfil'), findsOneWidget);
        expect(find.text('Mi actividad'), findsOneWidget);
        expect(find.text('Alertas y zonas'), findsOneWidget);
        expect(find.text('Privacidad'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(find.text('Guardar cambios'), findsNothing);
        await _capture(tester, capture, '$variant-overview');
        await tester.tap(find.byType(ProfileSummary));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 120));
        if (!reduced) {
          expect(
            tester.getTopLeft(find.byType(ProfileEditScreen)).dx,
            greaterThan(0),
          );
          expect(tester.getTopLeft(find.byType(ProfileScreen)).dx, lessThan(0));
          await _capture(tester, capture, '$variant-opening');
        }
        await tester.pumpAndSettle();
        expect(find.text('Editar perfil'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(3));
        expect(find.byType(SelectableText), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Guardar cambios'),
              )
              .onPressed,
          isNull,
        );
        await _capture(tester, capture, '$variant-editor');
        final name = find.byType(TextField).first;
        await tester.ensureVisible(name);
        if (small) await _capture(tester, capture, '$variant-editor-fields');
        await tester.enterText(name, 'Ana María');
        await tester.tap(find.byTooltip('Volver al perfil'));
        await tester.pumpAndSettle();
        expect(find.text('¿Descartar cambios?'), findsOneWidget);
        await tester.ensureVisible(find.text('Cancelar'));
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(
          container.read(profileViewModelProvider).requireValue.displayName,
          'Ana María',
        );
        tester.view.viewInsets = FakeViewPadding(bottom: small ? 100 : 280);
        await tester.pump();
        await tester.ensureVisible(find.text('Guardar cambios'));
        await _capture(tester, capture, '$variant-editor-keyboard');
        profiles.pendingUpdate = Completer<void>();
        await tester.tap(find.text('Guardar cambios'));
        await tester.pump();
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.byType(ProfileEditScreen), findsOneWidget);
        expect(find.text('¿Descartar cambios?'), findsNothing);
        profiles.pendingUpdate!.complete();
        await tester.pumpAndSettle();
        tester.view.resetViewInsets();
        expect(profiles.updates, 1);
        expect(find.text('Cambios guardados'), findsOneWidget);
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Volver al perfil'));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        if (!reduced) {
          expect(
            tester.getTopLeft(find.byType(ProfileEditScreen)).dx,
            greaterThan(0),
          );
          await _capture(tester, capture, '$variant-closing');
        }
        await tester.pumpAndSettle();
        expect(find.byType(ProfileEditScreen), findsNothing);
        expect(find.text('Ana María'), findsOneWidget);
        for (final (label, type) in [
          ('Borradores', LocalDraftsScreen),
          ('Envíos', SubmissionQueueScreen),
          ('Mis apelaciones', AppealsScreen),
          ('Cuentas bloqueadas', UserBlocksScreen),
        ]) {
          await tester.ensureVisible(find.text(label));
          await tester.tap(find.text(label));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 120));
          expect(find.byType(type), findsOneWidget);
          if (!reduced) {
            expect(tester.getTopLeft(find.byType(type)).dx, greaterThan(0));
          }
          await tester.pumpAndSettle();
          container.read(routerProvider).pop();
          await tester.pumpAndSettle();
          expect(find.byType(type), findsNothing);
        }
        if (small) {
          final label = tester.renderObject<RenderParagraph>(
            find.text('Cuentas bloqueadas'),
          );
          expect(
            label.getBoxesForSelection(
              const TextSelection(baseOffset: 8, extentOffset: 18),
            ),
            hasLength(1),
            reason: 'The enlarged word bloqueadas must fit on a single line.',
          );
        }
        await _capture(tester, capture, '$variant-overview-bottom');
        // Reopening a saved form must not announce a stale success.
        await tester.ensureVisible(find.byType(ProfileSummary));
        await tester.tap(find.byType(ProfileSummary));
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsNothing);
        await tester.ensureVisible(find.byType(TextField).first);
        await tester.enterText(
          find.byType(TextField).first,
          'Cambio descartado',
        );
        await tester.pump();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('¿Descartar cambios?'), findsOneWidget);
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Descartar'),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Descartar'));
        await tester.pumpAndSettle();
        expect(find.text('Ana María'), findsOneWidget);
        await tester.ensureVisible(find.text('Ubicaciones de interés'));
        await tester.tap(find.text('Ubicaciones de interés'));
        await tester.pumpAndSettle();
        expect(
          find.text('Todavía no tienes ubicaciones de interés.'),
          findsOneWidget,
        );
        await tester.tap(find.byTooltip('Volver al perfil'));
        await tester.pumpAndSettle();
        expect(find.text('Perfil'), findsOneWidget);
        await tester.ensureVisible(find.text('Cerrar sesión'));
        await tester.ensureVisible(find.text('Preferencias de alertas'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Preferencias de alertas'));
        await tester.pumpAndSettle();
        expect(find.text('Tipos de aviso'), findsOneWidget);
        container
            .read(alertPreferencesViewModelProvider.notifier)
            .edit(enabled: true);
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Volver al perfil'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Cancelar'));
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(find.text('Tipos de aviso'), findsOneWidget);
        await tester.tap(find.byTooltip('Volver al perfil'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Descartar'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Descartar'));
        await tester.pumpAndSettle();
        expect(find.text('Perfil'), findsOneWidget);
        await tester.ensureVisible(find.text('Cerrar sesión'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Cerrar perfil'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Cerrar perfil'));
        await tester.pumpAndSettle();
        expect(
          container
              .read(routerProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          '/home',
        );
        expect(find.byType(ExploreSection), findsOneWidget);
        auth.emit(null);
        await tester.pumpAndSettle();
        container.read(routerProvider).go('/home/profile');
        await tester.pumpAndSettle();
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.text('Perfil'), findsNothing);
        container.read(routerProvider).go('/home/profile/edit');
        await tester.pumpAndSettle();
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.text('Editar perfil'), findsNothing);
        container.read(routerProvider).go('/home/interest-zones');
        await tester.pumpAndSettle();
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.text('Ubicaciones de interés'), findsNothing);
        container.read(routerProvider).go('/home/alert-preferences');
        await tester.pumpAndSettle();
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.text('Tipos de aviso'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (Platform.environment['CAPTURE_PROFILE_UI'] != '1') return;
  await tester.pump();
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final folder = Directory('build/ui-preview/profile-navigation')
      ..createSync(recursive: true);
    await File(
      '${folder.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
