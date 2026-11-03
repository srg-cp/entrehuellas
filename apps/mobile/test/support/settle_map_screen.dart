import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/loading_shimmer.dart';

/// Flush tile-cache IO without waiting on a repeating loading animation.
Future<void> settleMapScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
  var hadLoadingTiles = false;
  for (var i = 0; i < 40; i++) {
    final loading = tester
        .widgetList<LoadingShimmer>(find.byType(LoadingShimmer))
        .any(
          (widget) =>
              widget.loadingLabel == 'Consultando mapa' && widget.isLoading,
        );
    hadLoadingTiles = hadLoadingTiles || loading;
    if (i >= 4 && !loading) break;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pumpAndSettle();
  if (hadLoadingTiles) {
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
  }
}
