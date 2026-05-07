import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart'; // Ensure 'frontend' matches your project name

void main() {
  testWidgets('AniTrack Initial Load Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Changed MyApp() to AniTrackApp() to match your main.dart
    await tester.pumpWidget(const AniTrackApp()); 

    // Verify that the Login Screen loads (checks for the 'ANITRACK' title)
    expect(find.text('ANITRACK'), findsOneWidget);

    // Verify the presence of the login button
    expect(find.text('LOG IN'), findsOneWidget);
  });
}
