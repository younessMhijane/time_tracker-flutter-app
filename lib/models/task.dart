class Task {
  final String id;
  final String name;
  final String projectId;

  const Task({
    required this.id,
    required this.name,
    required this.projectId,
  });

  Task copyWith({
    String? id,
    String? name,
    String? projectId,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      projectId: projectId ?? this.projectId,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        name: json['name'],
        projectId: json['projectId'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'projectId': projectId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          projectId == other.projectId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ projectId.hashCode;
}
