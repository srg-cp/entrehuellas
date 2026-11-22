import '../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/profile_view_model.dart';

class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({this.size = 40, super.key});
  final double size;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);
    final profile = (!state.isLoading || state.isRefreshing) && !state.hasError
        ? state.asData?.value.profile
        : null;
    final parts = (profile?.displayName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? null
        : '${parts.first.characters.first}${parts.length > 1 ? parts.last.characters.first : ''}'
              .toUpperCase();
    final fallback = Center(
      child: initials == null
          ? Icon(
              Icons.person_outline_rounded,
              size: size * .5,
              color: AppColors.secondary,
            )
          : Text(
              initials,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: size * .34,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
    );
    return ExcludeSemantics(
      child: ClipOval(
        child: ColoredBox(
          color: AppColors.surface,
          child: SizedBox(
            width: size,
            height: size,
            child: profile?.avatarUri == null
                ? fallback
                : Image.network(
                    profile!.avatarUri.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => fallback,
                    loadingBuilder: (_, image, progress) =>
                        progress == null ? image : fallback,
                  ),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key});
  @override
  Widget build(BuildContext context) => Builder(
    builder: (originContext) => Tooltip(
      message: 'Abrir perfil',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            final box = originContext.findRenderObject() as RenderBox;
            final origin = box.localToGlobal(Offset.zero) & box.size;
            context.push('/home/profile', extra: origin);
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: ProfileAvatar(),
          ),
        ),
      ),
    ),
  );
}
