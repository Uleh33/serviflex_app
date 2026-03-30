import 'package:flutter_test/flutter_test.dart';
import 'package:todolisto/main.dart';

void main() {
  testWidgets('Sincronización de interfaz Todo Listo', (WidgetTester tester) async {
    // Carga la app
    await tester.pumpWidget(const TodoListoApp());

    // Verifica que el nombre de la app esté presente
    expect(find.text('TODO LISTO'), findsOneWidget);

    // Verifica que los botones de acción existan
    expect(find.text('SOY CLIENTE'), findsOneWidget);
    expect(find.text('SOY PROFESIONAL'), findsOneWidget);
  });
}
