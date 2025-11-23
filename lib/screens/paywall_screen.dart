import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final StorageService _storage = StorageService();
  String? _selectedProduct;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),
            
            // Content scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Hero section
                    const Text('💎', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 24),
                    Text(
                      'Unlock Premium Insights',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get deeper understanding of your emotional patterns',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Features list
                    _buildFeaturesList(isDark),
                    const SizedBox(height: 40),
                    
                    // Products
                    _buildProductCard(
                      id: 'insights_pack',
                      emoji: '💎',
                      title: 'Insights AI Pack',
                      price: '7,99€',
                      subtitle: 'One-time purchase',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildProductCard(
                      id: 'premium_bundle',
                      emoji: '⭐',
                      title: 'Premium Bundle',
                      price: '9,99€',
                      subtitle: 'Everything unlocked',
                      badge: 'BEST VALUE',
                      isRecommended: true,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    
                    // Subscription option
                    _buildSubscriptionOption(isDark),
                    const SizedBox(height: 24),
                    
                    // Social proof
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        )),
                        const SizedBox(width: 8),
                        Text(
                          '4.9/5 (1,234 reviews)',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom section
            _buildBottomSection(isDark),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Balance le close button
          Text(
            'Upgrade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    final features = [
      'Advanced AI Insights',
      'Unlimited history',
      '100+ guided prompts',
      'Export to PDF',
      'Custom themes',
      'Priority support',
    ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.mint,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildProductCard({
    required String id,
    required String emoji,
    required String title,
    required String price,
    required String subtitle,
    String? badge,
    bool isRecommended = false,
    required bool isDark,
  }) {
    final isSelected = _selectedProduct == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProduct = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isRecommended
            ? AppColors.primary.withOpacity(0.1)
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? AppColors.primary 
              : (isRecommended 
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border.withOpacity(0.3)),
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Stack(
          children: [
            // Badge
            if (badge != null)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOption(bool isDark) {
    return Column(
      children: [
        Text(
          'Or subscribe:',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedProduct = 'subscription';
            });
          },
          child: Text(
            '3,99€/month • Cancel anytime',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(bool isDark) {
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
                onPressed: _selectedProduct != null ? _handlePurchase : null,
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
                  _selectedProduct == null 
                    ? 'Select a plan'
                    : 'Continue',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
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
    );
  }

  Future<void> _handlePurchase() async {
    // Simulation d'achat (dans la vraie app : RevenueCat)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Save premium status
    await _storage.setPremium(true);

    if (mounted) {
      Navigator.pop(context); // Close loading
      
      // Show success
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🎉 Success!'),
          content: const Text('Welcome to MoodJournal Premium!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Close paywall with result
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      );
    }
  }
}