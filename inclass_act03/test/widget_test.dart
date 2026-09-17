// Basic smoke test for the RA Duty Deck.
//
// The default `flutter create` test pumped `MyApp` and tapped a `+` icon, but
// this project's root widget is `TactileDeckApp` and there is no counter FAB,
// so that generated test could not compile. Retargeted at the real widget.

import 'package:flutter_test/flutter_test.dart';

import 'package:inclass_act03/main.dart';

void main() {
  testWidgets('deck renders its app bar and starting metrics',
      (WidgetTester tester) async {
    // Build the real root widget and trigger a frame.
    await tester.pumpWidget(const TactileDeckApp());

    // App bar title and the two metric labels are present at startup.
    expect(find.text('RA DUTY DECK'), findsOneWidget);
    expect(find.text('LOGGED ACTIONS'), findsOneWidget);
    expect(find.text('FLOOR LOAD'), findsOneWidget);

    // Counter starts at zero and the floor load starts at the 65% default.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('65%'), findsOneWidget);
  });
}
