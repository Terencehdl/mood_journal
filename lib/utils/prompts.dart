class Prompts {
  static String getPromptForMood(int mood, List<String> emotions) {
    switch (mood) {
      case 5:
        return "What made you smile today? 😊";
      case 4:
        return "What's one thing you're grateful for today?";
      case 3:
        return "How could you make tomorrow better?";
      case 2:
        if (emotions.contains('anxious')) {
          return "What's weighing on your mind right now?";
        }
        return "What's been challenging today?";
      case 1:
        return "It's okay to have tough days. What do you need right now?";
      default:
        return "How are you feeling? Tell me about your day.";
    }
  }
  
  static String getEncouragement(int entryCount) {
    if (entryCount == 0) {
      return "Great start! Come back tomorrow.";
    } else if (entryCount == 6) {
      return "7 days strong! You're building a habit.";
    } else if (entryCount == 29) {
      return "30 days! You're incredible.";
    } else {
      return "Keep going! You're doing great.";
    }
  }
}