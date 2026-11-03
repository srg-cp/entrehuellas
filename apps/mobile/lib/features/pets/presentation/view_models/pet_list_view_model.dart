import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/state/retained_query.dart';
import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../../providers/pet_providers.dart';
import 'pet_photos_view_model.dart';

final petListRefreshNoticeProvider = NotifierProvider.autoDispose
    .family<PetListRefreshNotice, Object?, bool>(PetListRefreshNotice.new);

class PetListRefreshNotice extends Notifier<Object?> {
  PetListRefreshNotice(this.archived);
  final bool archived;
  @override
  Object? build() {
    ref.watch(petSessionProvider);
    return null;
  }

  void clear() => state = null;
  void failed() => state = Object();
}

final petListViewModelProvider =
    AsyncNotifierProvider.autoDispose<PetListViewModel, List<Pet>>(
      PetListViewModel.new,
      retry: (_, _) => null,
    );

class PetListViewModel extends AsyncNotifier<List<Pet>> {
  PetListViewModel({this.archived = false});
  final bool archived;
  int _generation = 0;
  bool _refreshing = false;
  @override
  Future<List<Pet>> build() async {
    final generation = ++_generation;
    _refreshing = false;
    late final RetainedQuery retained;
    final useCase = ref.watch(listMyPetsProvider);
    final notice = ref.watch(petListRefreshNoticeProvider(archived).notifier);
    final session = await ref.watch(petSessionProvider.future);
    if (session == null) throw const PetFailure(PetFailureKind.signedOut);
    retained = RetainedQuery(
      ref,
      freshFor: const Duration(minutes: 1),
      revalidate: () async {
        if (_refreshing || state.isLoading || !state.hasValue) return;
        _refreshing = true;
        notice.clear();
        final previous = state;
        try {
          final pets = await useCase(session.userId, archived: archived);
          if (!ref.mounted || generation != _generation) return;
          state = AsyncData(pets);
          retained.markFresh();
        } catch (error, stack) {
          if (!ref.mounted || generation != _generation) return;
          final failure = AsyncError<List<Pet>>(error, stack);
          if (error is! PetFailure ||
              error.kind != PetFailureKind.unavailable) {
            retained.forget();
          }
          // Network failure may retain data; loss of access must remove it.
          if (error is PetFailure && error.kind == PetFailureKind.unavailable) {
            state = AsyncData(previous.requireValue);
            notice.failed();
          } else {
            state = failure;
          }
        } finally {
          if (generation == _generation) _refreshing = false;
        }
      },
    );
    final changes = ref
        .watch(petChangesProvider)
        .watch(session.userId)
        .listen((_) => ref.invalidateSelf());
    ref.onDispose(changes.cancel);
    final pets = await useCase(session.userId, archived: archived);
    if (ref.mounted && generation == _generation) {
      retained.markFresh();
      notice.clear();
    }
    return pets;
  }

  void reload() => ref.invalidateSelf();
}

final petDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<PetDetailViewModel, Pet, String>(
      PetDetailViewModel.new,
      retry: (_, _) => null,
    );

class PetDetailViewModel extends AsyncNotifier<Pet> {
  PetDetailViewModel(this.petId);
  final String petId;
  @override
  Future<Pet> build() async {
    final useCase = ref.watch(readPetProvider);
    final session = await ref.watch(petSessionProvider.future);
    if (session == null) throw const PetFailure(PetFailureKind.signedOut);
    final changes = ref
        .watch(petChangesProvider)
        .watch(session.userId, petId: petId)
        .listen((_) => ref.invalidateSelf());
    ref.onDispose(changes.cancel);
    final photos = ref.watch(petPhotosViewModelProvider(petId).notifier);
    final results = await Future.wait<Object?>([
      useCase(session.userId, petId),
      photos.ensureInitialized(true),
    ]);
    return results.first as Pet;
  }

  void reload() => ref.invalidateSelf();
}

final archivedPetListViewModelProvider =
    AsyncNotifierProvider.autoDispose<PetListViewModel, List<Pet>>(
      () => PetListViewModel(archived: true),
      retry: (_, _) => null,
    );
