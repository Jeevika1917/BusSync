import 'package:flutter_test/flutter_test.dart';
import 'package:bussync/main.dart';

void main() {
  testWidgets('BusSyncApp smoke test renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BusSyncApp());
    expect(find.text('BusSync'), findsOneWidget);
    expect(find.text('"Check. Choose. Board."'), findsOneWidget);
  });
}
