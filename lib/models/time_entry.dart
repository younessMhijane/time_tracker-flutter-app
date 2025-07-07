class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final double totalTime;
  final DateTime date;
  final String notes;

  const TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalTime,
    required this.date,
    required this.notes,
  });

  TimeEntry copyWith({
    String? id,
    String? projectId,
    String? taskId,
    double? totalTime,
    DateTime? date,
    String? notes,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      totalTime: totalTime ?? this.totalTime,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) => TimeEntry(
        id: json['id'],
        projectId: json['projectId'],
        taskId: json['taskId'],
        totalTime: (json['totalTime'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'taskId': taskId,
        'totalTime': totalTime,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          projectId == other.projectId &&
          taskId == other.taskId &&
          totalTime == other.totalTime &&
          date == other.date &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      projectId.hashCode ^
      taskId.hashCode ^
      totalTime.hashCode ^
      date.hashCode ^
      notes.hashCode;
}
