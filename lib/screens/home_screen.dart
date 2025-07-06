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
  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi du Temps'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
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
        builder: (context, provider, child) {
          if (provider.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune entrée de temps',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  Text(
                    'Appuyez sur le bouton + pour ajouter une entrée',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
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

return Card(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () {
      // Option: Ajouter une action quand on clique sur une entrée
    },
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                child: Text(
                  '${entry.totalTime}h',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${project.name} - ${task.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red[300]),
                onPressed: () {
                  _showDeleteDialog(context, provider, entry.id);
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(entry.date),
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (entry.notes.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              entry.notes,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ],
      ),
    ),
  ),
);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Ajouter une entrée',
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TimeEntryProvider provider, String entryId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer cette entrée ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTimeEntry(entryId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Entrée supprimée')),
              );
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}