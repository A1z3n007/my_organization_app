import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../widgets/empty_state.dart';
import '../forms/crm_forms.dart';

class ClientsTab extends StatelessWidget {
  const ClientsTab({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final clients = appState.clients;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => showClientDialog(context, appState),
            icon: const Icon(Icons.person_add),
            label: const Text('Добавить клиента'),
          ),
        ),
        Expanded(
          child: clients.isEmpty
              ? const EmptyState(message: 'Клиентов пока нет.')
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemBuilder: (context, index) =>
                      ClientCard(client: clients[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemCount: clients.length,
                ),
        ),
      ],
    );
  }
}

class ClientCard extends StatelessWidget {
  const ClientCard({super.key, required this.client});

  final ClientRecord client;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          foregroundColor: Colors.indigo.shade900,
          child: Text(client.name.isEmpty ? '?' : client.name[0].toUpperCase()),
        ),
        title: Text(client.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (client.company.isNotEmpty) Text(client.company),
            if (client.phone.isNotEmpty) Text(client.phone),
            if (client.email?.isNotEmpty ?? false) Text(client.email!),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.deepPurple.shade50,
          ),
          child: Text(client.stage),
        ),
      ),
    );
  }
}
