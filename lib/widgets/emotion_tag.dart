import 'package:flutter/material.dart';
import '../models/emotion.dart';
import '../utils/constants.dart';

class EmotionTag extends StatelessWidget {
  final Emotion emotion;
  final bool isSelected;
  final VoidCallback onTap;

  const EmotionTag({
    Key? key,
    required this.emotion,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // AnimatedContainer pour transition smooth
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primary.withOpacity(0.2) 
            : (isDark ? Colors.white.withOpacity(0.1) : Colors.white),
          border: Border.all(
            color: isSelected 
              ? AppColors.primary 
              : (isDark ? Colors.white.withOpacity(0.2) : AppColors.border),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emotion.emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              emotion.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}