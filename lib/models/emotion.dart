enum EmotionCategory { positive, negative, neutral }

class Emotion {
  final String id;
  final String emoji;
  final String label;
  final EmotionCategory category;

  const Emotion({
    required this.id,
    required this.emoji,
    required this.label,
    required this.category,
  });

  static const List<Emotion> allEmotions = [
    // Positive
    Emotion(id: 'happy', emoji: '😊', label: 'Happy', category: EmotionCategory.positive),
    Emotion(id: 'loved', emoji: '❤️', label: 'Loved', category: EmotionCategory.positive),
    Emotion(id: 'excited', emoji: '🎉', label: 'Excited', category: EmotionCategory.positive),
    Emotion(id: 'peaceful', emoji: '😌', label: 'Peaceful', category: EmotionCategory.positive),
    Emotion(id: 'grateful', emoji: '🤗', label: 'Grateful', category: EmotionCategory.positive),
    Emotion(id: 'confident', emoji: '💪', label: 'Confident', category: EmotionCategory.positive),
    
    // Negative
    Emotion(id: 'sad', emoji: '😔', label: 'Sad', category: EmotionCategory.negative),
    Emotion(id: 'anxious', emoji: '😰', label: 'Anxious', category: EmotionCategory.negative),
    Emotion(id: 'angry', emoji: '😡', label: 'Angry', category: EmotionCategory.negative),
    Emotion(id: 'tired', emoji: '😩', label: 'Tired', category: EmotionCategory.negative),
    Emotion(id: 'worried', emoji: '😟', label: 'Worried', category: EmotionCategory.negative),
    Emotion(id: 'lonely', emoji: '😞', label: 'Lonely', category: EmotionCategory.negative),
    
    // Neutral
    Emotion(id: 'neutral', emoji: '😐', label: 'Neutral', category: EmotionCategory.neutral),
    Emotion(id: 'thoughtful', emoji: '🤔', label: 'Thoughtful', category: EmotionCategory.neutral),
  ];

  static Emotion? findById(String id) {
    try {
      return allEmotions.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Emotion> getByCategory(EmotionCategory category) {
    return allEmotions.where((e) => e.category == category).toList();
  }
}