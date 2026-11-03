// Local visual QA: flutter test --dart-define=AMBIENT_BACKGROUND_MOTION=false tool/capture_onboarding_preview.dart
import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/presentation/view_models/onboarding_view_model.dart';

import '../test/app_test.dart' show FakeAuthRepository, FakeOnboarding;

void main() {
  testWidgets('Inspect bottom onboarding at normal and enlarged sizes', (
    tester,
  ) async {
    final previousShadows = debugDisableShadows;
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = previousShadows);
    await tester.runAsync(() async {
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final flutterPackage = (config['packages'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((entry) => entry['name'] == 'flutter');
      final fontRoot = configFile.uri
          .resolve('${flutterPackage['rootUri']}/')
          .resolve('../../bin/cache/artifacts/material_fonts/');
      for (final entry in {
        'sans-serif': 'assets/fonts/Roboto-Regular.ttf',
        'Roboto': 'assets/fonts/Roboto-Regular.ttf',
        'Poppins': 'assets/fonts/Poppins-Regular.ttf',
        'MaterialIcons': File.fromUri(
          fontRoot.resolve('materialicons-regular.otf'),
        ).path,
      }.entries) {
        final loader = FontLoader(entry.key);
        loader.addFont(
          File(entry.value).readAsBytes().then(ByteData.sublistView),
        );
        await loader.load();
      }
    });
    final auth = FakeAuthRepository()
      ..current = const AuthSession(userId: 'preview');
    final repository = FakeOnboarding(auth);
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        onboardingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(auth.controller.close);
    addTearDown(tester.view.reset);
    for (final sample in [
      ('normal', const Size(390, 844), 1.0, false),
      ('small-text', const Size(320, 600), 2.0, true),
    ]) {
      tester.view.physicalSize = sample.$2;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      final key = GlobalKey();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: sample.$2,
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                textScaler: TextScaler.linear(sample.$3),
                disableAnimations: sample.$4,
              ),
              child: RepaintBoundary(key: key, child: const OnboardingScreen()),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final context = key.currentContext!;
        for (final asset in [
          'dog_waving.png',
          'dog_with_map.png',
          'dog_and_cat.png',
        ]) {
          if (!context.mounted) return;
          await precacheImage(AssetImage('assets/onboarding/$asset'), context);
        }
        if (!context.mounted) return;
        await precacheImage(
          const AssetImage('assets/branding/app_icon.png'),
          context,
        );
      });
      Future<void> capture(String name) async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        boundary.markNeedsPaint();
        await tester.pump();
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final rendered = await boundary.toImage(pixelRatio: 2);
          final bytes = await rendered.toByteData(
            format: ui.ImageByteFormat.png,
          );
          final directory = Directory('build/ui-preview/onboarding-sader');
          await directory.create(recursive: true);
          await File(
            '${directory.path}/$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          rendered.dispose();
        });
      }

      List<double>? firstPositions;
      for (var page = 0; page < 3; page++) {
        container.read(onboardingViewModelProvider.notifier).selectPage(page);
        await tester.pumpAndSettle();
        final action = find.text(page == 2 ? 'Comenzar' : 'Continuar');
        await tester.ensureVisible(action);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final positions = [
          tester
              .getTopLeft(
                find.text(
                  [
                    'Cada huella importa',
                    'Volvamos a casa',
                    'Una nueva historia',
                  ][page],
                ),
              )
              .dy,
          tester
              .getTopLeft(
                find
                    .byType(Text)
                    .evaluate()
                    .map((element) => element.widget as Text)
                    .where(
                      (text) =>
                          text.data?.startsWith(
                            [
                              'Encuentra,',
                              'Con tu ayuda,',
                              'Pequeñas acciones',
                            ][page],
                          ) ??
                          false,
                    )
                    .map((text) => find.byWidget(text))
                    .single,
              )
              .dy,
          tester
              .getTopLeft(
                find.ancestor(of: action, matching: find.byType(FilledButton)),
              )
              .dy,
        ];
        firstPositions ??= positions;
        for (var index = 0; index < positions.length; index++) {
          expect(
            positions[index],
            closeTo(firstPositions[index], .01),
            reason:
                '${sample.$1}: stage ${page + 1}, slot $index must not move',
          );
        }
        if (sample.$1 == 'normal') {
          expect(
            tester
                .getTopLeft(
                  find.text(
                    [
                      'Cada huella importa',
                      'Volvamos a casa',
                      'Una nueva historia',
                    ][page],
                  ),
                )
                .dx,
            24,
          );
          expect(
            tester
                .getSize(
                  find.ancestor(
                    of: action,
                    matching: find.byType(FilledButton),
                  ),
                )
                .height,
            68,
          );
        }
        await capture('${sample.$1}-step-${page + 1}');
      }
      container.read(onboardingViewModelProvider.notifier).selectPage(0);
      await tester.pumpAndSettle();
      if (sample.$1 == 'normal') {
        await tester.tap(find.text('Continuar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await capture('motion-press-200ms');
        await tester.pump(const Duration(milliseconds: 201));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        await capture('motion-exit-150ms');
        await tester.pump(const Duration(milliseconds: 671));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 180));
        await capture('motion-entry-180ms');
        await tester.pumpAndSettle();
        container.read(onboardingViewModelProvider.notifier).selectPage(0);
        await tester.pumpAndSettle();
      }
    }
    debugDisableShadows = previousShadows;
  });
}
