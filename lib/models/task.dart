class SystemTask {
  String id;
  String title;
  String statType;
  int xpReward;
  bool isCompleted;

  SystemTask({
    required this.id,
    required this.title,
    required this.statType,
    this.xpReward = 10,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'stat_type': statType,
        'xp_reward': xpReward,
        'is_completed': isCompleted,
      };

  factory SystemTask.fromJson(Map<String, dynamic> json) {
    return SystemTask(
      id: json['id'],
      title: json['title'],
      statType: json['stat_type'],
      xpReward: json['xp_reward'] ?? 10,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}