import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ModalSection extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  final bool padded;

  const ModalSection({
    super.key,
    this.title,
    this.icon,
    required this.child,
    this.padded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              padded ? AppSpacing.base : 0,
              0,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  title!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        child,
      ],
    );
  }
}
