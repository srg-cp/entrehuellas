import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/entities/account_profile.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/screens/profile_screen.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_profile.dart';

void main() {
  testWidgets(
    'Overview keeps destinations during loading/error/retry and hides another identity',
    (tester) async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final profiles = FakeProfile()
        ..pendingRead = Completer<void>()
        ..profiles.addAll({
          'one': const AccountProfile(
            userId: 'one',
            displayName: 'Cuenta uno',
            city: 'Lima',
          ),
          'two': const AccountProfile(
            userId: 'two',
            displayName: 'Cuenta dos',
            city: 'Tacna',
          ),
        });
      final scope = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
        ],
      );
      addTearDown(() async {
        scope.dispose();
        await auth.controller.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: PageEntranceScope(
                routeOwnsEntrance: true,
                child: ProfileScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Cuenta uno'), findsNothing);
      expect(find.text('Borradores'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      profiles.failRead = true;
      profiles.pendingRead!.complete();
      await tester.pumpAndSettle();
      expect(
        find.text('No se pudo cargar tu perfil. Reintenta.'),
        findsOneWidget,
      );
      expect(find.text('Cuenta uno'), findsNothing);
      profiles.failRead = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Cuenta uno'), findsOneWidget);
      profiles.pendingRead = Completer<void>();
      auth.emit(const AuthSession(userId: 'two'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Cuenta uno'), findsNothing);
      expect(find.text('Cuenta dos'), findsNothing);
      profiles.pendingRead!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Cuenta dos'), findsOneWidget);
      expect(find.text('Cuenta uno'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
