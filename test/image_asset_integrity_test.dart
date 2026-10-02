import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:tasis_alnotq/data/game_data.dart';
import 'package:tasis_alnotq/data/lesson_data.dart';
import 'package:tasis_alnotq/data/matching_round.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('every declared learning imageAsset exists and is bundled', () async {
    final references = <String, String?>{
      for (final lesson in lessons)
        for (var i = 0; i < lesson.examples.length; i++)
          'lesson ${lesson.letter} example $i': lesson.examples[i].imageAsset,
      for (final animal in animals) 'animal ${animal.name}': animal.imageAsset,
    };
    final paths = references.values.whereType<String>().toList();
    expect(paths, isNotEmpty);
    final problems = <String>[];
    for (final entry in references.entries) {
      final path = entry.value;
      if (path == null) continue;
      if (!path.startsWith('assets/images/') ||
          path.split(RegExp(r'[/\\]')).contains('..') ||
          !File(path).existsSync()) {
        problems.add('${entry.key}: $path');
      }
    }
    expect(problems, isEmpty,
        reason:
            'Missing or invalid imageAsset references:\n${problems.join('\n')}');

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final bundled = manifest.listAssets().toSet();
    final omitted = paths.toSet().difference(bundled).toList()..sort();
    expect(omitted, isEmpty,
        reason:
            'Images missing from Flutter asset bundle:\n${omitted.join('\n')}');

    // MatchChoice images are derived from AnimalItem, rather than independently
    // declared. Exercise every animal as a target and check that propagation.
    final seen = <String>{};
    final random = Random(17);
    for (var i = 0; i < 1000 && seen.length < animals.length; i++) {
      final round = MatchingRound.generate(
          kind: ShadowMatchKind.animal, kg2: true, random: random);
      for (final choice in [round.target, ...round.options]) {
        final animal =
            animals.singleWhere((animal) => animal.name == choice.id);
        expect(choice.imageAsset, animal.imageAsset);
        seen.add(choice.id);
      }
    }
    expect(seen, containsAll(animals.map((animal) => animal.name)));
    // ignore: avoid_print
    print('Image assets checked: ${paths.length} declared references, '
        '${paths.toSet().length} unique files; no missing files. '
        '${seen.length} derived matching animal models verified.');
  });
}
