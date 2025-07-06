import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/time_entry.dart';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage storage;
  List<TimeEntry> _entries = [];

  TimeEntryProvider({required this.storage});

  List<TimeEntry> get entries => _entries;

  void loadData() {
    _entries = (storage.getItem('entries') as List? ?? [])
        .map((item) => TimeEntry.fromJson(item))
        .toList();
    notifyListeners();
  }

  void _saveEntries() {
    storage.setItem('entries', _entries.map((e) => e.toJson()).toList());
  }

  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveEntries();
    notifyListeners();
  }

  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveEntries();
    notifyListeners();
  }
}