import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/time_entry.dart';
import '../providers/time_entry_provider.dart';
import '../providers/project_task_provider.dart';
import 'add_time_entry_screen.dart';
import 'project_task_management_screen.dart';
import '../models/project.dart';
import '../models/task.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Time Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gérer projets et tâches',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectTaskManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, _) {
          if (provider.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune entrée trouvée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appuyez sur le bouton + pour en ajouter',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.entries.length,
            itemBuilder: (context, index) {
              final entry = provider.entries[index];
              final project = projectProvider.projects.firstWhere(
                (p) => p.id == entry.projectId,
                orElse: () => Project(id: '', name: 'Projet inconnu'),
              );
              final task = projectProvider.tasks.firstWhere(
                (t) => t.id == entry.taskId,
                orElse: () => Task(id: '', name: 'Tâche inconnue', projectId: ''),
              );

              return Dismissible(
                key: ValueKey(entry.id),
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  provider.deleteTimeEntry(entry.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Entrée supprimée')),
                  );
                },
                child: TimeEntryCard(entry: entry, project: project, task: task),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  AddTimeEntryScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class TimeEntryCard extends StatelessWidget {
  final TimeEntry entry;
  final Project project;
  final Task task;

  const TimeEntryCard({
    super.key,
    required this.entry,
    required this.project,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          child: Text(
            '${entry.totalTime}h',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${project.name} - ${task.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd/MM/yyyy HH:mm').format(entry.date)),
            if (entry.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  entry.notes,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Tu peux ajouter ici une navigation pour voir ou modifier l’entrée
        },
      ),
    );
  }
}
