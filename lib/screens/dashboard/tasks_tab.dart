import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../forms/crm_forms.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final tasks = appState.tasks;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => showTaskDialog(context, appState),
            icon: const Icon(Icons.add_task),
            label: const Text('Добавить задачу'),
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? const EmptyState(message: 'Задачи еще не созданы.')
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemBuilder: (context, index) => TaskCard(
                    task: tasks[index],
                    onToggle: () => appState.toggleTask(tasks[index].id),
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemCount: tasks.length,
                ),
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onToggle});

  final CrmTask task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final priorityColor = task.priority.color;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Checkbox(value: task.isDone, onChanged: (_) => onToggle()),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(task.description!),
            Text(
              'До ${formatReadableDate(task.dueDate)} • ${task.priority.label}',
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            task.isDone ? 'Готово' : 'В работе',
            style: TextStyle(
              color: priorityColor.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
