import 'package:dreiser_ops/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows dashboard and navigates to work queue', (tester) async {
    await tester.pumpWidget(DreiserOpsApp(state: AppState.screenshot()));

    expect(find.text(appName), findsOneWidget);
    expect(find.text('Daily operations desk'), findsOneWidget);
    expect(find.text('Operations snapshot'), findsOneWidget);

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    expect(find.text('Work queue'), findsOneWidget);
    expect(find.text('Track container DSRU 418204'), findsOneWidget);
  });

  testWidgets('creates a local work record from the form', (tester) async {
    final state = AppState.emptyForTest();
    await tester.pumpWidget(DreiserOpsApp(state: state));

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('new-work-item')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('work-title-field')),
      'Book carrier receiving slot',
    );
    await tester.enterText(
      find.byKey(const Key('work-reference-field')),
      'APT-2210',
    );
    await tester.enterText(
      find.byKey(const Key('work-owner-field')),
      'Gate office',
    );
    await tester.enterText(
      find.byKey(const Key('work-notes-field')),
      'Hold a receiving window and confirm dock lane assignment.',
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -520));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create record'));
    await tester.pumpAndSettle();

    expect(find.text('Book carrier receiving slot'), findsOneWidget);
    expect(state.items, hasLength(1));
    expect(state.items.single.reference, 'APT-2210');
  });
}
