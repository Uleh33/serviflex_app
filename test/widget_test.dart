import 'package:flutter_test/flutter_test.dart';
import 'package:serviflex_app/main.dart';

void main() {
  testWidgets('Sincronización de interfaz Serviflex', (WidgetTester tester) async {
    // Carga la app
    await tester.pumpWidget(const ServiflexApp());

    // Verifica que el nombre de la app esté presente
    expect(find.text('SERVIFLEX'), findsOneWidget);

    // Verifica que los botones de acción existan
    expect(find.text('SOY CLIENTE'), findsOneWidget);
    expect(find.text('SOY PROFESIONAL'), findsOneWidget);
  });
}
