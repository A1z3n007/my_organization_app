import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../forms/crm_forms.dart';
import 'notes_tab.dart';
import 'tasks_tab.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final notes = appState.notes;
    final tasks = appState.tasks;
    final clients = appState.clients;
    final deals = appState.deals;
    final openTasks = tasks.where((task) => !task.isDone).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final latestNotes = notes.take(2).toList();
    final hotDeals = deals.where((deal) => deal.stage != 'Успешно').toList()
      ..sort((a, b) {
        final deadlineA =
            a.deadline ?? DateTime.now().add(const Duration(days: 365));
        final deadlineB =
            b.deadline ?? DateTime.now().add(const Duration(days: 365));
        return deadlineA.compareTo(deadlineB);
      });
    final pipelineAmount = hotDeals.fold<double>(
      0,
      (sum, deal) => sum + deal.amount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user == null ? 'Привет!' : 'Привет, ${user.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Здесь весь твой рабочий день: клиенты, задачи, сделки и заметки.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => showNoteDialog(context, appState),
                        icon: const Icon(Icons.note_add_outlined),
                        label: const Text('Заметка'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => showTaskDialog(context, appState),
                        icon: const Icon(Icons.playlist_add_check),
                        label: const Text('Задача'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => showDealDialog(context, appState),
                        icon: const Icon(Icons.handshake_outlined),
                        label: const Text('Сделка'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Текущий пайплайн: ${pipelineAmount.toStringAsFixed(0)} тг',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              MetricCard(
                title: 'Заметки',
                value: notes.length.toString(),
                subtitle: 'быстрые идеи',
                icon: Icons.sticky_note_2_outlined,
                color: const Color(0xFF274472),
              ),
              MetricCard(
                title: 'Активные задачи',
                value: openTasks.length.toString(),
                subtitle: 'ещё в работе',
                icon: Icons.pending_actions_outlined,
                color: const Color(0xFF432371),
              ),
              MetricCard(
                title: 'Клиенты',
                value: clients.length.toString(),
                subtitle: 'в сопровождении',
                icon: Icons.people_outline,
                color: const Color(0xFF145c43),
              ),
              MetricCard(
                title: 'Сделки',
                value: deals.length.toString(),
                subtitle: 'во всей воронке',
                icon: Icons.handshake_outlined,
                color: const Color(0xFF115E67),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Ближайшие задачи',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (openTasks.isEmpty)
            const EmptyState(message: 'Дедлайнов нет — запланируй задачу.')
          else
            ...openTasks
                .take(3)
                .map(
                  (task) => TaskCard(
                    task: task,
                    onToggle: () => appState.toggleTask(task.id),
                  ),
                ),
          const SizedBox(height: 24),
          Text(
            'Свежие заметки',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (latestNotes.isEmpty)
            const EmptyState(message: 'Добавь первую заметку.')
          else
            ...latestNotes.map((note) => NoteCard(note: note)),
          const SizedBox(height: 24),
          Text(
            'Горящие сделки',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (hotDeals.isEmpty)
            const EmptyState(
              message: 'Все сделки закрыты. Самое время создать новую.',
            )
          else
            ...hotDeals
                .take(3)
                .map(
                  (deal) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(deal.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Клиент: ${deal.clientName}'),
                          if (deal.deadline != null)
                            Text(
                              'Дедлайн: ${formatReadableDate(deal.deadline!)}',
                            ),
                          if (deal.nextStep != null &&
                              deal.nextStep!.isNotEmpty)
                            Text('Следующий шаг: ${deal.nextStep}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${deal.amount.toStringAsFixed(0)} тг'),
                          Text(deal.stage),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey.shade800,
              child: Icon(icon),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
