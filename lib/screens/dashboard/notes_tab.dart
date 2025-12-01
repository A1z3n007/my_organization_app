import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../forms/crm_forms.dart';

class NotesTab extends StatelessWidget {
  const NotesTab({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final notes = appState.notes;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => showNoteDialog(context, appState),
            icon: const Icon(Icons.add),
            label: const Text('Добавить заметку'),
          ),
        ),
        Expanded(
          child: notes.isEmpty
              ? const EmptyState(message: 'Заметок пока нет.')
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemBuilder: (context, index) => NoteCard(note: notes[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemCount: notes.length,
                ),
        ),
      ],
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note});

  final CrmNote note;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              note.content.isEmpty ? 'Без описания' : note.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Создано: ${formatReadableDate(note.createdAt)}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
