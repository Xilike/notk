import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasis_alnotq/data/matching_round.dart';
import 'package:tasis_alnotq/screens/games_screens.dart';
import 'package:tasis_alnotq/services/app_state.dart';

void main() {
  for (final kind in ShadowMatchKind.values) {
    for (final level in ['KG1', 'KG2']) {
      testWidgets(
          '$kind $level: wrong snaps back, correct locks and rewards once',
          (tester) async {
        SharedPreferences.setMockInitialValues(
            {'soundEnabled': false, 'level': level});
        await AppState.instance.init();
        tester.view.physicalSize = const Size(430, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
            home: Directionality(
                textDirection: TextDirection.rtl,
                child: ShadowMatchGame(kind: kind))));
        final targetFinder = find.byKey(const ValueKey('match-target'));
        final display = tester
            .widgetList<Text>(
                find.descendant(of: targetFinder, matching: find.byType(Text)))
            .first
            .data;
        final draggables = tester
            .widgetList<Draggable<MatchChoice>>(
                find.byType(Draggable<MatchChoice>))
            .toList();
        expect(draggables.length, level == 'KG2' ? 4 : 3);
        final right =
            draggables.firstWhere((e) => e.data!.display == display).data!;
        final wrong =
            draggables.firstWhere((e) => e.data!.id != right.id).data!;
        Future<void> drop(MatchChoice item) async {
          final source = find.byKey(ValueKey('choice-${item.id}'));
          await tester.drag(source,
              tester.getCenter(targetFinder) - tester.getCenter(source));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
        }

        await drop(wrong);
        expect(AppState.instance.coins, 0);
        expect(find.byKey(ValueKey('choice-${wrong.id}')), findsOneWidget);
        await drop(right);
        expect(AppState.instance.coins, 1);
        expect(find.text('صح! ✓'), findsOneWidget);
        final locked = tester.widget<Draggable<MatchChoice>>(
            find.byKey(ValueKey('choice-${right.id}')));
        expect(locked.maxSimultaneousDrags, 0);
        await tester.tap(find.byKey(ValueKey('choice-${right.id}')));
        await tester.pump();
        expect(AppState.instance.coins, 1);
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('الجولة 2/6'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      });
    }
  }
}
