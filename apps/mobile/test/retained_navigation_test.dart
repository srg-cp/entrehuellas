import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_page.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_list_view_model.dart';
import 'support/fake_current_location.dart';
import 'support/fake_pets.dart';
import 'explore_test.dart' show SearchFake, item;

class CountingPets extends FakePets {
  int lists = 0;
  @override
  Future<List<Pet>> list(String ownerId, {bool archived = false}) {
    lists++;
    return super.list(ownerId, archived: archived);
  }
}

void main() {
  testWidgets('manual refresh supersedes an older background response', (
    tester,
  ) async {
    final repo = SearchFake();
    final container = ProviderContainer(
      overrides: [
        exploreRepositoryProvider.overrideWithValue(repo),
        currentLocationRepositoryProvider.overrideWithValue(
          const FakeCurrentLocation(),
        ),
        exploreSessionProvider.overrideWith(
          (_) => Stream.value(const AuthSession(userId: 'a')),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(exploreViewModelProvider, (_, _) {});
    await tester.pump();
    await tester.pump(const Duration(seconds: 31));
    final pending = repo.pending = Completer<ExplorePage>();
    final background = container
        .read(exploreViewModelProvider.notifier)
        .refreshIfStale();
    repo.pending = null;
    repo.firstPage = [item('confirmed-change')];
    await container.read(exploreViewModelProvider.notifier).refresh();
    pending.complete(ExplorePage(items: [item('old-result')]));
    await tester.pump();
    await background;
    expect(
      container.read(exploreViewModelProvider).requireValue.items.single.id,
      'confirmed-change',
    );
    expect(repo.calls.length, 3);
    sub.close();
    container.dispose();
  });

  testWidgets('ten brief section round trips reuse one query per list', (
    tester,
  ) async {
    final explore = SearchFake();
    final pets = CountingPets();
    final container = ProviderContainer(
      overrides: [
        exploreRepositoryProvider.overrideWithValue(explore),
        currentLocationRepositoryProvider.overrideWithValue(
          const FakeCurrentLocation(),
        ),
        exploreSessionProvider.overrideWith(
          (_) => Stream.value(const AuthSession(userId: 'a')),
        ),
        petRepositoryProvider.overrideWithValue(pets),
        petSessionProvider.overrideWith(
          (_) => Stream.value(const AuthSession(userId: 'a')),
        ),
      ],
    );
    addTearDown(container.dispose);
    for (var i = 0; i < 10; i++) {
      final e = container.listen(exploreViewModelProvider, (_, _) {});
      final p = container.listen(petListViewModelProvider, (_, _) {});
      await tester.pump();
      expect(container.read(exploreViewModelProvider).hasValue, isTrue);
      expect(container.read(petListViewModelProvider).hasValue, isTrue);
      await container.read(exploreViewModelProvider.notifier).refreshIfStale();
      e.close();
      p.close();
      await tester.pump(const Duration(seconds: 1));
    }
    expect(explore.calls.length, 1);
    expect(pets.lists, 1);
    container.dispose();
  });

  testWidgets(
    'stale re-entry retains content, deduplicates and updates silently',
    (tester) async {
      final repo = SearchFake();
      final container = ProviderContainer(
        overrides: [
          exploreRepositoryProvider.overrideWithValue(repo),
          currentLocationRepositoryProvider.overrideWithValue(
            const FakeCurrentLocation(),
          ),
          exploreSessionProvider.overrideWith(
            (_) => Stream.value(const AuthSession(userId: 'a')),
          ),
        ],
      );
      addTearDown(container.dispose);
      var sub = container.listen(exploreViewModelProvider, (_, _) {});
      await tester.pump();
      sub.close();
      await tester.pump(const Duration(seconds: 31));
      expect(repo.calls.length, 1, reason: 'Expiry must not poll');
      repo.pending = Completer<ExplorePage>();
      sub = container.listen(exploreViewModelProvider, (_, _) {});
      await tester.pump();
      final second = container
          .read(exploreViewModelProvider.notifier)
          .refreshIfStale();
      expect(repo.calls.length, 2);
      final current = container.read(exploreViewModelProvider);
      expect(current.isLoading, isFalse);
      expect(current.requireValue.refreshing, isFalse);
      expect(current.requireValue.items.single.id, 'one');
      repo.pending!.complete(ExplorePage(items: [item('updated')]));
      await tester.pump();
      await second;
      expect(
        container.read(exploreViewModelProvider).requireValue.items.single.id,
        'updated',
      );
      sub.close();
      container.dispose();
    },
  );

  testWidgets('inactive retained data expires and re-entry loads again', (
    tester,
  ) async {
    final repo = CountingPets();
    final container = ProviderContainer(
      overrides: [
        petRepositoryProvider.overrideWithValue(repo),
        petSessionProvider.overrideWith(
          (_) => Stream.value(const AuthSession(userId: 'a')),
        ),
      ],
    );
    addTearDown(container.dispose);
    var sub = container.listen(petListViewModelProvider, (_, _) {});
    await tester.pump();
    sub.close();
    await tester.pump(const Duration(minutes: 4));
    await tester.pump();
    sub = container.listen(petListViewModelProvider, (_, _) {});
    await tester.pump();
    expect(repo.lists, 2);
    sub.close();
    container.dispose();
  });

  testWidgets('account change rejects an old pending exploration response', (
    tester,
  ) async {
    final sessions = StreamController<AuthSession?>.broadcast();
    final repo = SearchFake();
    final container = ProviderContainer(
      overrides: [
        exploreRepositoryProvider.overrideWithValue(repo),
        currentLocationRepositoryProvider.overrideWithValue(
          const FakeCurrentLocation(),
        ),
        exploreSessionProvider.overrideWith((_) => sessions.stream),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(sessions.close);
    final sub = container.listen(exploreViewModelProvider, (_, _) {});
    await tester.pump();
    sessions.add(const AuthSession(userId: 'a'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 31));
    final pending = repo.pending = Completer<ExplorePage>();
    final refresh = container
        .read(exploreViewModelProvider.notifier)
        .refreshIfStale();
    await tester.pump();
    repo.pending = null;
    repo.firstPage = [item('account-b')];
    sessions.add(const AuthSession(userId: 'b'));
    await tester.pump();
    pending.complete(ExplorePage(items: [item('account-a-secret')]));
    await tester.pump();
    await refresh;
    final current = container.read(exploreViewModelProvider).requireValue;
    expect(current.owner, 'b');
    expect(current.items.single.id, 'account-b');
    sessions.add(null);
    await tester.pump();
    container.read(exploreViewModelProvider);
    await tester.pump();
    expect(container.read(exploreViewModelProvider).hasError, isTrue);
    sub.close();
    container.dispose();
  });

  testWidgets(
    'pets keep data on background network failure and recover on focus',
    (tester) async {
      final repo = CountingPets();
      final container = ProviderContainer(
        overrides: [
          petRepositoryProvider.overrideWithValue(repo),
          petSessionProvider.overrideWith(
            (_) => Stream.value(const AuthSession(userId: 'a')),
          ),
        ],
      );
      addTearDown(container.dispose);
      var sub = container.listen(petListViewModelProvider, (_, _) {});
      await tester.pump();
      repo.fail = true;
      sub.close();
      await tester.pump(const Duration(seconds: 61));
      sub = container.listen(petListViewModelProvider, (_, _) {});
      await tester.pump();
      expect(repo.lists, 2);
      expect(container.read(petListViewModelProvider).hasValue, isTrue);
      expect(container.read(petListRefreshNoticeProvider(false)), isNotNull);
      repo.fail = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(repo.lists, 3);
      expect(container.read(petListRefreshNoticeProvider(false)), isNull);
      container.read(petListViewModelProvider.notifier).reload();
      container.read(petListViewModelProvider);
      await tester.pump();
      expect(repo.lists, 4, reason: 'Manual refresh bypasses freshness');
      sub.close();
      container.dispose();
    },
  );
}
