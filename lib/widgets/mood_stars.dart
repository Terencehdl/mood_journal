import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MoodStars extends StatelessWidget {
  final int rating; // Mood actuel (0-5)
  final Function(int) onRatingChanged; // Callback quand on tape une étoile
  final double size; // Taille des étoiles

  const MoodStars({
    Key? key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starRating = index + 1; // 1-5
        final isSelected = starRating <= rating;
        
        return GestureDetector(
          onTap: () => onRatingChanged(starRating),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedScale(
              // Animation de scale quand sélectionné
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? Icons.star : Icons.star_border,
                size: size,
                color: isSelected 
                  ? AppColors.getMoodColor(starRating) 
                  : Colors.grey.shade300,
              ),
            ),
          ),
        );
      }),
    );
  }
}