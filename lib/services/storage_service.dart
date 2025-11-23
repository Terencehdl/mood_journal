import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _boxName = 'mood_entries';
  static const String _settingsBoxName = 'settings';
  
  late Box<MoodEntry> _box;
  late Box _settingsBox;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MoodEntryAdapter());
    }

    // Open boxes
    _box = await Hive.openBox<MoodEntry>(_boxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    
    print('✅ Hive initialized: ${_box.length} entries loaded');
  }

  // ==================== ENTRIES METHODS ====================

  /// Save a mood entry
  Future<void> saveEntry(MoodEntry entry) async {
    try {
      await _box.put(entry.id, entry);
      print('✅ Entry saved: ${entry.id}');
    } catch (e) {
      print('❌ Error saving entry: $e');
      rethrow;
    }
  }

  /// Get all entries sorted by date (newest first)
  List<MoodEntry> getAllEntries() {
    try {
      final entries = _box.values.toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (e) {
      print('❌ Error getting entries: $e');
      return [];
    }
  }

  /// Get entry by ID
  MoodEntry? getEntry(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      print('❌ Error getting entry: $e');
      return null;
    }
  }

  /// Delete an entry
  Future<void> deleteEntry(String id) async {
    try {
      await _box.delete(id);
      print('✅ Entry deleted: $id');
    } catch (e) {
      print('❌ Error deleting entry: $e');
      rethrow;
    }
  }

  /// Delete all entries (used in Settings > Delete All Data)
  Future<void> deleteAllEntries() async {
    try {
      await _box.clear();
      print('✅ All entries deleted');
    } catch (e) {
      print('❌ Error deleting all entries: $e');
      rethrow;
    }
  }

  /// Update an existing entry
  Future<void> updateEntry(MoodEntry entry) async {
    try {
      await _box.put(entry.id, entry);
      print('✅ Entry updated: ${entry.id}');
    } catch (e) {
      print('❌ Error updating entry: $e');
      rethrow;
    }
  }

  /// Get entries for a specific date range
  List<MoodEntry> getEntriesInRange(DateTime start, DateTime end) {
    try {
      final entries = _box.values.where((entry) {
        return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
               entry.date.isBefore(end.add(const Duration(days: 1)));
      }).toList();
      
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (e) {
      print('❌ Error getting entries in range: $e');
      return [];
    }
  }

  // ==================== ENTRIES GETTERS ====================

  /// Get total number of entries
  int get totalEntries => _box.length;

  /// Check if there are any entries
  bool get hasEntries => _box.isNotEmpty;

  /// Get today's entry (if exists)
  MoodEntry? get todayEntry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      return _box.values.firstWhere(
        (entry) {
          final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
          return entryDate.isAtSameMomentAs(today);
        },
      );
    } catch (e) {
      return null;
    }
  }

  /// Get current streak (consecutive days with entries)
  int get currentStreak {
    if (_box.isEmpty) return 0;

    final entries = getAllEntries();
    final now = DateTime.now();
    var streak = 0;
    var checkDate = DateTime(now.year, now.month, now.day);

    // Check if there's an entry today, if not, start from yesterday
    final hasToday = entries.any((e) {
      final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
      return entryDate.isAtSameMomentAs(checkDate);
    });

    if (!hasToday) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Count consecutive days
    while (true) {
      final hasEntry = entries.any((e) {
        final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
        return entryDate.isAtSameMomentAs(checkDate);
      });

      if (hasEntry) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get average mood for this week
  double get averageMoodThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weekEntries = getEntriesInRange(weekStart, weekEnd);

    if (weekEntries.isEmpty) return 0.0;

    final totalMood = weekEntries.fold<int>(0, (sum, entry) => sum + entry.moodScore);
    return totalMood / weekEntries.length;
  }

  // ==================== SETTINGS METHODS ====================

  /// Get dark mode setting
  bool get isDarkMode => _settingsBox.get('darkMode', defaultValue: false);

  /// Set dark mode
  Future<void> setDarkMode(bool value) async {
    await _settingsBox.put('darkMode', value);
  }

  /// Get onboarding completed status
  bool get hasCompletedOnboarding => _settingsBox.get('onboardingCompleted', defaultValue: false);

  /// Set onboarding completed
  Future<void> setOnboardingCompleted(bool value) async {
    await _settingsBox.put('onboardingCompleted', value);
  }

  /// Get notification time
  String get notificationTime => _settingsBox.get('notificationTime', defaultValue: '21:00');

  /// Set notification time (also called setReminderTime for compatibility)
  Future<void> setNotificationTime(String value) async {
    await _settingsBox.put('notificationTime', value);
  }

  /// Alias for setNotificationTime (for compatibility)
  Future<void> setReminderTime(String value) async {
    await setNotificationTime(value);
  }

  /// Get notifications enabled status
  bool get notificationsEnabled => _settingsBox.get('notificationsEnabled', defaultValue: true);

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool value) async {
    await _settingsBox.put('notificationsEnabled', value);
  }

  /// Get premium status
  bool get isPremium => _settingsBox.get('isPremium', defaultValue: false);

  /// Set premium status
  Future<void> setPremium(bool value) async {
    await _settingsBox.put('isPremium', value);
  }

  /// Close boxes (call on app dispose)
  Future<void> close() async {
    await _box.close();
    await _settingsBox.close();
  }
}