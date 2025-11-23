import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../providers/theme_provider.dart';
import '../providers/entries_provider.dart';
import '../utils/constants.dart';
import '../screens/paywall_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  bool isPremium = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),

                // Appearance
                _buildSection(
                  title: 'Appearance',
                  isDark: isDark,
                  children: [
                    _buildSettingTile(
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
                      title: 'Dark Mode',
                      subtitle: isDark ? 'Enabled' : 'Disabled',
                      isDark: isDark,
                      trailing: Switch(
                        value: isDark,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Notifications
                _buildSection(
                  title: 'Notifications',
                  isDark: isDark,
                  children: [
                    _buildSettingTile(
                      icon: Icons.notifications_outlined,
                      title: 'Daily Reminder',
                      subtitle: _storage.notificationsEnabled ? 'At ${_storage.notificationTime}' : 'Disabled',
                      isDark: isDark,
                      trailing: Switch(
                        value: _storage.notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _storage.setNotificationsEnabled(value);
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                    if (_storage.notificationsEnabled) ...[
                      _buildDivider(isDark),
                      _buildSettingTile(
                        icon: Icons.schedule_outlined,
                        title: 'Reminder Time',
                        subtitle: _storage.notificationTime,
                        isDark: isDark,
                        onTap: () {
                          _showTimePicker();
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Privacy & Data
                _buildSection(
                  title: 'Privacy & Data',
                  isDark: isDark,
                  children: [
                    _buildSettingTile(
                      icon: Icons.lock_outline,
                      title: 'App Lock',
                      subtitle: 'Face ID / Touch ID',
                      isDark: isDark,
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('App lock coming soon!')),
                          );
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      icon: Icons.download_outlined,
                      title: 'Export My Data',
                      subtitle: 'GDPR compliance',
                      isDark: isDark,
                      onTap: () {
                        _exportData();
                      },
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      icon: Icons.delete_outline,
                      title: 'Delete All Data',
                      isDark: isDark,
                      titleColor: AppColors.coral,
                      onTap: () {
                        _confirmDeleteAllData();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Premium
                _buildSection(
                  title: 'Premium',
                  isDark: isDark,
                  children: [
                    if (isPremium)
                      _buildPremiumActive(isDark)
                    else
                      _buildPremiumUpgrade(isDark),
                  ],
                ),
                const SizedBox(height: 24),

                // Support
                _buildSection(
                  title: 'Support',
                  isDark: isDark,
                  children: [
                    _buildSettingTile(
                      icon: Icons.help_outline,
                      title: 'FAQ',
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('FAQ coming soon!')),
                        );
                      },
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      icon: Icons.email_outlined,
                      title: 'Contact Us',
                      subtitle: 'support@moodjournal.app',
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening email...')),
                        );
                      },
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      icon: Icons.star_outline,
                      title: 'Rate the App',
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening App Store...')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // About
                _buildSection(
                  title: 'About',
                  isDark: isDark,
                  children: [
                    _buildSettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      icon: Icons.info_outline,
                      title: 'App Version',
                      subtitle: 'v1.0.0',
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withOpacity(0.3),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: titleColor ?? AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? (isDark ? Colors.white : AppColors.textPrimary),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                )
              : null),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? Colors.white.withOpacity(0.05) : AppColors.border.withOpacity(0.3),
    );
  }

  Widget _buildPremiumActive(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.mint],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Active',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Thank you for your support!',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumUpgrade(bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.coral, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.diamond, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Unlock AI insights & more',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() async {
    final currentTime = _parseTime(_storage.notificationTime);
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await _storage.setNotificationTime(formattedTime);
      setState(() {});
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDeleteAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.coral, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Delete All Data?')),
          ],
        ),
        content: const Text(
          'This will permanently delete ALL your mood entries, emotions, and journal notes.\n\nThis action cannot be undone.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllData();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    final entriesProvider = Provider.of<EntriesProvider>(context, listen: false);
    
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );

      // Delete all entries via provider
      await entriesProvider.deleteAllEntries();

      // Close loading
      if (mounted) {
        Navigator.pop(context);

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('All data deleted successfully'),
              ],
            ),
            backgroundColor: AppColors.mint,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading on error
      if (mounted) {
        Navigator.pop(context);

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: AppColors.coral,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}