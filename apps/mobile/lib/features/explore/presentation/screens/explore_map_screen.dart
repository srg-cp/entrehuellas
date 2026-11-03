import '../../../../core/presentation/widgets/map_sheet_header.dart';
import '../../../../core/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../view_models/explore_view_model.dart';
import '../widgets/explore_case_map.dart';
import '../widgets/explore_map_case_preview.dart';
import '../../domain/entities/explore_page.dart';

class ExploreMapScreen extends ConsumerStatefulWidget {
  const ExploreMapScreen({this.createTileProvider, super.key});
  final TileProvider Function()? createTileProvider;

  @override
  ConsumerState<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends ConsumerState<ExploreMapScreen> {
  final _sheetExtent = ValueNotifier<double>(.5);
  bool _openingCase = false;

  @override
  void dispose() {
    _sheetExtent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(exploreViewModelProvider);
    final data = value.isLoading || value.hasError ? null : value.asData?.value;
    final vm = ref.read(exploreViewModelProvider.notifier);
    Future<void> openCase(ExploreCase item, BuildContext source) async {
      if (_openingCase) return;
      setState(() => _openingCase = true);
      final box = source.findRenderObject() as RenderBox?;
      final navigator = Navigator.of(source).context.findRenderObject();
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero, ancestor: navigator) & box.size;
      try {
        await context.push(
          '/home/${item.fromPet ? 'cases' : 'found-cases'}/${item.id}',
          extra: origin,
        );
        if (context.mounted) {
          await ref.read(exploreViewModelProvider.notifier).refreshIfStale();
        }
      } finally {
        if (mounted) setState(() => _openingCase = false);
      }
    }

    return AppScaffold(
      body: ConfirmationToastHost(
        confirmed: value.hasError || data?.notice != null,
        isError: true,
        message: value.hasError
            ? 'No pudimos consultar los casos.'
            : data?.notice ?? '',
        noticeId: (value.error, data?.noticeId),
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            _sheetExtent.value = notification.extent;
            return false;
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (data == null)
                value.hasError
                    ? Center(
                        child: TextButton(
                          onPressed: vm.refresh,
                          child: const Text('Reintentar'),
                        ),
                      )
                    : const LoadingShimmer(
                        isLoading: true,
                        loadingLabel: 'Consultando casos',
                        child: ColoredBox(color: Color(0xFFE5E5EA)),
                      )
              else
                ContentRefresh(
                  refreshing: data.refreshing,
                  label: 'Actualizando casos',
                  child: ExploreCaseMap(
                    key: ValueKey(data.owner),
                    items: data.items,
                    query: data.query,
                    emptyMessage: data.failed || data.busy
                        ? 'Puedes volver a Explorar para ajustar la búsqueda.'
                        : data.needsLocation
                        ? 'Elige una ubicación desde Explorar para ver casos cercanos.'
                        : null,
                    onOpen: data.busy || _openingCase ? null : openCase,
                    createTileProvider: widget.createTileProvider,
                    previewBuilder: (item, onSummaryHeight) =>
                        ExploreMapCasePreview(
                          key: ValueKey(item.key),
                          item: item,
                          scrollable: false,
                          onSummaryHeight: onSummaryHeight,
                          onOpen: data.busy || _openingCase
                              ? null
                              : (source) => openCase(item, source),
                        ),
                    trailing: [
                      if (data.failed || data.cursor != null)
                        LoadingShimmer(
                          isLoading: data.appending,
                          loadingLabel: 'Consultando más casos',
                          child: TextButton(
                            onPressed: data.busy
                                ? null
                                : data.failed && data.cursor == null
                                ? vm.refresh
                                : vm.more,
                            child: Text(
                              data.failed ? 'Reintentar' : 'Ver más casos',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              MapSheetHeader(
                title: 'Explorar',
                backTooltip: 'Volver a Explorar',
                extent: _sheetExtent,
                onBack: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
