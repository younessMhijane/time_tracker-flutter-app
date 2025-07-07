import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectTaskProvider with ChangeNotifier {
  final LocalStorage projectStorage;
  final LocalStorage taskStorage;

  List<Project> _projects = [];
  List<Task> _tasks = [];

  ProjectTaskProvider({
    required this.projectStorage,
    required this.taskStorage,
  }) {
    loadData();
  }

  List<Project> get projects => List.unmodifiable(_projects);
  List<Task> get tasks => List.unmodifiable(_tasks);

  void loadData() {
    _projects = (projectStorage.getItem('projects') as List? ?? [])
        .map((item) => Project.fromJson(item))
        .toList();
    _tasks = (taskStorage.getItem('tasks') as List? ?? [])
        .map((item) => Task.fromJson(item))
        .toList();
    notifyListeners();
  }

  void _saveData(LocalStorage storage, String key, List<dynamic> data) {
    storage.setItem(key, data.map((e) => e.toJson()).toList());
  }

  void addProject(Project project) {
    _projects.add(project);
    _saveData(projectStorage, 'projects', _projects);
    notifyListeners();
  }

  void updateProject(Project updatedProject) {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      _saveData(projectStorage, 'projects', _projects);
      notifyListeners();
    }
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    _tasks.removeWhere((t) => t.projectId == id);
    _saveData(projectStorage, 'projects', _projects);
    _saveData(taskStorage, 'tasks', _tasks);
    notifyListeners();
  }

  // Même logique pour les tâches
  void addTask(Task task) {
    _tasks.add(task);
    _saveData(taskStorage, 'tasks', _tasks);
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveData(taskStorage, 'tasks', _tasks);
    notifyListeners();
  }
}
