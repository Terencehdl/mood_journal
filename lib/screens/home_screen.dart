import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../models/emotion.dart';
import '../providers/entries_provider.dart';
import '../utils/constants.dart';
import '../widgets/calendar_view.dart';
import 'checkin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _displayMonth = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entriesProvider = Provider.of<EntriesProvider>(context);
    final entries = entriesProvider.entries;
    final todayEntry = entriesProvider.todayEntry;
    final streak = entriesProvider.currentStreak;
    final avgMood = entriesProvider.averageMoodThisWeek;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text('😊', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Contenu scrollable
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats Widget
                  _buildStatsCard(streak, avgMood, isDark),
                  const SizedBox(height: 20),
                  
                  // Calendrier
                  CalendarView(
                    entries: entries,
                    displayMonth: _displayMonth,
                    onMonthChanged: (month) {
                      setState(() {
                        _displayMonth = month;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Check-in CTA ou Message
                  todayEntry == null
                    ? _buildCheckInButton(isDark, entriesProvider)
                    : _buildDoneMessage(isDark),
                  const SizedBox(height: 20),
                  
                  // Recent Entries
                  _buildRecentEntries(entries, isDark),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int streak, double avgMood, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Text(
                '$streak Day Streak',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (avgMood > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${AppColors.getMoodEmoji(avgMood.round())} Mood this week: ${AppColors.getMoodLabel(avgMood.round())}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckInButton(bool isDark, EntriesProvider entriesProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Navigation vers check-in
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckInScreen()),
          );
          
          // Si une entry a été créée, reload via provider
          if (result == true) {
            entriesProvider.loadEntries();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('➕', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Text(
              'Check-in Today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.bgLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'All done for today!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'See you tomorrow 😊',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries(List<MoodEntry> entries, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Entries',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        if (entries.isEmpty)
          _buildEmptyState(isDark)
        else
          ...entries.take(3).map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildEntryCard(entry, isDark),
          )),
      ],
    );
  }

Widget _buildEmptyState(bool isDark) {
  return Center(  // ✅ Wrapp tout dans Center
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 24), // ✅ Ajouter margin
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,  // ✅ Important !
        children: [
          const Text('📝', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first check-in above!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildEntryCard(MoodEntry entry, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(entry.date),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Text(
                    AppColors.getMoodEmoji(entry.moodScore),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppColors.getMoodLabel(entry.moodScore),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (entry.journalText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              entry.journalText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
          if (entry.emotions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.emotions.take(3).map((emotionId) {
                final emotion = Emotion.findById(emotionId);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark 
                      ? Colors.white.withOpacity(0.1) 
                      : AppColors.bgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    emotion?.label ?? emotionId,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}