import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import 'clients_tab.dart';
import 'deals_tab.dart';
import 'notes_tab.dart';
import 'overview_tab.dart';
import 'tasks_tab.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key, required this.appState});

  final AppState appState;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      OverviewTab(appState: widget.appState),
      NotesTab(appState: widget.appState),
      TasksTab(appState: widget.appState),
      ClientsTab(appState: widget.appState),
      DealsTab(appState: widget.appState),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_currentIndex)),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: widget.appState.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Обзор',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            label: 'Заметки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl),
            label: 'Задачи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Клиенты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            label: 'Сделки',
          ),
        ],
      ),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Заметки';
      case 2:
        return 'Задачи';
      case 3:
        return 'Клиенты';
      case 4:
        return 'Сделки';
      default:
        return 'Главная';
    }
  }
}
