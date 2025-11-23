import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/storage_service.dart';

class EntriesProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  List<MoodEntry> _entries = [];
  bool _isLoading = false;

  List<MoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  int get totalEntries => _entries.length;
  bool get hasEntries => _entries.isNotEmpty;

  // Getters calculés
  MoodEntry? get todayEntry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      return _entries.firstWhere(
        (entry) {
          final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
          return entryDate.isAtSameMomentAs(today);
        },
      );
    } catch (e) {
      return null;
    }
  }

  int get currentStreak {
    if (_entries.isEmpty) return 0;

    final now = DateTime.now();
    var streak = 0;
    var checkDate = DateTime(now.year, now.month, now.day);

    final hasToday = _entries.any((e) {
      final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
      return entryDate.isAtSameMomentAs(checkDate);
    });

    if (!hasToday) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final hasEntry = _entries.any((e) {
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

  double get averageMoodThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weekEntries = _entries.where((entry) {
      return entry.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             entry.date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    if (weekEntries.isEmpty) return 0.0;

    final totalMood = weekEntries.fold<int>(0, (sum, entry) => sum + entry.moodScore);
    return totalMood / weekEntries.length;
  }

  /// Load all entries from storage
  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = _storage.getAllEntries();
      print('✅ Loaded ${_entries.length} entries');
    } catch (e) {
      print('❌ Error loading entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new entry
  Future<void> addEntry(MoodEntry entry) async {
    try {
      await _storage.saveEntry(entry);
      await loadEntries(); // Reload to update UI
      print('✅ Entry added and reloaded');
    } catch (e) {
      print('❌ Error adding entry: $e');
      rethrow;
    }
  }

  /// Delete an entry
  Future<void> deleteEntry(String id) async {
    try {
      await _storage.deleteEntry(id);
      await loadEntries(); // Reload to update UI
      print('✅ Entry deleted and reloaded');
    } catch (e) {
      print('❌ Error deleting entry: $e');
      rethrow;
    }
  }

  /// Delete all entries
  Future<void> deleteAllEntries() async {
    try {
      await _storage.deleteAllEntries();
      await loadEntries(); // Reload to update UI
      print('✅ All entries deleted and reloaded');
    } catch (e) {
      print('❌ Error deleting all entries: $e');
      rethrow;
    }
  }

  /// Update an existing entry
  Future<void> updateEntry(MoodEntry entry) async {
    try {
      await _storage.updateEntry(entry);
      await loadEntries(); // Reload to update UI
      print('✅ Entry updated and reloaded');
    } catch (e) {
      print('❌ Error updating entry: $e');
      rethrow;
    }
  }
}