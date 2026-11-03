import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_entrehuellas/core/config/map_config.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/loading_shimmer.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';

void main() {
  test('Native retina preserves provider, query and explicit resolution', () {
    const base =
        'https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png?key=fixture';
    expect(
      MapConfig.nativeRetinaTemplate(base),
      base.replaceFirst('.png', '{r}.png'),
    );
    for (final template in [
      base.replaceFirst('.png', '{r}.png'),
      base.replaceFirst('.png', '@2x.png'),
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      'https://example.org/{z}/{x}/{y}.png?key=fixture',
    ]) {
      expect(MapConfig.nativeRetinaTemplate(template), template);
    }
  });

  for (final density in [1.0, 3.0]) {
    testWidgets(
      'Pending tiles shimmer, decode and request native resolution; DPR=$density',
      (tester) async {
        PaintingBinding.instance.imageCache.clear();
        final pending = Completer<void>();
        final requests = <Uri>[];
        final client = MockClient((request) async {
          requests.add(request.url);
          await pending.future;
          return http.Response.bytes(
            TileProvider.transparentImage,
            200,
            request: request,
          );
        });
        addTearDown(client.close);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(devicePixelRatio: density),
              child: Scaffold(
                body: ZoneMapPicker(
                  latitude: -12,
                  longitude: -77,
                  radiusMeters: 1000,
                  onSelect: null,
                  readOnly: true,
                  createTileProvider: () => NetworkTileProvider(
                    httpClient: client,
                    cachingProvider: const DisabledMapCachingProvider(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final shimmers = tester.widgetList<LoadingShimmer>(
          find.byType(LoadingShimmer),
        );
        expect(shimmers.any((shimmer) => shimmer.isLoading), isTrue);
        pending.complete();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pumpAndSettle();
        expect(requests, isNotEmpty);
        expect(
          tester
              .widgetList<LoadingShimmer>(find.byType(LoadingShimmer))
              .any((s) => s.isLoading),
          isFalse,
        );
        if (MapConfig.displayTileUrl.contains('{r}')) {
          expect(
            requests.every(
              (uri) => uri.path.endsWith(density > 1 ? '@2x.png' : '.png'),
            ),
            isTrue,
          );
          if (density == 1) {
            expect(requests.any((uri) => uri.path.contains('@2x')), isFalse);
          }
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
