import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/time_entry_provider.dart';
import '../providers/project_task_provider.dart';
const _kDefaultPadding = 16.0;
const _kCardRadius = 12.0;
const _kButtonRadius = 10.0;
class AddTimeEntryScreen extends StatefulWidget {
  @override
  _AddTimeEntryScreenState createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectTaskProvider = Provider.of<ProjectTaskProvider>(context);
    final filteredTasks = _selectedProjectId != null
        ? projectTaskProvider.tasks.where((task) => task.projectId == _selectedProjectId).toList()
        : <Task>[];

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle Entrée', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_kCardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_kDefaultPadding),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedProjectId,
                        decoration: InputDecoration(
                          labelText: 'Projet',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        items: projectTaskProvider.projects
                            .map<DropdownMenuItem<String>>((project) {
                          return DropdownMenuItem<String>(
                            value: project.id,
                            child: Text(
                              project.name,
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProjectId = value;
                            _selectedTaskId = null; // Reset task when project changes
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Veuillez sélectionner un projet' : null,
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedTaskId,
                        decoration: InputDecoration(
                          labelText: 'Tâche',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.task),
                        ),
                        items: filteredTasks
                            .map<DropdownMenuItem<String>>((task) {
                          return DropdownMenuItem<String>(
                            value: task.id,
                            child: Text(
                              task.name,
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTaskId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Veuillez sélectionner une tâche' : null,
                        disabledHint: Text(
                          _selectedProjectId == null 
                              ? 'Sélectionnez d\'abord un projet'
                              : 'Aucune tâche disponible',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_kCardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_kDefaultPadding),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Durée (heures)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une durée';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () => _selectDateTime(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date et heure',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate),
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_kCardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_kDefaultPadding),
                  child: TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (optionnel)',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kButtonRadius),
                  ),
                
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final timeEntry = TimeEntry(
                      id: DateTime.now().toString(),
                      projectId: _selectedProjectId!,
                      taskId: _selectedTaskId!,
                      totalTime: double.parse(_timeController.text),
                      date: _selectedDate,
                      notes: _notesController.text,
                    );
                    
                    Provider.of<TimeEntryProvider>(context, listen: false)
                        .addTimeEntry(timeEntry);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Entrée ajoutée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'ENREGISTRER',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}