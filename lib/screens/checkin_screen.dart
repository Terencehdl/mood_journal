import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../models/emotion.dart';
import '../providers/entries_provider.dart';
import '../utils/constants.dart';
import '../utils/prompts.dart';
import '../widgets/mood_stars.dart';
import '../widgets/emotion_tag.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _journalController = TextEditingController();
  
  int _currentStep = 0;
  int _moodRating = 0;
  List<String> _selectedEmotions = [];
  
  @override
  void dispose() {
    _pageController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveEntry() async {
    final entriesProvider = Provider.of<EntriesProvider>(context, listen: false);
    
    final entry = MoodEntry.create(
      moodScore: _moodRating,
      emotions: _selectedEmotions,
      journalText: _journalController.text.trim(),
    );
    
    // ✅ Utiliser le Provider au lieu de StorageService
    await entriesProvider.addEntry(entry);
    
    // Retourner true pour dire "entry créée"
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header avec progress
            _buildHeader(isDark),
            
            // Contenu des étapes
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMoodStep(isDark),
                  _buildEmotionsStep(isDark),
                  _buildJournalStep(isDark),
                  _buildDoneStep(isDark),
                ],
              ),
            ),
            
            // Boutons navigation
            _buildBottomButtons(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Step ${_currentStep + 1} of 4',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // STEP 1: Mood Selection
  Widget _buildMoodStep(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            MoodStars(
              rating: _moodRating,
              onRatingChanged: (rating) {
                setState(() {
                  _moodRating = rating;
                });
              },
            ),
            const SizedBox(height: 32),
            if (_moodRating > 0)
              AnimatedOpacity(
                opacity: _moodRating > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _getMoodMessage(_moodRating),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMoodMessage(int mood) {
    switch (mood) {
      case 5:
        return "Amazing! What made today special?";
      case 4:
        return "That's great! Keep it up!";
      case 3:
        return "Okay day. Tomorrow will be better.";
      case 2:
        return "We all have tough days. You're not alone.";
      case 1:
        return "I'm sorry you're struggling. Let's reflect together.";
      default:
        return "";
    }
  }

  // STEP 2: Emotions Selection
  Widget _buildEmotionsStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'What emotions are you feeling?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '(Optional - tap to select)',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Positive emotions
          _buildEmotionGroup(
            'Positive',
            Emotion.getByCategory(EmotionCategory.positive),
            isDark,
          ),
          const SizedBox(height: 24),
          
          // Negative emotions
          _buildEmotionGroup(
            'Negative',
            Emotion.getByCategory(EmotionCategory.negative),
            isDark,
          ),
          const SizedBox(height: 24),
          
          // Neutral emotions
          _buildEmotionGroup(
            'Neutral',
            Emotion.getByCategory(EmotionCategory.neutral),
            isDark,
          ),
          
          if (_selectedEmotions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Selected: ${_selectedEmotions.length} emotion${_selectedEmotions.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionGroup(String title, List<Emotion> emotions, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: emotions.map((emotion) {
            final isSelected = _selectedEmotions.contains(emotion.id);
            return EmotionTag(
              emotion: emotion,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedEmotions.remove(emotion.id);
                  } else {
                    _selectedEmotions.add(emotion.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 3: Journal Entry
  Widget _buildJournalStep(bool isDark) {
    final prompt = Prompts.getPromptForMood(_moodRating, _selectedEmotions);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: TextField(
              controller: _journalController,
              maxLines: 12,
              maxLength: AppConstants.maxJournalLength,
              decoration: InputDecoration(
                hintText: 'Write your thoughts here...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                  fontFamily: 'Georgia',
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Done/Confirmation
  Widget _buildDoneStep(bool isDark) {
  final entriesProvider = Provider.of<EntriesProvider>(context);
  final entryCount = entriesProvider.totalEntries;
  final encouragement = Prompts.getEncouragement(entryCount);
  
  return SingleChildScrollView(  // ✅ Wrapp dans SingleChildScrollView
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.7, // ✅ Hauteur fixe
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // ✅ Important
            children: [
              const Text('✅', style: TextStyle(fontSize: 100)),
              const SizedBox(height: 32),
              Text(
                'Entry Saved!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                encouragement,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildBottomButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue() ? () {
                  if (_currentStep < 3) {
                    _nextStep();
                  } else {
                    _saveEntry();
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getButtonText(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (_currentStep == 1) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _nextStep,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canContinue() {
    if (_currentStep == 0) {
      return _moodRating > 0;
    }
    return true;
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
      case 1:
        return 'Continue';
      case 2:
        return 'Save & Continue';
      case 3:
        return 'View Timeline';
      default:
        return 'Continue';
    }
  }
}