// flutter test --dart-define=AMBIENT_BACKGROUND_MOTION=false tool/capture_home_redesign.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_explore_banner.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_found_banner.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_photo_search_card.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_report_banner.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_section.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_map_button.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pets_section.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import '../test/explore_test.dart' show SearchFake, item;
import '../test/support/fake_pets.dart';
import '../test/support/fake_current_location.dart';

void main() {
  testWidgets('Capture approved Home with real assets, fonts and scrolling', (
    tester,
  ) async {
    await tester.runAsync(() async {
      for (final family in ['Poppins', 'sans-serif']) {
        final loader = FontLoader(family);
        for (final name
            in family == 'Poppins'
                ? ['Poppins-Regular', 'Poppins-SemiBold']
                : ['Roboto-Regular', 'Roboto-Bold']) {
          loader.addFont(
            File(
              'assets/fonts/$name.ttf',
            ).readAsBytes().then(ByteData.sublistView),
          );
        }
        await loader.load();
      }
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final flutter = (config['packages'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((entry) => entry['name'] == 'flutter');
      final root = configFile.uri.resolve('${flutter['rootUri']}/');
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          File.fromUri(
            root.resolve(
              '../../bin/cache/artifacts/material_fonts/materialicons-regular.otf',
            ),
          ).readAsBytes().then(ByteData.sublistView),
        );
      await icons.load();
    });
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final directory = Directory('build/ui-preview/home-redesign')
      ..createSync(recursive: true);
    for (final config in [
      ('normal', const Size(390, 844), 1.0),
      ('small', const Size(320, 600), 2.0),
      ('short', const Size(320, 350), 2.0),
    ]) {
      tester.view.physicalSize = config.$2;
      final boundaryKey = GlobalKey();
      final pets = FakePets();
      for (var index = 0; index < 8; index++) {
        pets.pets['preview-$index'] = Pet(
          id: 'preview-$index',
          ownerId: 'preview',
          version: 1,
          fields: PetFields(
            name: ['Luna', 'Milo', 'Nala', 'Toby'][index % 4],
            species: PetSpecies.dog,
          ),
        );
      }
      final explore = SearchFake()
        ..firstPage = [for (var i = 0; i < 8; i++) item('preview-$i')];
      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey(config.$1),
          overrides: [
            petRepositoryProvider.overrideWithValue(pets),
            petSessionProvider.overrideWith(
              (_) => Stream.value(const AuthSession(userId: 'preview')),
            ),
            exploreRepositoryProvider.overrideWithValue(explore),
            exploreSessionProvider.overrideWith(
              (_) => Stream.value(const AuthSession(userId: 'preview')),
            ),
            currentLocationRepositoryProvider.overrideWithValue(
              const FakeCurrentLocation(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: config.$2,
                textScaler: TextScaler.linear(config.$3),
                disableAnimations: config.$1 != 'normal',
                padding: const EdgeInsets.only(top: 24, bottom: 24),
              ),
              child: RepaintBoundary(
                key: boundaryKey,
                child: HomeScreen(
                  petsContent: const PetsSection(),
                  exploreContent: const ExploreSection(),
                  exploreFloatingAction: const ExploreMapButton(),
                  profileAvatar: const CircleAvatar(
                    backgroundColor: Color(0xFFF5F5F7),
                    foregroundColor: Color(0xFF111111),
                    child: Text('A'),
                  ),
                  onAlerts: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        for (final asset in [
          'assets/branding/app_icon.png',
          HomeReportBanner.artwork,
          HomeFoundBanner.artwork,
          HomePhotoSearchCard.artwork,
          HomeExploreBanner.artwork,
        ]) {
          await precacheImage(AssetImage(asset), boundaryKey.currentContext!);
        }
      });

      Future<void> capture(String name) async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        boundary.markNeedsPaint();
        await tester.pump();
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final pixels = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '${directory.path}/$name.png',
          ).writeAsBytes(pixels!.buffer.asUint8List());
          image.dispose();
        });
        expect(tester.takeException(), isNull);
      }

      if (config.$1 == 'normal') {
        await tester.pump(const Duration(milliseconds: 200));
        await capture('normal-entry-200ms');
      }
      await tester.pumpAndSettle();
      await capture('${config.$1}-top');
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      scroll.position.jumpTo(
        230.clamp(0, scroll.position.maxScrollExtent).toDouble(),
      );
      await tester.pumpAndSettle();
      await capture('${config.$1}-header-fade');
      if (config.$1 == 'normal') {
        final button = find.ancestor(
          of: find.text('Reportar pérdida'),
          matching: find.byType(FilledButton),
        );
        final viewportTop = tester
            .getTopLeft(find.byType(SingleChildScrollView))
            .dy;
        scroll.position.jumpTo(
          scroll.position.pixels +
              tester.getTopLeft(button).dy -
              viewportTop -
              10,
        );
        await tester.pumpAndSettle();
        await capture('normal-header-fade-report');
      }
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('home-found-banner'))),
      );
      await tester.pumpAndSettle();
      await capture('${config.$1}-scroll');
      await Scrollable.ensureVisible(
        tester.element(find.text('Explorar')),
        alignment: .35,
      );
      await tester.pumpAndSettle();
      await capture('${config.$1}-bottom');
      for (final section in [
        ('Explorar', 'explore'),
        ('Mis mascotas', 'pets'),
      ]) {
        await tester.tap(find.byTooltip(section.$1));
        await tester.pumpAndSettle();
        await capture('${config.$1}-${section.$2}-top');
        final sectionScroll = tester.state<ScrollableState>(
          find.byType(Scrollable),
        );
        sectionScroll.position.jumpTo(
          130.clamp(0, sectionScroll.position.maxScrollExtent).toDouble(),
        );
        await tester.pumpAndSettle();
        await capture('${config.$1}-${section.$2}-fade');
      }
    }
  });
}
