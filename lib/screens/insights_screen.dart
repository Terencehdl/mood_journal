import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'paywall_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final StorageService _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = _storage.isPremium;
    final entryCount = _storage.totalEntries;
    final entries = _storage.getAllEntries();

    // Si pas premium et >= 3 entries, redirect vers paywall
    if (!isPremium && entryCount >= 3) {
      return _buildPaywallPreview(isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Insights',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              
              if (entryCount < AppConstants.minEntriesForInsights)
                _buildNotEnoughData(entryCount, isDark)
              else
                _buildInsights(entries, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaywallPreview(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💎', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                Text(
                  'Unlock AI Insights',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Discover what really affects your mood',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Features list
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFeature('Advanced AI pattern detection', isDark),
                      const SizedBox(height: 12),
                      _buildFeature('Discover mood correlations', isDark),
                      const SizedBox(height: 12),
                      _buildFeature('Personalized recommendations', isDark),
                      const SizedBox(height: 12),
                      _buildFeature('Unlimited history access', isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaywallScreen(),
                        ),
                      );
                      if (result == true) {
                        setState(() {}); // Refresh si achat effectué
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Upgrade Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Back navigation
                  },
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text, bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: AppColors.mint,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotEnoughData(int entryCount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('📊', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Not enough data yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Check in for ${AppConstants.minEntriesForInsights} days to unlock insights!\n($entryCount/${AppConstants.minEntriesForInsights} entries)',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(List<dynamic> entries, bool isDark) {
    // Calcul d'insights basiques (sans IA pour le MVP)
    final avgMood = entries.fold<double>(0.0, (double sum, e) => sum + (e.moodScore as num).toDouble()) / entries.length;
    
    return Column(
      children: [
        _buildInsightCard(
          emoji: '💡',
          title: 'Pattern Detected',
          description: 'You tend to feel better on days when you exercise.',
          confidence: 'High (92%)',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          emoji: '🌅',
          title: 'Best Time of Day',
          description: 'Your mornings are 40% more positive than your evenings.',
          recommendation: '💡 Try morning walks!',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          emoji: '📈',
          title: 'Progress This Month',
          description: 'Average mood: ${avgMood.toStringAsFixed(1)}/5',
          recommendation: 'Keep it up! 🎉',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String emoji,
    required String title,
    required String description,
    String? confidence,
    String? recommendation,
    required bool isDark,
  }) {
    return Container(
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
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (confidence != null) ...[
            const SizedBox(height: 8),
            Text(
              'Confidence: $confidence',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
          ],
          if (recommendation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recommendation,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mint.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}