import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex; // Index de l'onglet actif (0-3)
  final Function(int) onTap; // Callback quand on change d'onglet

  const BottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
          ? const Color(0xFF1A1A1A).withOpacity(0.95) 
          : Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        // SafeArea pour gérer l'encoche iPhone
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                index: 0,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.trending_up,
                label: 'Insights',
                index: 1,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.book,
                label: 'Journal',
                index: 2,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.settings,
                label: 'Settings',
                index: 3,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque, // Toute la zone est cliquable
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive 
                ? AppColors.primary 
                : (isDark ? Colors.white.withOpacity(0.5) : Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive 
                  ? AppColors.primary 
                  : (isDark ? Colors.white.withOpacity(0.5) : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}