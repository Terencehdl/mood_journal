import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF7C3AED);
  
  // Mood colors
  static const Color mint = Color(0xFF86EFAC);
  static const Color peach = Color(0xFFFDBA74);
  static const Color coral = Color(0xFFFB7185);
  
  // Backgrounds
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color bgDark = Color(0xFF1A1A1A);
  
  // Text
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  
  // Mood gradient
  static Color getMoodColor(int rating) {
    switch (rating) {
      case 5:
        return mint;
      case 4:
        return mint.withOpacity(0.8);
      case 3:
        return peach;
      case 2:
        return coral.withOpacity(0.8);
      case 1:
        return coral;
      default:
        return Colors.grey;
    }
  }
  
  static String getMoodEmoji(int rating) {
    switch (rating) {
      case 5:
        return '🎉';
      case 4:
        return '😄';
      case 3:
        return '😊';
      case 2:
        return '😐';
      case 1:
        return '😔';
      default:
        return '😐';
    }
  }
  
  static String getMoodLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Great';
      case 4:
        return 'Good';
      case 3:
        return 'Okay';
      case 2:
        return 'Bad';
      case 1:
        return 'Very Bad';
      default:
        return '';
    }
  }
}

class AppConstants {
  static const String appName = 'MoodJournal';
  static const int maxJournalLength = 500;
  static const int minEntriesForInsights = 7;
}