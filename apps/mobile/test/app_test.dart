import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'support/fake_password_recovery.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_stage_transition.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/brand_wordmark.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/login_view_model.dart';
import 'access_test.dart' show FakeAccess;
import 'package:flutter_application_entrehuellas/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';

class FakeAuthRepository implements AuthRepository {
  AuthSession? current;
  final controller = StreamController<AuthSession?>.broadcast();
  void emit(AuthSession? session) {
    current = session;
    controller.add(session);
  }

  @override
  Stream<AuthSession?> watchSession() async* {
    yield current;
    yield* controller.stream;
  }
}

class FakeOnboarding implements OnboardingRepository {
  FakeOnboarding(this.auth);
  final FakeAuthRepository auth;
  final completed = <String>{};
  bool failRead = false;
  bool failSave = false;
  int saves = 0;
  Completer<bool>? pendingRead;
  Completer<void>? pendingSave;
  @override
  Future<bool> isCompleted(String userId) async {
    if (pendingRead != null) return pendingRead!.future;
    if (failRead) throw StateError('private server details');
    return completed.contains(userId);
  }

  @override
  Future<void> complete() async {
    saves++;
    if (pendingSave != null) await pendingSave!.future;
    if (failSave) throw StateError('private server details');
    completed.add(auth.current!.userId);
  }
}

void main() {
  testWidgets(
    'Login hides Apple and session notices while keeping useful errors on the affected field',
    (tester) async {
      final localAuth = FakeAuthRepository();
      final local = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(
            const StartupState(StartupStatus.ready),
          ),
          passwordRecoveryRepositoryProvider.overrideWithValue(
            FakePasswordRecovery(),
          ),
          authRepositoryProvider.overrideWithValue(localAuth),
          accessRepositoryProvider.overrideWithValue(FakeAccess()),
        ],
      );
      addTearDown(() async {
        local.dispose();
        await localAuth.controller.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: local,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      await local.read(loginViewModelProvider.notifier).signOut();
      await tester.pumpAndSettle();
      expect(find.text('Sesión cerrada.'), findsNothing);
      expect(find.text('Continuar con Apple'), findsNothing);
      expect(find.text('Continuar con Google'), findsOneWidget);
      await local
          .read(loginViewModelProvider.notifier)
          .password('invalid', 'password');
      await tester.pumpAndSettle();
      final error = find.text('Correo no válido');
      expect(error, findsOneWidget);
      expect(
        tester.getTopLeft(error).dy,
        lessThan(tester.getTopLeft(find.text('Ingresar')).dy),
      );
    },
  );
  late FakeAuthRepository auth;
  late FakeOnboarding onboarding;
  late ProviderContainer container;
  setUp(() {
    auth = FakeAuthRepository();
    onboarding = FakeOnboarding(auth);
    container = ProviderContainer(
      overrides: [
        startupStateProvider.overrideWithValue(
          const StartupState(StartupStatus.ready),
        ),
        passwordRecoveryRepositoryProvider.overrideWithValue(
          FakePasswordRecovery(),
        ),
        authRepositoryProvider.overrideWithValue(auth),
        onboardingRepositoryProvider.overrideWithValue(onboarding),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await auth.controller.close();
  });
  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EntreHuellasApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Login is first and protected routes cannot bypass authentication',
    (tester) async {
      await mount(tester);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      for (final path in [
        '/home',
        '/home/explore-map',
        '/onboarding',
        '/unknown?code=private',
      ]) {
        container.read(routerProvider).go(path);
        await tester.pumpAndSettle();
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.textContaining('private'), findsNothing);
      }
    },
  );
  testWidgets(
    'First login traverses the three stages then never repeats for that account',
    (tester) async {
      await mount(tester);
      auth.emit(const AuthSession(userId: 'one'));
      await tester.pumpAndSettle();
      container.read(routerProvider).go('/home/explore-map');
      await tester.pumpAndSettle();
      expect(find.text('Cada huella importa'), findsOneWidget);
      expect(find.text('Omitir'), findsNothing);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Volvamos a casa'), findsOneWidget);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Una nueva historia'), findsOneWidget);
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Inicio'), findsOneWidget);
      expect(onboarding.completed, {'one'});
      auth.emit(null);
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      auth.emit(const AuthSession(userId: 'one'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Inicio'), findsOneWidget);
      auth.emit(const AuthSession(userId: 'two'));
      await tester.pumpAndSettle();
      expect(find.text('Cada huella importa'), findsOneWidget);
    },
  );
  testWidgets(
    'Final stage persists completion; a failed save allows retry without leaving onboarding',
    (tester) async {
      auth.current = const AuthSession(userId: 'one');
      onboarding.failSave = true;
      await mount(tester);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();
      expect(
        find.text('No se pudo guardar. Inténtalo de nuevo.'),
        findsOneWidget,
      );
      expect(onboarding.completed, isEmpty);
      expect(find.textContaining('private'), findsNothing);
      onboarding.failSave = false;
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Inicio'), findsOneWidget);
      expect(onboarding.saves, 2);
    },
  );
  testWidgets(
    'Onboarding replaces stages only after reverse stagger, locks repeated taps and never slides horizontally',
    (tester) async {
      auth.current = const AuthSession(userId: 'one');
      await mount(tester);
      double opacity(String text) => tester
          .widget<Opacity>(
            find
                .ancestor(of: find.text(text), matching: find.byType(Opacity))
                .last,
          )
          .opacity;
      final brand = tester.getRect(find.byType(BrandWordmark));
      final titleX = tester.getTopLeft(find.text('Cada huella importa')).dx;
      expect(find.byType(PageView), findsNothing);
      expect(find.byType(StaggerStageItem), findsNWidgets(4));
      await tester.drag(
        find.text('Cada huella importa'),
        const Offset(-360, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Volvamos a casa'), findsNothing);
      await tester.tap(find.text('Continuar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(opacity('Cada huella importa'), 1);
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacity('Continuar'), lessThan(1));
      expect(
        opacity('Cada huella importa'),
        1,
        reason: 'Bottom group exits first',
      );
      expect(tester.getTopLeft(find.text('Cada huella importa')).dx, titleX);
      expect(tester.getRect(find.byType(BrandWordmark)), brand);
      await tester.tap(find.text('Continuar'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 671));
      await tester.pump();
      expect(find.text('Cada huella importa'), findsNothing);
      expect(find.text('Volvamos a casa'), findsOneWidget);
      expect(opacity('Volvamos a casa'), 0);
      await tester.pump(const Duration(milliseconds: 180));
      expect(opacity('Volvamos a casa'), greaterThan(0));
      expect(opacity('Volvamos a casa'), lessThan(1));
      expect(opacity('Continuar'), 0, reason: 'Action enters last');
      expect(tester.getTopLeft(find.text('Volvamos a casa')).dx, titleX);
      await tester.pumpAndSettle();
      expect(opacity('Volvamos a casa'), 1);
      await tester.drag(find.text('Volvamos a casa'), const Offset(360, 0));
      await tester.pumpAndSettle();
      expect(find.text('Volvamos a casa'), findsOneWidget);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Una nueva historia'), findsOneWidget);
      expect(opacity('Una nueva historia'), 1);
    },
  );
  testWidgets(
    'Confirmed onboarding save remains visible, blocks repeats and exits before routing',
    (tester) async {
      auth.current = const AuthSession(userId: 'one');
      await mount(tester);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      onboarding.pendingSave = Completer<void>();
      await tester.tap(find.text('Comenzar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pump();
      expect(onboarding.saves, 1);
      expect(
        find.bySemanticsLabel('Guardando finalización del onboarding'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(
                of: find.text('Una nueva historia'),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        1,
      );
      await tester.tap(find.text('Comenzar'), warnIfMissed: false);
      expect(onboarding.saves, 1);
      onboarding.pendingSave!.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Una nueva historia'), findsOneWidget);
      expect(find.byTooltip('Inicio'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Inicio'), findsOneWidget);
      expect(onboarding.completed, {'one'});
    },
  );

  testWidgets('Pending account check shows the brand without a spinner', (
    tester,
  ) async {
    await mount(tester);
    final pending = Completer<bool>();
    onboarding.pendingRead = pending;
    auth.emit(const AuthSession(userId: 'one'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Preparando tu cuenta'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Cada huella importa'), findsNothing);
    expect(find.text('Inicio'), findsNothing);
    pending.complete(false);
    await tester.pumpAndSettle();
    expect(find.text('Cada huella importa'), findsOneWidget);
    expect(find.bySemanticsLabel('Preparando tu cuenta'), findsNothing);
  });
  testWidgets(
    'Profile loading failure does not skip onboarding and recovers on retry',
    (tester) async {
      auth.current = const AuthSession(userId: 'one');
      onboarding.failRead = true;
      await mount(tester);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.text('Inicio'), findsNothing);
      expect(find.textContaining('private'), findsNothing);
      onboarding.failRead = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Cada huella importa'), findsOneWidget);
    },
  );
  testWidgets('Restored returning session skips login and onboarding', (
    tester,
  ) async {
    auth.current = const AuthSession(userId: 'returning');
    onboarding.completed.add('returning');
    await mount(tester);
    expect(find.byTooltip('Inicio'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);
  });

  testWidgets(
    'A late result for the previous account cannot change the new account route',
    (tester) async {
      await mount(tester);
      final previousRead = Completer<bool>();
      onboarding.pendingRead = previousRead;
      auth.emit(const AuthSession(userId: 'old'));
      await tester.pump();
      await tester.pump();
      onboarding.pendingRead = null;
      auth.emit(const AuthSession(userId: 'new'));
      await tester.pumpAndSettle();
      expect(find.text('Cada huella importa'), findsOneWidget);
      previousRead.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('Cada huella importa'), findsOneWidget);
      expect(find.text('Inicio'), findsNothing);
      container.read(routerProvider).go('/home');
      await tester.pumpAndSettle();
      expect(find.text('Cada huella importa'), findsOneWidget);
    },
  );
  testWidgets(
    'Login and onboarding support a small viewport with enlarged text',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.binding.setSurfaceSize(const Size(320, 350));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await mount(tester);
      expect(tester.takeException(), isNull);
      auth.emit(const AuthSession(userId: 'one'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      // Each step now scrolls its content and action together.
      await tester.ensureVisible(find.text('Continuar'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Comenzar'));
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Inicio'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Invalid and failed startup states still begin at login', (
    tester,
  ) async {
    for (final status in [
      StartupStatus.invalidConfiguration,
      StartupStatus.failed,
    ]) {
      final local = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(StartupState(status)),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: local,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      local.dispose();
    }
  });
}
