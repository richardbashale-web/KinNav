import 'package:flutter_test/flutter_test.dart';
import 'package:kinnav/app.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('renders KinNav home search and anonymous banner', (tester) async {
    await tester.pumpWidget(const KinNavApp());
    await tester.pumpAndSettle();
    expect(find.text('Où allez-vous ?'), findsOneWidget);
    expect(find.textContaining('Mode anonyme'), findsOneWidget);
    expect(find.text('Alertes'), findsOneWidget);
  });
}
