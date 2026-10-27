import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class BookNowButton extends StatelessWidget {
  const BookNowButton({
    super.key,
    required this.onPressed,
    this.text = "Save Trip",
  });

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
          foregroundColor: isDark ? AppColors.primaryDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
