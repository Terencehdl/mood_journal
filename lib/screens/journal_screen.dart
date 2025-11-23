import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../models/emotion.dart';
import '../providers/entries_provider.dart';
import '../utils/constants.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entriesProvider = Provider.of<EntriesProvider>(context);
    final entries = entriesProvider.entries;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Journal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.lock_outline,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('App lock coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Entries list
            Expanded(
              child: entries.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: entries.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildEntryCard(context, entries[index], isDark, entriesProvider);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📔', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'No entries yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your first check-in to see your journal!',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, MoodEntry entry, bool isDark, EntriesProvider entriesProvider) {
    return GestureDetector(
      onTap: () {
        _showEntryDetails(context, entry, isDark, entriesProvider);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date et mood
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(entry.date),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Text(
                      AppColors.getMoodEmoji(entry.moodScore),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppColors.getMoodLabel(entry.moodScore),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Stars
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < entry.moodScore ? Icons.star : Icons.star_border,
                  size: 16,
                  color: index < entry.moodScore 
                    ? AppColors.getMoodColor(entry.moodScore)
                    : Colors.grey.shade300,
                );
              }),
            ),
            
            // Emotions
            if (entry.emotions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.emotions.map((emotionId) {
                  final emotion = Emotion.findById(emotionId);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (emotion != null) ...[
                          Text(emotion.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            emotion.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            
            // Journal text preview
            if (entry.journalText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '"${entry.journalText}"',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, MoodEntry entry, bool isDark, EntriesProvider entriesProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy • HH:mm').format(entry.date),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Mood
                      Row(
                        children: [
                          Text(
                            AppColors.getMoodEmoji(entry.moodScore),
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mood: ${AppColors.getMoodLabel(entry.moodScore)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < entry.moodScore ? Icons.star : Icons.star_border,
                                    size: 18,
                                    color: index < entry.moodScore 
                                      ? AppColors.getMoodColor(entry.moodScore)
                                      : Colors.grey.shade300,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Emotions
                      if (entry.emotions.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Emotions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: entry.emotions.map((emotionId) {
                            final emotion = Emotion.findById(emotionId);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark 
                                  ? Colors.white.withOpacity(0.1) 
                                  : AppColors.bgLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (emotion != null) ...[
                                    Text(emotion.emoji, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(
                                      emotion.label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      
                      // Journal entry
                      if (entry.journalText.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Journal Entry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark 
                              ? Colors.white.withOpacity(0.05) 
                              : AppColors.bgLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            entry.journalText,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.7,
                              color: isDark ? Colors.white.withOpacity(0.87) : AppColors.textPrimary,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edit coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _confirmDelete(context, entry, entriesProvider);
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.coral,
                                side: const BorderSide(color: AppColors.coral),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MoodEntry entry, EntriesProvider entriesProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await entriesProvider.deleteEntry(entry.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}