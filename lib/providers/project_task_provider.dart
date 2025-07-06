import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectTaskProvider with ChangeNotifier {
  List<Project> _projects = [];
  List<Task> _tasks = [];

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    // Supprimer aussi les tâches associées
    _tasks.removeWhere((task) => task.projectId == id);
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}