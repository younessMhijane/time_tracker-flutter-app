class Project {
  final String id;
  final String name;
  final String description;

  Project({
    required this.id,
    required this.name,
    this.description = '',
  });
}