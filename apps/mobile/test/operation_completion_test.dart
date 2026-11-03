import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_entrehuellas/core/presentation/navigation/complete_operation.dart';

void main() {
  testWidgets('Confirmed editor replacement survives disposal of its shell', (
    tester,
  ) async {
    var completed = false;
    final router = GoRouter(
      initialLocation: '/editor',
      routes: [
        GoRoute(
          path: '/editor',
          builder: (context, state) => StatefulBuilder(
            builder: (context, update) => Scaffold(
              body: completed
                  ? const SizedBox.shrink()
                  : Builder(
                      builder: (childContext) => TextButton(
                        onPressed: () {
                          completeOperation(childContext, '/case');
                          update(() => completed = true);
                        },
                        child: const Text('Publicar'),
                      ),
                    ),
            ),
          ),
        ),
        GoRoute(
          path: '/case',
          builder: (context, state) => const Scaffold(body: Text('Ficha real')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();
    expect(find.text('Ficha real'), findsOneWidget);
    expect(find.text('Publicar'), findsNothing);
    expect(router.canPop(), isFalse);
  });
}
