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
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime _selectedDate = DateTime.now();

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
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
        title: const Text(
          'Nouvelle Entrée',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_kDefaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdownCard(
                context,
                title: 'Projet',
                icon: Icons.work_outline,
                value: _selectedProjectId,
                items: projectTaskProvider.projects
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                    _selectedTaskId = null;
                  });
                },
                validator: (value) => value == null ? 'Sélectionnez un projet' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownCard(
                context,
                title: 'Tâche',
                icon: Icons.task_alt,
                value: _selectedTaskId,
                items: filteredTasks
                    .map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTaskId = value;
                  });
                },
                validator: (value) => value == null ? 'Sélectionnez une tâche' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFieldCard(
                controller: _timeController,
                title: 'Durée (heures)',
                icon: Icons.timer_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une durée';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Entrez un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateTimeCard(context),
              const SizedBox(height: 16),
              _buildNotesCard(),
              const SizedBox(height: 24),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kCardRadius)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(_kDefaultPadding),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: title,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildTextFieldCard({
    required TextEditingController controller,
    required String title,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kCardRadius)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(_kDefaultPadding),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDateTimeCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kCardRadius)),
      elevation: 2,
      child: InkWell(
        onTap: () => _selectDateTime(context),
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: Padding(
          padding: const EdgeInsets.all(_kDefaultPadding),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kCardRadius)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(_kDefaultPadding),
        child: TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (optionnel)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.notes_outlined),
          ),
          maxLines: 3,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          final timeEntry = TimeEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            projectId: _selectedProjectId!,
            taskId: _selectedTaskId!,
            totalTime: double.parse(_timeController.text),
            date: _selectedDate,
            notes: _notesController.text,
          );

          Provider.of<TimeEntryProvider>(context, listen: false).addTimeEntry(timeEntry);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entrée ajoutée avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }
      },
      icon: const Icon(Icons.check_circle_outline),
      label: const Text('ENREGISTRER', style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kButtonRadius)),
      ),
    );
  }
}
