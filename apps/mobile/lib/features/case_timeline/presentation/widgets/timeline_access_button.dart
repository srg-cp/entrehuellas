import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/case_action_button.dart';
import '../../domain/entities/case_timeline.dart';
import '../view_models/case_timeline_view_model.dart';

class TimelineAccessButton extends ConsumerWidget {
  const TimelineAccessButton({
    required this.target,
    this.companion,
    this.onReturn,
    super.key,
  });
  final TimelineTarget target;
  final Widget? companion;
  final VoidCallback? onReturn;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = timelineAccessViewModelProvider(target),
        value = ref.watch(provider);
    if (value.isLoading) return companion ?? const SizedBox.shrink();
    if (value.hasError) {
      return ConfirmationToastHost(
        confirmed: true,
        message: 'No pudimos consultar el acceso al historial.',
        noticeId: value.error,
        isError: true,
        child: Column(
          children: [
            TextButton(
              onPressed: ref.read(provider.notifier).retry,
              child: const Text('Reintentar historial'),
            ),
            if (companion != null) companion!,
          ],
        ),
      );
    }
    return CaseActionLayout(
      utilities: true,
      children: [
        if (value.asData?.value == true)
          CaseUtilityButton(
            title: 'Ver seguimiento',
            onReturn: onReturn,
            subtitle: 'Historial del caso',
            icon: Icons.route_outlined,
            route:
                '/home/timeline/${target.community ? 'found' : 'lost'}/${target.id}',
          ),
        if (companion != null) companion!,
      ],
    );
  }
}
