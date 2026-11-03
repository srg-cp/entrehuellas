import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/glass_surface.dart';
import 'profile_navigation_row.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    required this.title,
    required this.destinations,
    required this.enabled,
    super.key,
  });
  final String title;
  final List<({IconData icon, String label, String path})> destinations;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: Color(0xFF454746),
          ),
        ),
      ),
      const SizedBox(height: 12),
      GlassSurface.card(
        radius: 22,
        child: Column(
          children: [
            for (var i = 0; i < destinations.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 1,
                    thickness: .5,
                    color: Color(0x246E6E73),
                  ),
                ),
              ProfileNavigationRow(
                leading: Icon(
                  destinations[i].icon,
                  size: 22,
                  color: const Color(0xFF454746),
                ),
                onTap: enabled
                    ? () => context.push(destinations[i].path)
                    : null,
                child: Text(
                  destinations[i].label,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF171918),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
