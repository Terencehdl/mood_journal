import 'package:hive/hive.dart';

part 'mood_entry.g.dart'; // Pour Hive code generation

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime date;
  
  @HiveField(2)
  final int moodScore; // 1-5
  
  @HiveField(3)
  final List<String> emotions;
  
  @HiveField(4)
  final String journalText;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  DateTime updatedAt;

  MoodEntry({
    required this.id,
    required this.date,
    required this.moodScore,
    required this.emotions,
    required this.journalText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MoodEntry.create({
    required int moodScore,
    required List<String> emotions,
    required String journalText,
  }) {
    final now = DateTime.now();
    return MoodEntry(
      id: now.millisecondsSinceEpoch.toString(),
      date: now,
      moodScore: moodScore,
      emotions: emotions,
      journalText: journalText,
      createdAt: now,
      updatedAt: now,
    );
  }

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    int? moodScore,
    List<String>? emotions,
    String? journalText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodScore: moodScore ?? this.moodScore,
      emotions: emotions ?? this.emotions,
      journalText: journalText ?? this.journalText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}