import '../../../../core/presentation/widgets/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../domain/failures/profile_failure.dart';
import '../view_models/profile_photo_view_model.dart';
import '../view_models/profile_view_model.dart';
import 'profile_avatar.dart';

class ProfilePhotoEditor extends ConsumerStatefulWidget {
  const ProfilePhotoEditor({super.key});
  @override
  ConsumerState<ProfilePhotoEditor> createState() => _ProfilePhotoEditorState();
}

class _ProfilePhotoEditorState extends ConsumerState<ProfilePhotoEditor> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(profilePhotoViewModelProvider.notifier).recover();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileViewModelProvider, (previous, next) {
      if (!next.isLoading &&
          next.hasValue &&
          (previous == null || previous.isLoading || previous.hasError)) {
        ref.read(profilePhotoViewModelProvider.notifier).recover();
      }
    });
    final photo = ref.watch(profilePhotoViewModelProvider);
    final profile = ref.watch(profileViewModelProvider);
    final busy = photo.result.isLoading;
    final model = ref.read(profilePhotoViewModelProvider.notifier);
    final available =
        !profile.isLoading &&
        !profile.hasError &&
        !(profile.asData?.value.isBusy ?? true);
    final failed = photo.result.hasError;
    final retry = failed && photo.bytes != null;
    final invalid =
        photo.result.error is ProfileFailure &&
        (photo.result.error as ProfileFailure).kind ==
            ProfileFailureKind.invalidPhoto;
    return ConfirmationToastHost(
      key: ValueKey(profile.asData?.value.profile.userId),
      confirmed: failed || photo.result.asData?.value != null,
      isError: failed,
      message: failed
          ? (invalid
                ? 'Elige una imagen válida.'
                : 'No se pudo confirmar la foto. Tócala para reintentar.')
          : 'Foto actualizada',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoadingShimmer(
            isLoading: busy || profile.isLoading,
            loadingLabel: busy ? 'Actualizando foto' : 'Consultando foto',
            radius: 56,
            child: Semantics(
              label: photo.recovered
                  ? 'Foto recuperada pendiente de guardar'
                  : (retry
                        ? 'Reintentar foto de perfil'
                        : 'Cambiar foto de perfil'),
              button: !photo.recovered,
              enabled: available && !busy && !photo.recovered,
              child: GestureDetector(
                onTap: available && !busy && !photo.recovered
                    ? (retry ? model.retry : model.choose)
                    : null,
                child: profile.isLoading
                    ? const CircleAvatar(
                        radius: 56,
                        backgroundColor: Color(0xFFE5E5EA),
                      )
                    : photo.recovered && photo.bytes != null
                    ? ClipOval(
                        child: Image.memory(
                          photo.bytes!,
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Stack(
                        children: [
                          ProfileAvatar(size: 112),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GlassSurface(
                              radius: 20,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.photo_camera_outlined,
                                  size: 22,
                                  color: Color(0xFF454746),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          // Android activity recovery is exceptional and requires explicit confirmation.
          if (photo.recovered) ...[
            const SizedBox(height: 12),
            LoadingShimmer(
              isLoading: busy,
              loadingLabel: 'Guardando foto recuperada',
              radius: 16,
              child: TextButton(
                onPressed: busy || !available ? null : model.retry,
                child: const Text('Guardar foto recuperada'),
              ),
            ),
            TextButton(
              onPressed: busy ? null : model.discard,
              child: const Text('Descartar foto recuperada'),
            ),
          ],
        ],
      ),
    );
  }
}
