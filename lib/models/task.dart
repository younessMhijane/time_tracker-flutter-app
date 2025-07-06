class Task {
  final String id;
  final String name;
  final String projectId;

  Task({
    required this.id,
    required this.name,
    required this.projectId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      projectId: json['projectId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'projectId': projectId,
    };
  }
}