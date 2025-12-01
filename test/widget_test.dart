// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_organization_app/main.dart';
import 'package:my_organization_app/state/app_state.dart';

void main() {
  testWidgets('Auth screen renders login form by default', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appState = AppState(prefs);
    await appState.initialize();

    await tester.pumpWidget(MyApp(appState: appState));

    expect(find.text('Neon CRM'), findsOneWidget);
    expect(find.text('Войди в свой рабочий контур'), findsOneWidget);

    await tester.tap(find.text('Нет профиля? Регистрация'));
    await tester.pumpAndSettle();

    expect(find.text('Создай рабочий аккаунт'), findsOneWidget);
  });
}
