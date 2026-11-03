import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/failure_feedback.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../view_models/profile_view_model.dart';
import 'profile_avatar.dart';
import 'profile_navigation_row.dart';

class ProfileSummary extends ConsumerWidget {
  const ProfileSummary({required this.onEdit, super.key});
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileViewModelProvider);
    if (async.hasError) {
      return FailureFeedback(
        message: 'No se pudo cargar tu perfil. Reintenta.',
        noticeId: async.error,
        onRetry: () => ref.read(profileViewModelProvider.notifier).retry(),
      );
    }
    if (async.isLoading) {
      return const LoadingShimmer(
        isLoading: true,
        loadingLabel: 'Consultando tu perfil',
        child: ExcludeSemantics(
          child: Row(
            children: [
              CircleAvatar(radius: 36, backgroundColor: Color(0xFFE5E5EA)),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ColoredBox(
                      color: Color(0xFFE5E5EA),
                      child: SizedBox(height: 22),
                    ),
                    SizedBox(height: 8),
                    ColoredBox(
                      color: Color(0xFFE5E5EA),
                      child: SizedBox(height: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    final profile = async.requireValue.profile;
    return ProfileNavigationRow(
      semanticLabel: 'Editar perfil',
      onTap: onEdit,
      padding: const EdgeInsets.symmetric(vertical: 8),
      leading: const ProfileAvatar(size: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.displayName?.trim().isNotEmpty == true
                ? profile.displayName!
                : 'Tu perfil',
            style: const TextStyle(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171918),
            ),
          ),
          if (profile.city?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              profile.city!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Color(0xFF6E6E73),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
