import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/project_task_provider.dart';

class ProjectTaskManagementScreen extends StatelessWidget {
  const ProjectTaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Gestion Projets & Tâches',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.work_outline), text: 'Projets'),
              Tab(icon: Icon(Icons.task_alt), text: 'Tâches'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Aide'),
                    content: const Text('Ajoutez et gérez vos projets et tâches ici.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            ProjectsTab(),
            TasksTab(),
          ],
        ),
      ),
    );
  }
}

class ProjectsTab extends StatefulWidget {
  const ProjectsTab({super.key});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addProject(ProjectTaskProvider provider) {
    if (_formKey.currentState!.validate()) {
      provider.addProject(Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
      ));
      _nameController.clear();
      _descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projet ajouté')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildForm(context, provider),
          const SizedBox(height: 16),
          Expanded(
            child: provider.projects.isEmpty
                ? _buildEmptyState('Aucun projet créé', Icons.work_outline)
                : ListView.builder(
                    itemCount: provider.projects.length,
                    itemBuilder: (context, index) {
                      final project = provider.projects[index];
                      return Dismissible(
                        key: Key(project.id),
                        background: _buildDismissBackground(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          provider.deleteProject(project.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Projet supprimé')),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              child: Text(
                                project.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              project.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: project.description.isNotEmpty
                                ? Text(project.description)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, ProjectTaskProvider provider) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du projet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un nom' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter Projet'),
                onPressed: () => _addProject(provider),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      color: Colors.redAccent,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 30),
    );
  }
}

// 🟣 TasksTab : Même refacto avec Dropdown pro + swipe
class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedProjectId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addTask(ProjectTaskProvider provider) {
    if (_formKey.currentState!.validate()) {
      provider.addTask(Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        projectId: _selectedProjectId!,
      ));
      _nameController.clear();
      _selectedProjectId = null;
      _formKey.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâche ajoutée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildForm(context, provider),
          const SizedBox(height: 16),
          Expanded(
            child: provider.tasks.isEmpty
                ? _buildEmptyState('Aucune tâche créée', Icons.task_alt_outlined)
                : ListView.builder(
                    itemCount: provider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = provider.tasks[index];
                      final project = provider.projects.firstWhere(
                        (p) => p.id == task.projectId,
                        orElse: () => Project(id: '', name: 'Projet supprimé'),
                      );

                      return Dismissible(
                        key: Key(task.id),
                        background: _buildDismissBackground(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          provider.deleteTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tâche supprimée')),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.task_alt, color: Colors.blueAccent),
                            title: Text(task.name),
                            subtitle: Text('Projet: ${project.name}'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, ProjectTaskProvider provider) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedProjectId,
                decoration: const InputDecoration(
                  labelText: 'Projet associé',
                  border: OutlineInputBorder(),
                ),
                items: provider.projects
                    .map((project) => DropdownMenuItem<String>(
                          value: project.id,
                          child: Text(project.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un projet' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la tâche',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un nom' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter Tâche'),
                onPressed: () => _addTask(provider),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      color: Colors.redAccent,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 30),
    );
  }
}
