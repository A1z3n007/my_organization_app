import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  AppState(this._prefs);

  static const _storageKey = 'mini_crm_state';
  static const dealStages = [
    'Новый',
    'Контакт',
    'Переговоры',
    'Согласование',
    'Успешно',
  ];

  final SharedPreferences _prefs;
  CrmUser? _currentUser;
  final List<CrmUser> _users = [];
  final List<CrmNote> _notes = [];
  final List<CrmTask> _tasks = [];
  final List<ClientRecord> _clients = [];
  final List<CrmDeal> _deals = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final raw = _prefs.getString(_storageKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _users
        ..clear()
        ..addAll(
          (decoded['users'] as List<dynamic>? ?? []).map(
            (item) => CrmUser.fromMap(item as Map<String, dynamic>),
          ),
        );
      _notes
        ..clear()
        ..addAll(
          (decoded['notes'] as List<dynamic>? ?? []).map(
            (item) => CrmNote.fromMap(item as Map<String, dynamic>),
          ),
        );
      _tasks
        ..clear()
        ..addAll(
          (decoded['tasks'] as List<dynamic>? ?? []).map(
            (item) => CrmTask.fromMap(item as Map<String, dynamic>),
          ),
        );
      _clients
        ..clear()
        ..addAll(
          (decoded['clients'] as List<dynamic>? ?? []).map(
            (item) => ClientRecord.fromMap(item as Map<String, dynamic>),
          ),
        );
      _deals
        ..clear()
        ..addAll(
          (decoded['deals'] as List<dynamic>? ?? []).map(
            (item) => CrmDeal.fromMap(item as Map<String, dynamic>),
          ),
        );
      final currentId = decoded['currentUserId'] as String?;
      _currentUser = _users.firstWhere(
        (user) => user.id == currentId,
        orElse: () => CrmUser.empty,
      );
      if (_currentUser?.id.isEmpty ?? true) {
        _currentUser = null;
      }
    }
    _initialized = true;
    notifyListeners();
  }

  CrmUser? get currentUser => _currentUser;

  List<CrmNote> get notes {
    final user = _currentUser;
    if (user == null) {
      return const <CrmNote>[];
    }
    final userNotes = _notes.where((note) => note.ownerId == user.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(userNotes);
  }

  List<CrmTask> get tasks {
    final user = _currentUser;
    if (user == null) {
      return const <CrmTask>[];
    }
    final userTasks = _tasks.where((task) => task.ownerId == user.id).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return List.unmodifiable(userTasks);
  }

  List<ClientRecord> get clients {
    final user = _currentUser;
    if (user == null) {
      return const <ClientRecord>[];
    }
    final userClients =
        _clients.where((client) => client.ownerId == user.id).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(userClients);
  }

  List<CrmDeal> get deals {
    final user = _currentUser;
    if (user == null) {
      return const <CrmDeal>[];
    }
    final userDeals = _deals.where((deal) => deal.ownerId == user.id).toList()
      ..sort(
        (a, b) =>
            dealStages.indexOf(a.stage).compareTo(dealStages.indexOf(b.stage)),
      );
    return List.unmodifiable(userDeals);
  }

  bool register({
    required String name,
    required String email,
    required String password,
  }) {
    if (_users.any(
      (user) => user.email.toLowerCase() == email.trim().toLowerCase(),
    )) {
      return false;
    }
    final user = CrmUser(
      id: _generateId(),
      name: name,
      email: email.trim(),
      password: password,
    );
    _users.add(user);
    _currentUser = user;
    _bootstrapDemoContentFor(user);
    _persistState();
    notifyListeners();
    return true;
  }

  bool login({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final user = _users.firstWhere(
        (item) =>
            item.email.toLowerCase() == normalizedEmail &&
            item.password == password,
      );
      _currentUser = user;
      _persistState();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _persistState();
    notifyListeners();
  }

  void addNote({required String title, required String content}) {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    _notes.add(
      CrmNote(
        id: _generateId(),
        ownerId: user.id,
        title: title,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
    _persistState();
    notifyListeners();
  }

  void addTask({
    required String title,
    String? description,
    required DateTime dueDate,
    required TaskPriority priority,
  }) {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    final trimmedDescription = description?.trim();
    _tasks.add(
      CrmTask(
        id: _generateId(),
        ownerId: user.id,
        title: title,
        description: trimmedDescription?.isEmpty ?? true
            ? null
            : trimmedDescription,
        dueDate: dueDate,
        priority: priority,
      ),
    );
    _persistState();
    notifyListeners();
  }

  void toggleTask(String taskId) {
    final index = _tasks.indexWhere((item) => item.id == taskId);
    if (index == -1) {
      return;
    }
    _tasks[index].isDone = !_tasks[index].isDone;
    _persistState();
    notifyListeners();
  }

  void addClient({
    required String name,
    required String company,
    required String phone,
    required String stage,
    String? email,
  }) {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    final trimmedEmail = email?.trim();
    _clients.add(
      ClientRecord(
        id: _generateId(),
        ownerId: user.id,
        name: name,
        company: company,
        phone: phone,
        stage: stage,
        email: trimmedEmail?.isEmpty ?? true ? null : trimmedEmail,
      ),
    );
    _persistState();
    notifyListeners();
  }

  void addDeal({
    required String title,
    required String clientName,
    required double amount,
    required String stage,
    DateTime? deadline,
    String? nextStep,
  }) {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    _deals.add(
      CrmDeal(
        id: _generateId(),
        ownerId: user.id,
        title: title,
        clientName: clientName,
        amount: amount,
        stage: stage,
        deadline: deadline,
        nextStep: nextStep,
      ),
    );
    _persistState();
    notifyListeners();
  }

  void updateDealStage(String dealId, String stage) {
    final index = _deals.indexWhere((deal) => deal.id == dealId);
    if (index == -1) {
      return;
    }
    _deals[index] = _deals[index].copyWith(stage: stage);
    _persistState();
    notifyListeners();
  }

  void _bootstrapDemoContentFor(CrmUser user) {
    final now = DateTime.now();
    _notes.addAll([
      CrmNote(
        id: _generateId(),
        ownerId: user.id,
        title: 'Созвон с новым клиентом',
        content: 'Уточнить потребности и отправить презентацию после встречи.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      CrmNote(
        id: _generateId(),
        ownerId: user.id,
        title: 'Встреча подтверждена',
        content: 'Очная встреча завтра в 14:00. Взять договор и презу.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    _tasks.addAll([
      CrmTask(
        id: _generateId(),
        ownerId: user.id,
        title: 'Подготовить КП',
        description:
            'Учесть индивидуальные скидки и постпродажное сопровождение.',
        dueDate: now.add(const Duration(days: 1)),
        priority: TaskPriority.high,
      ),
      CrmTask(
        id: _generateId(),
        ownerId: user.id,
        title: 'Отправить напоминание о демо',
        description: 'За час до звонка прислать ссылку и чек-лист.',
        dueDate: now.add(const Duration(days: 2)),
        priority: TaskPriority.medium,
      ),
    ]);

    _clients.addAll([
      ClientRecord(
        id: _generateId(),
        ownerId: user.id,
        name: 'Алия Серикова',
        company: 'Sunrise LLC',
        phone: '+7 777 555 11 22',
        stage: 'Переговоры',
        email: 'aliya@sunrise.kz',
      ),
      ClientRecord(
        id: _generateId(),
        ownerId: user.id,
        name: 'Михаил Бек',
        company: 'Orbit Tech',
        phone: '+7 700 123 45 67',
        stage: 'Контакт',
        email: 'mbeck@orbit.kz',
      ),
    ]);

    _deals.addAll([
      CrmDeal(
        id: _generateId(),
        ownerId: user.id,
        title: 'CRM + обучение команды',
        clientName: 'Sunrise LLC',
        amount: 1200000,
        stage: 'Переговоры',
        deadline: now.add(const Duration(days: 5)),
        nextStep: 'Подготовить финальный расчёт',
      ),
      CrmDeal(
        id: _generateId(),
        ownerId: user.id,
        title: 'Лицензии + поддержка',
        clientName: 'Orbit Tech',
        amount: 850000,
        stage: 'Контакт',
        deadline: now.add(const Duration(days: 10)),
        nextStep: 'Назначить демо на следующую неделю',
      ),
    ]);
  }

  void _persistState() {
    final payload = jsonEncode({
      'users': _users.map((user) => user.toMap()).toList(),
      'notes': _notes.map((note) => note.toMap()).toList(),
      'tasks': _tasks.map((task) => task.toMap()).toList(),
      'clients': _clients.map((client) => client.toMap()).toList(),
      'deals': _deals.map((deal) => deal.toMap()).toList(),
      'currentUserId': _currentUser?.id,
    });
    _prefs.setString(_storageKey, payload);
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}

class CrmUser {
  CrmUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  final String id;
  final String name;
  final String email;
  final String password;

  static CrmUser get empty =>
      CrmUser(id: '', name: '', email: '', password: '');

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
  };

  factory CrmUser.fromMap(Map<String, dynamic> map) => CrmUser(
    id: map['id'] as String,
    name: map['name'] as String,
    email: map['email'] as String,
    password: map['password'] as String,
  );
}

class CrmNote {
  CrmNote({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String content;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CrmNote.fromMap(Map<String, dynamic> map) => CrmNote(
    id: map['id'] as String,
    ownerId: map['ownerId'] as String,
    title: map['title'] as String,
    content: map['content'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );
}

class CrmTask {
  CrmTask({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    this.isDone = false,
  });

  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskPriority priority;
  bool isDone;

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority.name,
    'isDone': isDone,
  };

  factory CrmTask.fromMap(Map<String, dynamic> map) => CrmTask(
    id: map['id'] as String,
    ownerId: map['ownerId'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    dueDate: DateTime.parse(map['dueDate'] as String),
    priority: TaskPriority.values.firstWhere(
      (value) => value.name == map['priority'],
    ),
    isDone: map['isDone'] as bool? ?? false,
  );
}

class ClientRecord {
  ClientRecord({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.company,
    required this.phone,
    required this.stage,
    this.email,
  });

  final String id;
  final String ownerId;
  final String name;
  final String company;
  final String phone;
  final String stage;
  final String? email;

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'company': company,
    'phone': phone,
    'stage': stage,
    'email': email,
  };

  factory ClientRecord.fromMap(Map<String, dynamic> map) => ClientRecord(
    id: map['id'] as String,
    ownerId: map['ownerId'] as String,
    name: map['name'] as String,
    company: map['company'] as String,
    phone: map['phone'] as String,
    stage: map['stage'] as String,
    email: map['email'] as String?,
  );
}

class CrmDeal {
  CrmDeal({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.clientName,
    required this.amount,
    required this.stage,
    this.deadline,
    this.nextStep,
  });

  final String id;
  final String ownerId;
  final String title;
  final String clientName;
  final double amount;
  final String stage;
  final DateTime? deadline;
  final String? nextStep;

  CrmDeal copyWith({String? stage}) => CrmDeal(
    id: id,
    ownerId: ownerId,
    title: title,
    clientName: clientName,
    amount: amount,
    stage: stage ?? this.stage,
    deadline: deadline,
    nextStep: nextStep,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'clientName': clientName,
    'amount': amount,
    'stage': stage,
    'deadline': deadline?.toIso8601String(),
    'nextStep': nextStep,
  };

  factory CrmDeal.fromMap(Map<String, dynamic> map) => CrmDeal(
    id: map['id'] as String,
    ownerId: map['ownerId'] as String,
    title: map['title'] as String,
    clientName: map['clientName'] as String,
    amount: (map['amount'] as num).toDouble(),
    stage: map['stage'] as String,
    deadline: map['deadline'] == null
        ? null
        : DateTime.parse(map['deadline'] as String),
    nextStep: map['nextStep'] as String?,
  );
}

enum TaskPriority { low, medium, high }

extension TaskPriorityUi on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Низкий';
      case TaskPriority.medium:
        return 'Средний';
      case TaskPriority.high:
        return 'Высокий';
    }
  }

  MaterialColor get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}
