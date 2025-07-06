import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/project_task_provider.dart';

class ProjectTaskManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gestion des Projets et Tâches'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.work)), 
              Tab(icon: Icon(Icons.task)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Aide'),
                    content: Text('Ajoutez et gérez vos projets et tâches ici'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
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
  @override
  _ProjectsTabState createState() => _ProjectsTabState();
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du projet',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer un nom' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (optionnelle)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Ajouter Projet'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          provider.addProject(Project(
                            id: DateTime.now().toString(),
                            name: _nameController.text,
                            description: _descriptionController.text,
                          ));
                          _nameController.clear();
                          _descriptionController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: provider.projects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline, size: 64, color: Colors.grey),
                        Text(
                          'Aucun projet créé',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.projects.length,
                    itemBuilder: (context, index) {
                      final project = provider.projects[index];
                      return Dismissible(
                        key: Key(project.id),
                        background: Container(color: Colors.red),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Confirmer'),
                              content: Text(
                                  'Supprimer ce projet et toutes ses tâches associées ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Supprimer'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          provider.deleteProject(project.id);
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(project.name[0].toUpperCase()),
                            ),
                            title: Text(
                              project.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: project.description.isNotEmpty
                                ? Text(project.description)
                                : null,
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Confirmer'),
                                    content: Text(
                                        'Supprimer ce projet et toutes ses tâches associées ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          provider.deleteProject(project.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: Text('Supprimer'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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
}

class TasksTab extends StatefulWidget {
  @override
  _TasksTabState createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedProjectId = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedProjectId.isEmpty ? null : _selectedProjectId,
                      decoration: InputDecoration(
                        labelText: 'Projet associé',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.projects
                          .map<DropdownMenuItem<String>>((project) {
                        return DropdownMenuItem<String>(
                          value: project.id,
                          child: Text(project.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value ?? '';
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Veuillez sélectionner un projet' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom de la tâche',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer un nom' : null,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Ajouter Tâche'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          provider.addTask(Task(
                            id: DateTime.now().toString(),
                            name: _nameController.text,
                            projectId: _selectedProjectId,
                          ));
                          _nameController.clear();
                          _selectedProjectId = '';
                          _formKey.currentState!.reset();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: provider.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_outlined, size: 64, color: Colors.grey),
                        Text(
                          'Aucune tâche créée',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = provider.tasks[index];
                      final project = provider.projects.firstWhere(
                        (p) => p.id == task.projectId,
                        orElse: () => Project(id: '', name: 'Projet supprimé'),
                      );

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: false,
                            onChanged: (value) {},
                          ),
                          title: Text(task.name),
                          subtitle: Text(
                            'Projet: ${project.name}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Confirmer'),
                                  content: Text('Supprimer cette tâche ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        provider.deleteTask(task.id);
                                        Navigator.pop(ctx);
                                      },
                                      child: Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );
                            },
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
}