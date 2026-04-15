import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BottomNavInicio extends StatelessWidget {
  final VoidCallback? onTap;

  const BottomNavInicio({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Inicio',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
