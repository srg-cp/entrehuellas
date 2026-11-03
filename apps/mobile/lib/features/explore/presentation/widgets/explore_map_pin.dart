import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/brand_map_pin.dart';

class ExploreMapPin extends StatelessWidget {
  const ExploreMapPin({required this.selected, required this.onTap, super.key});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BrandMapPin(
    color: selected ? const Color(0xFF171918) : Colors.white,
    logoColor: selected ? Colors.white : Colors.black,
    logoSize: 30,
    elevation: selected ? 4 : 2,
    label: null,
    onTap: onTap,
  );
}
