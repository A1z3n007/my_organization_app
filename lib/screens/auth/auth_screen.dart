import 'package:flutter/material.dart';

import '../../state/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    bool success;
    if (_isLogin) {
      success = widget.appState.login(email: email, password: password);
      if (!success) {
        setState(() => _errorMessage = 'Неверный email или пароль');
        return;
      }
    } else {
      success = widget.appState.register(
        name: _nameCtrl.text.trim(),
        email: email,
        password: password,
      );
      if (!success) {
        setState(() => _errorMessage = 'Такой email уже зарегистрирован');
        return;
      }
    }
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 6,
              color: const Color(0xFF0B1224),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Neon CRM',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin
                            ? 'Войди в свой рабочий контур'
                            : 'Создай рабочий аккаунт',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (!_isLogin)
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Как тебя зовут?',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Укажи имя'
                              : null,
                        ),
                      if (!_isLogin) const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Введите email'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Пароль'),
                        validator: (value) => value != null && value.length >= 4
                            ? null
                            : 'Минимум 4 символа',
                      ),
                      const SizedBox(height: 16),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _submit,
                        child: Text(_isLogin ? 'Войти' : 'Создать аккаунт'),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin
                              ? 'Нет профиля? Регистрация'
                              : 'Уже в системе? Войти',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
