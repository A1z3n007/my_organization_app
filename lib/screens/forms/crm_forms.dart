import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../utils/date_formatter.dart';

Future<void> showNoteDialog(BuildContext context, AppState appState) async {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Новая заметка'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Заголовок'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Обязательное поле'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bodyCtrl,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
              appState.addNote(
                title: titleCtrl.text.trim(),
                content: bodyCtrl.text.trim(),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Сохранить'),
          ),
        ],
      );
    },
  );

}

Future<void> showTaskDialog(BuildContext context, AppState appState) async {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime dueDate = DateTime.now().add(const Duration(days: 1));
  TaskPriority priority = TaskPriority.medium;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Новая задача'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Название'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Обязательное поле'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Описание'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: dueDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              setState(() => dueDate = picked);
                            }
                          },
                          icon: const Icon(Icons.event),
                          label: Text('До ${formatReadableDate(dueDate)}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<TaskPriority>(
                          // ignore: deprecated_member_use
                          value: priority,
                          decoration: const InputDecoration(
                            labelText: 'Приоритет',
                          ),
                          items: TaskPriority.values
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => priority = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  appState.addTask(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    dueDate: dueDate,
                    priority: priority,
                  );
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Добавить'),
              ),
            ],
          );
        },
      );
    },
  );

}

Future<void> showClientDialog(BuildContext context, AppState appState) async {
  final nameCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String stage = 'Новый';

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Новый клиент / контакт'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Имя клиента',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Обязательное поле'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: companyCtrl,
                      decoration: const InputDecoration(labelText: 'Компания'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Телефон'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: stage,
                      decoration: const InputDecoration(labelText: 'Этап'),
                      items: const [
                        DropdownMenuItem(value: 'Новый', child: Text('Новый')),
                        DropdownMenuItem(
                          value: 'Контакт',
                          child: Text('Контакт'),
                        ),
                        DropdownMenuItem(
                          value: 'Переговоры',
                          child: Text('Переговоры'),
                        ),
                        DropdownMenuItem(
                          value: 'Согласование',
                          child: Text('Согласование'),
                        ),
                        DropdownMenuItem(
                          value: 'Успешно',
                          child: Text('Успешно'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => stage = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  appState.addClient(
                    name: nameCtrl.text.trim(),
                    company: companyCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    stage: stage,
                  );
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      );
    },
  );

}

Future<void> showDealDialog(BuildContext context, AppState appState) async {
  final titleCtrl = TextEditingController();
  final clientCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final nextStepCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String stage = AppState.dealStages.first;
  DateTime? deadline;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Новая сделка'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Название сделки',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Обязательное поле'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: clientCtrl,
                      decoration: const InputDecoration(labelText: 'Клиент'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Обязательное поле'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Бюджет, тг',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите сумму';
                        }
                        return double.tryParse(value.replaceAll(',', '.')) ==
                                null
                            ? 'Только цифры'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: stage,
                      decoration: const InputDecoration(
                        labelText: 'Этап воронки',
                      ),
                      items: AppState.dealStages
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => stage = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate:
                              deadline ??
                              DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => deadline = picked);
                        }
                      },
                      icon: const Icon(Icons.event),
                      label: Text(
                        deadline == null
                            ? 'Выбрать дедлайн'
                            : 'До ${formatReadableDate(deadline!)}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nextStepCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Следующий шаг',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  appState.addDeal(
                    title: titleCtrl.text.trim(),
                    clientName: clientCtrl.text.trim(),
                    amount: double.parse(
                      amountCtrl.text.trim().replaceAll(',', '.'),
                    ),
                    stage: stage,
                    deadline: deadline,
                    nextStep: nextStepCtrl.text.trim(),
                  );
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Добавить'),
              ),
            ],
          );
        },
      );
    },
  );

}
