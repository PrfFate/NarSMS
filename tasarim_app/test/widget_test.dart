import 'package:flutter_test/flutter_test.dart';
import 'package:tasarim_app/app.dart';

void main() {
  testWidgets('App should load login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that login page elements exist
    expect(find.text('Hoş Geldiniz'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
