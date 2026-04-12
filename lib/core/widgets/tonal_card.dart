import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TonalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const TonalCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
