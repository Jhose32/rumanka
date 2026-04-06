import 'package:flutter_test/flutter_test.dart';
import 'package:app_rumanka/main.dart';

void main() {
  testWidgets('App inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const RumankaApp());
  });
}
