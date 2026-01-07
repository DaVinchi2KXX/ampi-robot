/// Emotion constants for Robot-AmPI
class Emotions {
  static const int happy = 0;
  static const int angry = 1;
  static const int sad = 2;
  static const int surprised = 3;
  static const int love = 4;
  static const int sleepy = 5;

  static const List<EmotionData> all = [
    EmotionData(
      id: happy,
      name: 'Happy',
      icon: '😊',
      description: 'Joyful blinking with rising melody',
    ),
    EmotionData(
      id: angry,
      name: 'Angry',
      icon: '😠',
      description: 'Angry eyebrows with head shake',
    ),
    EmotionData(
      id: sad,
      name: 'Sad',
      icon: '😢',
      description: 'Downcast eyes with head lowering',
    ),
    EmotionData(
      id: surprised,
      name: 'Surprised',
      icon: '😲',
      description: 'Wide eyes with quick head lift',
    ),
    EmotionData(
      id: love,
      name: 'Love',
      icon: '😍',
      description: 'Heart symbols with gentle nodding',
    ),
    EmotionData(
      id: sleepy,
      name: 'Sleepy',
      icon: '😴',
      description: 'Half-closed eyes with slow drooping',
    ),
  ];

  static EmotionData? getEmotion(int id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}

class EmotionData {
  final int id;
  final String name;
  final String icon;
  final String description;

  const EmotionData({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}
