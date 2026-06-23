import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';

class ModalTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? errorText;
  final bool required;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const ModalTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.errorText,
    this.required = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final labelWithAsterisk = required ? '$label *' : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
          decoration: InputDecoration(
            labelText: labelWithAsterisk,
            labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
            prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
            filled: true,
            fillColor: AppColors.surfaceHighest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
          ),
        ),
        if (errorText != null) const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
