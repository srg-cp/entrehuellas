import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../view_models/profile_photo_view_model.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/profile_editor.dart';
import '../widgets/profile_photo_editor.dart';
import '../widgets/profile_screen_shell.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({this.cityFieldBuilder, super.key});
  final ProfileCityFieldBuilder? cityFieldBuilder;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  bool _confirming = false;
  bool _allowPop = false;

  Future<void> _back() async {
    if (_confirming || _busy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (_dirty) {
      _confirming = true;
      final discard = await confirmDiscardAction(
        context,
        '¿Descartar cambios?',
        'Los cambios de tu perfil sin guardar se perderán.',
        'Descartar',
      );
      _confirming = false;
      if (!mounted || !discard || _busy) return;
    }
    if (!mounted) return;
    ref.read(profileViewModelProvider.notifier).discard();
    ref.read(profilePhotoViewModelProvider.notifier).discard();
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  bool get _busy =>
      ref.read(profileViewModelProvider).asData?.value.isBusy == true ||
      ref.read(profilePhotoViewModelProvider).result.isLoading;

  bool get _dirty {
    final photo = ref.read(profilePhotoViewModelProvider);
    return ref.read(profileViewModelProvider).asData?.value.isDirty == true ||
        (photo.bytes != null && (photo.recovered || photo.result.hasError));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileViewModelProvider);
    ref.watch(profilePhotoViewModelProvider);
    return PopScope(
      canPop: _allowPop || (!_busy && !_dirty),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _back();
        } else {
          ref.read(profileViewModelProvider.notifier).discard();
        }
      },
      child: ProfileScreenShell(
        title: 'Editar perfil',
        navigationEnabled: !_busy,
        onBack: _back,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProfilePhotoEditor(),
            const SizedBox(height: 24),
            ProfileEditor(cityFieldBuilder: widget.cityFieldBuilder),
          ],
        ),
      ),
    );
  }
}
