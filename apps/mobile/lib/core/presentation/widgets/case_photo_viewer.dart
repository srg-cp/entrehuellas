import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'case_photo.dart';
import 'glass_navigation_bar.dart';
import 'stagger_reveal.dart';

/// Uses the same authorized image providers as the card, without cropping.
class CasePhotoViewer extends StatefulWidget {
  const CasePhotoViewer({
    required this.photos,
    required this.initialPhoto,
    super.key,
  });
  final List<Widget> photos;
  final int initialPhoto;

  @override
  State<CasePhotoViewer> createState() => _CasePhotoViewerState();
}

class _CasePhotoViewerState extends State<CasePhotoViewer> {
  late final _pages = PageController(initialPage: widget.initialPhoto);
  late int _index = widget.initialPhoto;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Widget _fullPhoto(Widget photo) => switch (photo) {
    CasePhotoView() => CasePhotoView(
      image: photo.image,
      semanticLabel: photo.semanticLabel,
      fit: BoxFit.contain,
    ),
    Image() => Image(
      image: photo.image,
      semanticLabel: photo.semanticLabel,
      fit: BoxFit.contain,
    ),
    _ => Center(child: photo),
  };

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 68, bottom: 52),
              child: StaggerReveal(
                count: 1,
                child: StaggerRevealItem(
                  order: 0,
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (index) => setState(() => _index = index),
                    children: [
                      for (final photo in widget.photos)
                        InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: SizedBox.expand(child: _fullPhoto(photo)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GlassNavigationBar(
            icon: Icons.close_rounded,
            foregroundColor: Colors.white,
            tooltip: 'Cerrar foto',
            onBack: () => Navigator.of(context).pop(),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 12,
            child: Semantics(
              liveRegion: true,
              child: Text(
                'Foto ${_index + 1} de ${widget.photos.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
