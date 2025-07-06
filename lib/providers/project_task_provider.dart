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
  });

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  void loadData() {
    _projects = (projectStorage.getItem('projects') as List? ?? [])
        .map((item) => Project.fromJson(item))
        .toList();
    
    _tasks = (taskStorage.getItem('tasks') as List? ?? [])
        .map((item) => Task.fromJson(item))
        .toList();
    
    notifyListeners();
  }

  void _saveProjects() {
    projectStorage.setItem('projects', _projects.map((p) => p.toJson()).toList());
  }

  void _saveTasks() {
    taskStorage.setItem('tasks', _tasks.map((t) => t.toJson()).toList());
  }

  void addProject(Project project) {
    _projects.add(project);
    _saveProjects();
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    _tasks.removeWhere((task) => task.projectId == id);
    _saveProjects();
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _saveTasks();
    notifyListeners();
  }
}