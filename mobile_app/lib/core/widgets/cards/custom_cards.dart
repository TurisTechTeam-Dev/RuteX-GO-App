import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blancoTarjeta,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.negroTexto, width: 2),

        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
