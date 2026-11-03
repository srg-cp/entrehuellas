import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'case_photo_failure.dart';
import 'loading_shimmer.dart';

class CasePhotoView extends StatelessWidget {
  CasePhotoView.network(
    Uri uri, {
    this.semanticLabel,
    this.fit = BoxFit.cover,
    super.key,
  }) : image = uri.scheme == 'data'
           ? MemoryImage(uri.data!.contentAsBytes())
           : NetworkImage(uri.toString());
  CasePhotoView.memory(
    Uint8List bytes, {
    this.semanticLabel,
    this.fit = BoxFit.cover,
    super.key,
  }) : image = MemoryImage(bytes);
  const CasePhotoView({
    required this.image,
    this.semanticLabel,
    this.fit = BoxFit.cover,
    super.key,
  });
  final ImageProvider image;
  final String? semanticLabel;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => Image(
    image: image,
    semanticLabel: semanticLabel,
    fit: fit,
    frameBuilder: (context, child, frame, synchronous) =>
        synchronous || frame != null ? child : const CasePhotoSkeleton(),
    errorBuilder: (_, _, _) => const CasePhotoFailure(),
  );
}

class CasePhotoSkeleton extends StatelessWidget {
  const CasePhotoSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const LoadingShimmer(
    isLoading: true,
    isAction: false,
    radius: 0,
    loadingLabel: 'Consultando foto del caso',
    child: ExcludeSemantics(
      child: SizedBox.expand(child: ColoredBox(color: Color(0xFFE5E5EA))),
    ),
  );
}
