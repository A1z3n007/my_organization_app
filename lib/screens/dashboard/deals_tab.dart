import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../forms/crm_forms.dart';

class DealsTab extends StatelessWidget {
  const DealsTab({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final deals = appState.deals;
    final grouped = <String, List<CrmDeal>>{
      for (final stage in AppState.dealStages) stage: [],
    };
    for (final deal in deals) {
      grouped[deal.stage]?.add(deal);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => showDealDialog(context, appState),
            icon: const Icon(Icons.add),
            label: const Text('Новая сделка'),
          ),
        ),
        Expanded(
          child: deals.isEmpty
              ? const EmptyState(
                  message: 'Добавь первую сделку и веди воронку.',
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: grouped.entries.map((entry) {
                    final stageDeals = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${entry.key} (${stageDeals.length})',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  _formatAmount(
                                    stageDeals.fold<double>(
                                      0,
                                      (sum, deal) => sum + deal.amount,
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (stageDeals.isEmpty)
                              const Text('Нет сделок на этом этапе.')
                            else
                              ...stageDeals.map(
                                (deal) => _DealCard(
                                  deal: deal,
                                  onStageChange: (stage) =>
                                      appState.updateDealStage(deal.id, stage),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  String _formatAmount(double value) {
    final millions = value >= 1000000
        ? '${(value / 1000000).toStringAsFixed(1)} млн тг'
        : '${value.toStringAsFixed(0)} тг';
    return millions.replaceAll('.0', '');
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal, required this.onStageChange});

  final CrmDeal deal;
  final ValueChanged<String> onStageChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121b33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deal.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.segment),
                tooltip: 'Изменить этап',
                onSelected: onStageChange,
                itemBuilder: (context) => AppState.dealStages
                    .map(
                      (stage) => PopupMenuItem<String>(
                        value: stage,
                        child: Text(stage),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Клиент: ${deal.clientName}'),
          const SizedBox(height: 4),
          Text('Сумма: ${deal.amount.toStringAsFixed(0)} тг'),
          if (deal.deadline != null)
            Text('Дедлайн: ${formatReadableDate(deal.deadline!)}'),
          if (deal.nextStep != null && deal.nextStep!.isNotEmpty)
            Text('Следующий шаг: ${deal.nextStep}'),
        ],
      ),
    );
  }
}
