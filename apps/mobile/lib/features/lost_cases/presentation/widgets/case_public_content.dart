import '../../../../core/presentation/widgets/case_photo.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/case_public_cards.dart';
import '../../../../core/presentation/widgets/case_photo_failure.dart';
import 'package:flutter/material.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../domain/entities/lost_case.dart';

String caseDateLabel(DateTime time) => caseDateTimeLabel(time);

String caseFailureLabel(CaseFailureKind? kind) => switch (kind) {
  CaseFailureKind.busy =>
    'Otra operación está usando esta mascota. Reintenta en unos segundos.',
  CaseFailureKind.localStorage =>
    'No pudimos guardar el borrador en este dispositivo. Libera espacio y reintenta antes de salir.',
  CaseFailureKind.timedOut =>
    'La publicación no respondió. Reintenta o consulta Mis casos.',
  CaseFailureKind.invalid =>
    'Elige mascota y fotos, fecha y hora válidas, punto y referencia del lugar.',
  CaseFailureKind.activeCase =>
    'Esta mascota ya tiene un caso perdido activo. Consulta Mis casos.',
  CaseFailureKind.photosUnverified =>
    'Vuelve a guardar las fotos en Editar mascota.',
  CaseFailureKind.incompletePet =>
    'Completa tamaño, edad y rasgos desde Editar mascota antes de publicar.',
  CaseFailureKind.conflict =>
    'La ficha o el envío cambió. Consulta Mis casos antes de iniciar otra publicación.',
  CaseFailureKind.forbidden =>
    'No tienes autorización para publicar esta mascota. Revisa tu sesión.',
  _ =>
    'No pudimos confirmar la operación. Conservamos los datos para reintentar.',
};

class CasePublicContent extends StatelessWidget {
  const CasePublicContent({
    required this.value,
    this.actions,
    this.contact,
    this.offline = false,
    this.isPreview = false,
    super.key,
  });
  final PublicLostCase value;
  final Widget? actions;
  final Widget? contact;
  final bool offline;
  final bool isPreview;
  @override
  Widget build(BuildContext context) {
    final f = value.fields;
    return CasePublicCards(
      key: ValueKey(value.id),
      offline: offline,
      name: f.name,
      eventLabel: value.status == 'active' ? 'Perdido' : 'Búsqueda cerrada',
      photos: [
        for (final photo in value.photos)
          photo.uri == null
              ? const CasePhotoFailure()
              : CasePhotoView.network(
                  photo.uri!,
                  semanticLabel: 'Foto de ${f.name}',
                ),
      ],
      facts: [
        CasePublicFact('Especie', switch (f.species) {
          PetSpecies.dog => 'Perro',
          PetSpecies.cat => 'Gato',
          _ => f.speciesDetail ?? 'Otra especie',
        }),
        if (f.sex != null)
          CasePublicFact('Sexo', f.sex == PetSex.male ? 'Macho' : 'Hembra'),
        if (f.size != null)
          CasePublicFact('Tamaño', switch (f.size!) {
            PetSize.small => 'Pequeño',
            PetSize.medium => 'Mediano',
            PetSize.large => 'Grande',
          }),
        if (f.ageMonths != null) CasePublicFact('Edad', '${f.ageMonths} meses'),
      ],
      description: f.traits ?? '',
      occurredAt: 'Desaparición: ${caseDateLabel(value.occurredAt)}',
      latitude: value.latitude,
      longitude: value.longitude,
      privacy: isPreview ? casePublicationPrivacyNotice : null,
      actions: actions,
      contact: value.status == 'active' ? contact : null,
    );
  }
}

class CasePreviewContent extends StatelessWidget {
  const CasePreviewContent({
    required this.value,
    this.actions,
    this.isPreview = true,
    super.key,
  });
  final PublicLostCase value;
  final Widget? actions;
  final bool isPreview;
  @override
  Widget build(BuildContext context) =>
      CasePublicContent(value: value, actions: actions, isPreview: isPreview);
}
