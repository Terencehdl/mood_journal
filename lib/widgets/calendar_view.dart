import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../utils/constants.dart';

class CalendarView extends StatelessWidget {
  final List<MoodEntry> entries;
  final DateTime displayMonth; // Mois affiché
  final Function(DateTime) onMonthChanged;

  const CalendarView({
    Key? key,
    required this.entries,
    required this.displayMonth,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.white.withOpacity(0.05) 
          : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 16),
          _buildWeekDays(isDark),
          const SizedBox(height: 8),
          _buildDaysGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(displayMonth),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final previousMonth = DateTime(
                  displayMonth.year,
                  displayMonth.month - 1,
                );
                onMonthChanged(previousMonth);
              },
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final nextMonth = DateTime(
                  displayMonth.year,
                  displayMonth.month + 1,
                );
                onMonthChanged(nextMonth);
              },
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekDays(bool isDark) {
    const weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark 
                ? Colors.white.withOpacity(0.6) 
                : AppColors.textSecondary,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDaysGrid(bool isDark) {
    // Calculer le nombre de jours dans le mois
    final daysInMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
    
    // Calculer le premier jour de la semaine (0 = dimanche)
    final firstDayWeekday = DateTime(displayMonth.year, displayMonth.month, 1).weekday;
    final offset = firstDayWeekday % 7; // Offset pour aligner le calendrier
    
    return GridView.builder(
      shrinkWrap: true, // Important : ne prend que l'espace nécessaire
      physics: const NeverScrollableScrollPhysics(), // Pas de scroll interne
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 colonnes (jours de la semaine)
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1, // Cellules carrées
      ),
      itemCount: offset + daysInMonth, // Total de cellules
      itemBuilder: (context, index) {
        if (index < offset) {
          // Cellules vides avant le 1er jour du mois
          return const SizedBox();
        }
        
        final day = index - offset + 1;
        final date = DateTime(displayMonth.year, displayMonth.month, day);
        
        // Trouver l'entry pour ce jour
        final entry = entries.cast<MoodEntry?>().firstWhere(
          (e) => e != null && _isSameDay(e.date, date),
          orElse: () => null,
        );
        
        final isToday = _isSameDay(date, DateTime.now());
        
        return Container(
          decoration: BoxDecoration(
            color: entry != null 
              ? AppColors.getMoodColor(entry.moodScore)
              : (isDark 
                  ? Colors.white.withOpacity(0.05) 
                  : AppColors.bgLight),
            borderRadius: BorderRadius.circular(8),
            border: isToday 
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: entry != null 
                  ? Colors.white 
                  : (isDark ? Colors.white.withOpacity(0.6) : AppColors.textSecondary),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}