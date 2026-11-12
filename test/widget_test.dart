import 'package:flutter_test/flutter_test.dart';
import 'package:food_kart_app/main.dart';

void main() {
  testWidgets('FoodKartApp launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodKartApp());
    expect(find.text('FoodKart'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
  });
}
