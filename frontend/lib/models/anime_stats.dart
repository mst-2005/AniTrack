class WatchStats {
  final int watching;
  final int completed;
  final int onHold;
  final int planToWatch;

  WatchStats({
    required this.watching,
    required this.completed,
    required this.onHold,
    required this.planToWatch,
  });

  factory WatchStats.fromJson(Map<String, dynamic> json) {
    return WatchStats(
      watching: json['watching'] ?? 0,
      completed: json['completed'] ?? 0,
      onHold: json['onHold'] ?? 0,
      planToWatch: json['planToWatch'] ?? 0,
    );
  }
}
