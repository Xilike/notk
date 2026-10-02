import 'dart:math';
import '../data/matching_round.dart';
import '../services/reward_service.dart';
import '../services/child_speech_text.dart';
import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../data/lesson_data.dart';
import '../models/lesson.dart';
import '../services/app_state.dart';
import '../services/speech_service.dart';
import '../widgets/ui.dart';
import '../widgets/auto_speak_page.dart';

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});
  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen>
    with AutoSpeakPage<GamesHubScreen> {
  @override
  Object get autoSpeechKey => 'games';
  @override
  Future<void> speakVisibleContent() => SpeechService.speakScreenEntry([
        SpeechService.text.instruction(ChildInstruction.chooseGame),
      ]);

  @override
  Widget build(BuildContext context) {
    final games = <({
      String title,
      String subtitle,
      String emoji,
      Color color,
      Widget page
    })>[
      (
        title: 'رتّب الحروف',
        subtitle: 'اسحب الحروف وضعها بالترتيب',
        emoji: '🔡',
        color: const Color(0xFF1677FF),
        page: const LetterOrderingGame()
      ),
      (
        title: 'رتّب الأرقام',
        subtitle: 'رتّب الأرقام من الأصغر للأكبر',
        emoji: '🔢',
        color: const Color(0xFFFF9F1C),
        page: const NumberOrderingGame()
      ),
      (
        title: 'اختر الحيوان',
        subtitle: 'اسمع الاسم واختر شكل الحيوان',
        emoji: '🦁',
        color: const Color(0xFF00A884),
        page: const AnimalChoiceGame()
      ),
      (
        title: 'اختر الشكل',
        subtitle: 'تعرّف على الدائرة والمربع وغيرها',
        emoji: '🔺',
        color: const Color(0xFF8E5AE8),
        page: const ShapeChoiceGame()
      ),
      (
        title: 'طابق الحيوان مع ظله',
        subtitle: 'اسحب الحيوان وضعه فوق ظله',
        emoji: '🐾',
        color: const Color(0xFF455A64),
        page: const ShadowMatchGame(kind: ShadowMatchKind.animal)
      ),
      (
        title: 'طابق الحرف',
        subtitle: 'اسحب الحرف المطابق إلى الظل',
        emoji: '🔠',
        color: const Color(0xFF536DFE),
        page: const ShadowMatchGame(kind: ShadowMatchKind.letter)
      ),
      (
        title: 'طابق الرقم',
        subtitle: 'اسحب الرقم المطابق إلى الظل',
        emoji: '🔟',
        color: const Color(0xFFFF7043),
        page: const ShadowMatchGame(kind: ShadowMatchKind.number)
      ),
      (
        title: 'اسمع واختار',
        subtitle: 'اسمع الكلمة واختار الصورة',
        emoji: '🔊',
        color: const Color(0xFFFF5CB7),
        page: const ListenChooseGame()
      ),
      (
        title: 'الحرف الأول',
        subtitle: 'اختار أول حرف في الكلمة',
        emoji: '🔤',
        color: const Color(0xFF7458DE),
        page: const FirstLetterGame()
      ),
      (
        title: 'طابق الكلمة',
        subtitle: 'طابق الكلمة بالصورة',
        emoji: '🧩',
        color: const Color(0xFF31BA6B),
        page: const MatchWordGame()
      ),
    ];

    return Scaffold(
      appBar: AppBar(
          title: const Text('ألعابي التعليمية 🎮',
              style: TextStyle(fontWeight: FontWeight.w900))),
      body: SkyBackground(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('اختار لعبة',
                  subtitle:
                      'كل إجابة صحيحة تكسبك عملة، وكل 10 إجابات تفتح صندوق مكافأة'),
              const SizedBox(height: 15),
              Expanded(
                child: GridView.builder(
                  itemCount: games.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: .86,
                  ),
                  itemBuilder: (context, i) {
                    final g = games[i];
                    return KidCard(
                      gradient: [g.color, g.color.withValues(alpha: .78)],
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => g.page)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(g.emoji,
                                    style: const TextStyle(fontSize: 34)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(g.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 5),
                            Text(g.subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    height: 1.25,
                                    fontSize: 12.5)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class _QuizState<T extends StatefulWidget> extends State<T>
    with AutoSpeakPage<T> {
  int question = 0;
  int score = 0;
  bool locked = false;
  int? selected;
  final random = Random();
  final rewards = RewardService();
  static const total = 8;

  List<String> get questionSpeech;
  @override
  Object get autoSpeechKey => question;
  @override
  bool get canAutoSpeak => !locked;
  @override
  Future<void> speakVisibleContent() =>
      SpeechService.speakQuestion(questionSpeech);
  Future<void> replayQuestion() =>
      SpeechService.speakQuestion(questionSpeech, automatic: false);

  Future<void> choose(int selectedIndex, int correctIndex,
      {String? spokenAnswer, String? tappedText}) async {
    if (locked) return;
    final isCorrect = selectedIndex == correctIndex;
    setState(() => locked = true);

    if (tappedText != null) await SpeechService.speak(tappedText);
    if (!mounted || !educationalPageVisible) return;
    setState(() {
      selected = selectedIndex;
      if (isCorrect) score++;
    });
    final openedBox = await rewards.answer(question, isCorrect);
    if (isCorrect) {
      await SpeechService.correctAnswer(target: spokenAnswer);
      if (openedBox) await SpeechService.rewardBox();
    } else {
      await SpeechService.wrongAnswer(target: spokenAnswer);
    }

    if (!mounted || !educationalPageVisible) return;
    if (question == total - 1) {
      final earned = score >= 6
          ? 10
          : score >= 4
              ? 7
              : 5;
      await rewards.finish(correct: score, total: total, starsEarned: earned);
      if (!mounted || !educationalPageVisible) return;
      final state = AppState.instance;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('خلصت الجولة! 🎉', textAlign: TextAlign.center),
          content: Text(
            'نتيجتك $score من $total\nوكسبت $earned نجوم ⭐\nمعاك ${state.coins} عملة 🪙 و ${state.rewardBoxes} صندوق 🎁',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('جميل!'))
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      question++;
      selected = null;
      locked = false;
    });
    nextQuestion();
    autoSpeechContentChanged();
  }

  void nextQuestion();

  Widget header() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('السؤال ${question + 1}/$total',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              Text('⭐ $score',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: (question + 1) / total,
              minHeight: 9,
              borderRadius: BorderRadius.circular(10)),
        ],
      );
}

abstract class _OrderingGameState<T extends StatefulWidget> extends State<T>
    with AutoSpeakPage<T> {
  int question = 0;
  int firstTryScore = 0;
  bool hadMistake = false;
  bool checking = false;
  bool showError = false;
  final random = Random();
  final rewards = RewardService();
  static const total = 6;
  late List<String> items;
  late List<String> answer;

  @override
  Object get autoSpeechKey => question;
  @override
  bool get canAutoSpeak => !checking;
  ChildInstruction get orderingInstruction;
  @override
  Future<void> speakVisibleContent() => SpeechService.speakQuestion([
        SpeechService.text.instruction(orderingInstruction),
        items.map(spokenItem).join('، '),
      ]);

  String get spokenAnswer;
  void prepareQuestion();

  void reorder(int oldIndex, int newIndex) {
    if (checking) return;
    setState(() {
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      showError = false;
    });
  }

  Future<void> checkOrder() async {
    if (checking) return;
    setState(() => checking = true);
    final isCorrect = _sameOrder(items, answer);
    if (!isCorrect) {
      hadMistake = true;
      setState(() => showError = true);
      await AppState.instance.recordAnswer(false);
      await SpeechService.wrongAnswer();
      if (!mounted || !educationalPageVisible) return;
      await Future.delayed(const Duration(milliseconds: 450));
      if (mounted) {
        setState(() {
          showError = false;
          checking = false;
        });
      }
      return;
    }

    setState(() => checking = true);
    if (!hadMistake) firstTryScore++;
    final openedBox = await rewards.answer(question, true);
    await SpeechService.correctAnswer(target: spokenAnswer);
    if (openedBox) await SpeechService.rewardBox();
    if (!mounted || !educationalPageVisible) return;

    if (question == total - 1) {
      final earned = firstTryScore >= 5
          ? 10
          : firstTryScore >= 3
              ? 7
              : 5;
      await rewards.finish(
          correct: firstTryScore, total: total, starsEarned: earned);
      if (!mounted || !educationalPageVisible) return;
      final state = AppState.instance;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('اكتمل الترتيب 🎉', textAlign: TextAlign.center),
          content: Text(
            'رتبت $total مجموعات كاملة\n${firstTryScore == 0 ? 'استمريت لحد ما وصلت للحل 👏' : 'ومن أول محاولة: $firstTryScore'}\n+$earned نجوم ⭐  •  ${state.coins} 🪙',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('جميل!'))
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      question++;
      hadMistake = false;
      checking = false;
      showError = false;
      prepareQuestion();
    });
    autoSpeechContentChanged();
  }

  bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Widget header() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الجولة ${question + 1}/$total',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              Text('🪙 ${AppState.instance.coins}',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: (question + 1) / total,
              minHeight: 9,
              borderRadius: BorderRadius.circular(10)),
        ],
      );

  String spokenItem(String item) {
    final number = List.generate(20, (i) => i + 1)
        .where((n) => arabicNumber(n) == item)
        .firstOrNull;
    return number == null
        ? SpeechService.letterTarget(item)
        : spokenArabicNumber(number);
  }

  Future<void> speakItem(String item) => SpeechService.speak(spokenItem(item));

  Widget orderingBoard({required Color color}) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 112,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: showError ? const Color(0xFFFFECEC) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
              color: showError ? Colors.red : const Color(0xFFDCE8F2),
              width: 3),
        ),
        child: ReorderableListView.builder(
          scrollDirection: Axis.horizontal,
          buildDefaultDragHandles: false,
          itemCount: items.length,
          onReorderItem: reorder,
          onReorderStart: (index) {
            if (!checking) speakItem(items[index]);
          },
          itemBuilder: (context, i) => ReorderableDragStartListener(
            key: ValueKey('${items[i]}-$question'),
            index: i,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: checking ? null : () => speakItem(items[i]),
              child: Container(
                width: 68,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(items[i],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900)),
                    const Icon(Icons.drag_indicator_rounded,
                        color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class LetterOrderingGame extends StatefulWidget {
  const LetterOrderingGame({super.key});
  @override
  State<LetterOrderingGame> createState() => _LetterOrderingGameState();
}

class _LetterOrderingGameState extends _OrderingGameState<LetterOrderingGame> {
  @override
  ChildInstruction get orderingInstruction => ChildInstruction.orderLetters;

  @override
  void initState() {
    super.initState();
    prepareQuestion();
  }

  @override
  void prepareQuestion() {
    final available =
        AppState.instance.unlockedLetters.clamp(4, lessons.length).toInt();
    final desired = AppState.instance.level == 'KG2' ? 5 : 4;
    final count = min(desired, available);
    final maxStart = max(0, available - count);
    final start = maxStart == 0 ? 0 : random.nextInt(maxStart + 1);
    answer = lessons.skip(start).take(count).map((e) => e.letter).toList();
    items = List<String>.from(answer);
    _shuffleUntilDifferent();
  }

  void _shuffleUntilDifferent() {
    var tries = 0;
    do {
      items.shuffle(random);
      tries++;
    } while (_isAlreadyCorrect() && tries < 12);
  }

  bool _isAlreadyCorrect() {
    for (var i = 0; i < items.length; i++) {
      if (items[i] != answer[i]) return false;
    }
    return true;
  }

  @override
  String get spokenAnswer => answer.join('، ');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('رتّب الحروف 🔡')),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              header(),
              const SizedBox(height: 26),
              Text(
                  SpeechService.text.instruction(ChildInstruction.orderLetters),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text('سحب كل بطاقة إلى مكانها الصحيح',
                  style: TextStyle(fontSize: 16, color: Color(0xFF61758A))),
              const SizedBox(height: 10),
              IconButton.filledTonal(
                onPressed: () => SpeechService.speakQuestion([
                  SpeechService.text.instruction(orderingInstruction),
                  items.map(spokenItem).join('، ')
                ], automatic: false),
                icon: const Icon(Icons.volume_up_rounded),
              ),
              const Spacer(),
              orderingBoard(color: const Color(0xFF1677FF)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: checking ? null : checkOrder,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('تحقّق',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
}

class NumberOrderingGame extends StatefulWidget {
  const NumberOrderingGame({super.key});
  @override
  State<NumberOrderingGame> createState() => _NumberOrderingGameState();
}

class _NumberOrderingGameState extends _OrderingGameState<NumberOrderingGame> {
  @override
  ChildInstruction get orderingInstruction => ChildInstruction.orderNumbers;

  @override
  void initState() {
    super.initState();
    prepareQuestion();
  }

  @override
  void prepareQuestion() {
    final isKg2 = AppState.instance.level == 'KG2';
    final maxNumber = isKg2 ? 10 : 5;
    final count = isKg2 ? 5 : 4;
    final maxStart = maxNumber - count + 1;
    final start = 1 + (maxStart <= 1 ? 0 : random.nextInt(maxStart));
    answer = List.generate(count, (i) => arabicNumber(start + i));
    items = List<String>.from(answer);
    var tries = 0;
    do {
      items.shuffle(random);
      tries++;
    } while (_alreadyCorrect() && tries < 12);
  }

  bool _alreadyCorrect() {
    for (var i = 0; i < items.length; i++) {
      if (items[i] != answer[i]) return false;
    }
    return true;
  }

  @override
  String get spokenAnswer => answer.join('، ');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('رتّب الأرقام 🔢')),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              header(),
              const SizedBox(height: 26),
              const Text('من الأصغر إلى الأكبر',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              Text(
                AppState.instance.level == 'KG2'
                    ? 'نتدرّب على الأرقام من ١ إلى ١٠'
                    : 'نتدرّب على الأرقام من ١ إلى ٥',
                style: const TextStyle(fontSize: 16, color: Color(0xFF61758A)),
              ),
              const SizedBox(height: 10),
              IconButton.filledTonal(
                onPressed: () => SpeechService.speakQuestion([
                  SpeechService.text.instruction(orderingInstruction),
                  items.map(spokenItem).join('، ')
                ], automatic: false),
                icon: const Icon(Icons.volume_up_rounded),
              ),
              const Spacer(),
              orderingBoard(color: const Color(0xFFFF9F1C)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: checking ? null : checkOrder,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('تحقّق',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
}

class AnimalChoiceGame extends StatefulWidget {
  const AnimalChoiceGame({super.key});
  @override
  State<AnimalChoiceGame> createState() => _AnimalChoiceGameState();
}

class _AnimalChoiceGameState extends _QuizState<AnimalChoiceGame> {
  late AnimalItem target;
  late List<AnimalItem> options;
  late int correct;

  @override
  List<String> get questionSpeech =>
      [SpeechService.whereQuestion(target.spokenName)];

  @override
  void initState() {
    super.initState();
    nextQuestion();
  }

  @override
  void nextQuestion() {
    final pool =
        AppState.instance.level == 'KG2' ? animals : animals.take(8).toList();
    final optionCount = AppState.instance.level == 'KG2' ? 4 : 3;
    target = pool[random.nextInt(pool.length)];
    final rest = List<AnimalItem>.from(pool.where((e) => e.name != target.name))
      ..shuffle(random);
    options = [target, ...rest.take(optionCount - 1)]..shuffle(random);
    correct = options.indexWhere((e) => e.name == target.name);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('اختر الحيوان 🦁')),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              header(),
              const SizedBox(height: 20),
              Text('أين ${target.name}؟',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              IconButton.filledTonal(
                onPressed: replayQuestion,
                icon: const Icon(Icons.volume_up_rounded, size: 30),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: List.generate(options.length, (i) {
                    final chosen = selected == i;
                    final right = i == correct;
                    return InkWell(
                      key: ValueKey('animal-option-${options[i].name}'),
                      borderRadius: BorderRadius.circular(28),
                      onTap: () async {
                        if (locked) return;
                        await choose(i, correct,
                            tappedText: options[i].spokenName,
                            spokenAnswer: target.spokenName);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              color: chosen
                                  ? (right ? Colors.green : Colors.red)
                                  : const Color(0xFFE1EBF2),
                              width: 4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            KidImage(
                              asset: options[i].imageAsset,
                              emoji: options[i].emoji,
                              size: 110,
                              radius: 26,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
}

class ShapeChoiceGame extends StatefulWidget {
  const ShapeChoiceGame({super.key});
  @override
  State<ShapeChoiceGame> createState() => _ShapeChoiceGameState();
}

class _ShapeChoiceGameState extends _QuizState<ShapeChoiceGame> {
  late ShapeItem target;
  late List<ShapeItem> options;
  late int correct;

  @override
  List<String> get questionSpeech =>
      [SpeechService.whereQuestion(target.spokenName)];

  @override
  void initState() {
    super.initState();
    nextQuestion();
  }

  @override
  void nextQuestion() {
    final pool =
        AppState.instance.level == 'KG2' ? shapes : shapes.take(4).toList();
    final optionCount = AppState.instance.level == 'KG2' ? 4 : 3;
    target = pool[random.nextInt(pool.length)];
    final rest = List<ShapeItem>.from(pool.where((e) => e.name != target.name))
      ..shuffle(random);
    options = [target, ...rest.take(optionCount - 1)]..shuffle(random);
    correct = options.indexWhere((e) => e.name == target.name);
  }

  @override
  Widget build(BuildContext context) {
    const shapeColors = [
      Color(0xFF1677FF),
      Color(0xFFFF5C7A),
      Color(0xFF00A884),
      Color(0xFFFF9F1C)
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('اختر الشكل 🔺')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            header(),
            const SizedBox(height: 20),
            Text('أين ${target.name}؟',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            IconButton.filledTonal(
              onPressed: replayQuestion,
              icon: const Icon(Icons.volume_up_rounded, size: 30),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: List.generate(options.length, (i) {
                  final chosen = selected == i;
                  final right = i == correct;
                  return InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () async {
                      if (locked) return;
                      await choose(i, correct,
                          tappedText: options[i].spokenName,
                          spokenAnswer: target.spokenName);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: chosen
                                ? (right ? Colors.green : Colors.red)
                                : const Color(0xFFE1EBF2),
                            width: 4),
                      ),
                      child: Text(options[i].symbol,
                          style: TextStyle(
                              fontSize: 92,
                              color: shapeColors[i],
                              fontWeight: FontWeight.w900)),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListenChooseGame extends StatefulWidget {
  const ListenChooseGame({super.key});
  @override
  State<ListenChooseGame> createState() => _ListenChooseGameState();
}

class _ListenChooseGameState extends _QuizState<ListenChooseGame> {
  late WordExample target;
  late List<WordExample> options;
  late int correct;

  @override
  List<String> get questionSpeech =>
      [SpeechService.text.instruction(ChildInstruction.choose), target.word];

  @override
  void initState() {
    super.initState();
    nextQuestion();
  }

  @override
  void nextQuestion() {
    final pool = lessons
        .take(
            AppState.instance.unlockedLetters.clamp(4, lessons.length).toInt())
        .toList();
    final all = (AppState.instance.level == 'KG2'
            ? pool.expand((e) => e.examples)
            : pool.map((e) => e.examples.first))
        .toList();
    target = all[random.nextInt(all.length)];
    final distractors =
        List<WordExample>.from(all.where((e) => e.word != target.word))
          ..shuffle(random);
    options = [target, ...distractors.take(3)]..shuffle(random);
    correct = options.indexWhere((e) => e.word == target.word);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('اسمع واختار')),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              header(),
              const SizedBox(height: 16),
              const Text('الاستماع ثم اختيار الصورة الصحيحة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              IconButton.filled(
                  style: IconButton.styleFrom(minimumSize: const Size(70, 70)),
                  onPressed: replayQuestion,
                  icon: const Icon(Icons.volume_up_rounded, size: 36)),
              const SizedBox(height: 15),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      children: List.generate(4, (i) => _option(i)))),
            ],
          ),
        ),
      );

  Widget _option(int i) {
    final right = i == correct;
    final chosen = selected == i;
    return InkWell(
      onTap: () async {
        if (locked) return;
        await choose(i, correct,
            tappedText: options[i].word, spokenAnswer: target.word);
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
              color: chosen
                  ? (right ? Colors.green : Colors.red)
                  : const Color(0xFFE5EDF4),
              width: 4),
        ),
        child: KidImage(
          asset: options[i].imageAsset,
          emoji: options[i].emoji,
          size: 110,
          radius: 26,
        ),
      ),
    );
  }
}

class FirstLetterGame extends StatefulWidget {
  const FirstLetterGame({super.key});
  @override
  State<FirstLetterGame> createState() => _FirstLetterGameState();
}

class _FirstLetterGameState extends _QuizState<FirstLetterGame> {
  late int targetIndex;
  late List<String> choices;
  late int correct;

  @override
  List<String> get questionSpeech => [
        'مَا أَوَّلُ حَرْفٍ فِي كَلِمَة',
        lessons[targetIndex].examples.first.word
      ];

  @override
  void initState() {
    super.initState();
    nextQuestion();
  }

  @override
  void nextQuestion() {
    targetIndex = random.nextInt(
        AppState.instance.unlockedLetters.clamp(4, lessons.length).toInt());
    final correctLetter = lessons[targetIndex].letter;
    final others = lessons
        .map((e) => e.letter)
        .where((e) => e != correctLetter)
        .toList()
      ..shuffle(random);
    choices = [correctLetter, ...others.take(2)]..shuffle(random);
    correct = choices.indexOf(correctLetter);
  }

  @override
  Widget build(BuildContext context) {
    final ex = lessons[targetIndex].examples.first;
    return Scaffold(
      appBar: AppBar(title: const Text('الحرف الأول')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            header(),
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => SpeechService.speak(ex.word),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                child: Column(children: [
                  Text(ex.emoji, style: const TextStyle(fontSize: 100)),
                  Text(ex.word,
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.w900)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            IconButton(
                onPressed: replayQuestion,
                icon: const Icon(Icons.volume_up_rounded, size: 34)),
            const Text('ما أول حرف في الكلمة؟',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) {
                final chosen = selected == i;
                final right = i == correct;
                return InkWell(
                  onTap: () async {
                    if (locked) return;
                    final cue = lessons
                        .firstWhere((e) => e.letter == choices[i])
                        .soundCue;
                    await choose(i, correct,
                        tappedText: cue,
                        spokenAnswer: lessons[targetIndex].soundCue);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: chosen
                          ? (right ? Colors.green : Colors.red)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE4EDF4)),
                    ),
                    child: Text(choices[i],
                        style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: chosen
                                ? Colors.white
                                : const Color(0xFF17365D))),
                  ),
                );
              }),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class MatchWordGame extends StatefulWidget {
  const MatchWordGame({super.key});
  @override
  State<MatchWordGame> createState() => _MatchWordGameState();
}

class _MatchWordGameState extends _QuizState<MatchWordGame> {
  late WordExample target;
  late List<WordExample> options;
  late int correct;

  @override
  List<String> get questionSpeech =>
      [SpeechService.text.instruction(ChildInstruction.choose), target.word];

  @override
  void initState() {
    super.initState();
    nextQuestion();
  }

  @override
  void nextQuestion() {
    final pool = lessons
        .take(
            AppState.instance.unlockedLetters.clamp(4, lessons.length).toInt())
        .toList();
    final all = (AppState.instance.level == 'KG2'
            ? pool.expand((e) => e.examples)
            : pool.map((e) => e.examples.first))
        .toList();
    target = all[random.nextInt(all.length)];
    final rest = List<WordExample>.from(all.where((e) => e.word != target.word))
      ..shuffle(random);
    options = [target, ...rest.take(3)]..shuffle(random);
    correct = options.indexWhere((e) => e.word == target.word);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('طابق الكلمة')),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              header(),
              const SizedBox(height: 22),
              Text('اختار صورة كلمة «${target.word}»',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w900)),
              IconButton(
                  onPressed: replayQuestion,
                  icon: const Icon(Icons.volume_up_rounded, size: 33)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: List.generate(4, (i) {
                    final chosen = selected == i;
                    final right = i == correct;
                    return InkWell(
                      onTap: () async {
                        if (locked) return;
                        await choose(i, correct,
                            tappedText: options[i].word,
                            spokenAnswer: target.word);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: chosen
                                  ? (right ? Colors.green : Colors.red)
                                  : const Color(0xFFE5EDF4),
                              width: 4),
                        ),
                        child: KidImage(
                          asset: options[i].imageAsset,
                          emoji: options[i].emoji,
                          size: 110,
                          radius: 26,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
}

class ShadowMatchGame extends StatefulWidget {
  final ShadowMatchKind kind;
  const ShadowMatchGame({super.key, required this.kind});

  @override
  State<ShadowMatchGame> createState() => _ShadowMatchGameState();
}

class _ShadowMatchGameState extends State<ShadowMatchGame>
    with AutoSpeakPage<ShadowMatchGame> {
  static const total = 6;
  final random = Random();
  final rewards = RewardService();
  int question = 0;
  int firstTryScore = 0;
  bool hadMistake = false;
  bool locked = false;
  bool showSuccess = false;
  late MatchChoice target;
  late List<MatchChoice> options;

  @override
  Object get autoSpeechKey => question;
  @override
  bool get canAutoSpeak => !locked;
  List<String> get matchingSpeech => [
        if (question == 0) SpeechService.text.instruction(_matchingInstruction),
        target.spoken,
      ];
  @override
  Future<void> speakVisibleContent() =>
      SpeechService.speakQuestion(matchingSpeech);

  @override
  void initState() {
    super.initState();
    _prepareQuestion();
  }

  String get _title => switch (widget.kind) {
        ShadowMatchKind.animal => 'طابق الحيوان مع ظله 🐾',
        ShadowMatchKind.letter => 'طابق الحرف 🔠',
        ShadowMatchKind.number => 'طابق الرقم 🔟',
      };

  ChildInstruction get _matchingInstruction => switch (widget.kind) {
        ShadowMatchKind.animal => ChildInstruction.dragAnimal,
        ShadowMatchKind.letter => ChildInstruction.dragLetter,
        ShadowMatchKind.number => ChildInstruction.dragNumber,
      };
  String get _instruction =>
      SpeechService.text.instruction(_matchingInstruction);

  void _prepareQuestion() {
    final round = MatchingRound.generate(
        kind: widget.kind,
        kg2: AppState.instance.level == 'KG2',
        random: random,
        unlockedLetters: AppState.instance.unlockedLetters);
    target = round.target;
    options = round.options;
  }

  Future<void> _speakInstruction() =>
      SpeechService.speakQuestion(matchingSpeech, automatic: false);

  Future<void> _handleDrop(MatchChoice item) async {
    if (locked) return;
    final correct = item.id == target.id;
    setState(() => locked = true);
    await SpeechService.speak(item.spoken);

    if (!correct) {
      hadMistake = true;
      await AppState.instance.recordAnswer(false);
      await SpeechService.wrongAnswer();
      if (!mounted || !educationalPageVisible) return;
      setState(() => locked = false);
      return;
    }

    if (!hadMistake) firstTryScore++;
    final openedBox = await rewards.answer(question, true);
    if (mounted) setState(() => showSuccess = true);
    await SpeechService.correctAnswer(target: target.spoken);
    if (openedBox) await SpeechService.rewardBox();
    if (!mounted || !educationalPageVisible) return;

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted || !educationalPageVisible) return;

    if (question == total - 1) {
      final earned = firstTryScore >= 5
          ? 10
          : firstTryScore >= 3
              ? 7
              : 5;
      await rewards.finish(
          correct: firstTryScore, total: total, starsEarned: earned);
      if (!mounted || !educationalPageVisible) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('برافو! خلصت لعبة الظلال 🎉',
              textAlign: TextAlign.center),
          content: Text(
              'مطابقات من أول محاولة: $firstTryScore من $total\n+$earned نجوم ⭐',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('جميل!'))
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      question++;
      hadMistake = false;
      locked = false;
      showSuccess = false;
      _prepareQuestion();
    });
    autoSpeechContentChanged();
  }

  Widget _symbol(MatchChoice item, {bool shadow = false, double size = 86}) {
    if (item.imageAsset != null) {
      final image = Image.asset(item.imageAsset!,
          width: size,
          height: size,
          errorBuilder: (_, error, stack) =>
              Text(item.display, style: TextStyle(fontSize: size)));
      return shadow
          ? ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(Color(0xFF263238), BlendMode.srcIn),
              child: image)
          : image;
    }
    if (item.isEmoji) {
      final emoji = Text(item.display, style: TextStyle(fontSize: size));
      if (!shadow) return emoji;
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Color(0xFF263238), BlendMode.srcIn),
        child: Opacity(opacity: .78, child: emoji),
      );
    }
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF263238);
    return Text(
      item.display,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: shadow ? null : const Color(0xFF1677FF),
        foreground: shadow ? outline : null,
        shadows: shadow
            ? const [
                Shadow(
                    color: Colors.black26, blurRadius: 7, offset: Offset(0, 4))
              ]
            : null,
      ),
    );
  }

  Widget _draggableCard(MatchChoice item, {bool feedback = false}) => Material(
        color: Colors.transparent,
        child: Container(
          width: feedback ? 105 : 96,
          height: feedback ? 105 : 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDCE8F2), width: 3),
            boxShadow: feedback
                ? const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ]
                : null,
          ),
          child: _symbol(item, size: item.isEmoji ? 58 : 55),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(_title)),
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                      child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الجولة ${question + 1}/$total',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            Text('🪙 ${AppState.instance.coins}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                            value: (question + 1) / total,
                            minHeight: 9,
                            borderRadius: BorderRadius.circular(10)),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                                child: Text(_instruction,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900))),
                            IconButton.filledTonal(
                                onPressed: _speakInstruction,
                                icon: const Icon(Icons.volume_up_rounded)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        DragTarget<MatchChoice>(
                          key: const ValueKey('match-target'),
                          onWillAcceptWithDetails: (_) => !locked,
                          onAcceptWithDetails: (details) =>
                              _handleDrop(details.data),
                          builder: (context, candidateData, rejectedData) =>
                              GestureDetector(
                            onTap: locked
                                ? null
                                : () => SpeechService.speak(target.spoken),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 190,
                              height: 190,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: showSuccess
                                    ? const Color(0xFFE8FFF0)
                                    : const Color(0xFFF1F4F6),
                                borderRadius: BorderRadius.circular(36),
                                border: Border.all(
                                  color: showSuccess
                                      ? Colors.green
                                      : candidateData.isNotEmpty
                                          ? const Color(0xFF1677FF)
                                          : const Color(0xFFCFD8DC),
                                  width: 4,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Semantics(
                                    key: ValueKey('match-target-${target.id}'),
                                    label: target.spoken,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _symbol(target,
                                          shadow: !showSuccess,
                                          size: target.isEmoji ? 102 : 104),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(showSuccess ? 'صح! ✓' : 'ضعه هنا',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: showSuccess
                                              ? Colors.green
                                              : const Color(0xFF607D8B))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 14,
                          runSpacing: 14,
                          children: options.map((item) {
                            return Draggable<MatchChoice>(
                              key: ValueKey('choice-${item.id}'),
                              data: item,
                              onDragStarted: () =>
                                  SpeechService.speak(item.spoken),
                              maxSimultaneousDrags: locked ? 0 : 1,
                              feedback: _draggableCard(item, feedback: true),
                              childWhenDragging: Opacity(
                                  opacity: .3, child: _draggableCard(item)),
                              child: GestureDetector(
                                onTap: locked
                                    ? null
                                    : () => SpeechService.speak(item.spoken),
                                child: _draggableCard(item),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                            'لمس البطاقة لسماع اسمها • سحب البطاقة للمطابقة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF607D8B),
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                      ],
                    ),
                  )))),
        ),
      );
}
