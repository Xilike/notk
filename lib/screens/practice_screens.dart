import 'package:flutter/material.dart';
import '../data/lesson_data.dart';
import '../services/app_state.dart';
import '../services/recording_service.dart';
import '../services/speech_service.dart';
import '../widgets/ui.dart';
import '../widgets/auto_speak_page.dart';

enum PracticeMode { sounds, words }

class WordCarouselScreen extends StatefulWidget {
  final PracticeMode mode;
  const WordCarouselScreen({super.key, required this.mode});
  @override
  State<WordCarouselScreen> createState() => _WordCarouselScreenState();
}

class _WordCarouselScreenState extends State<WordCarouselScreen>
    with AutoSpeakPage<WordCarouselScreen> {
  int index = 0;

  @override
  Object get autoSpeechKey => (widget.mode, index);
  @override
  Future<void> speakVisibleContent() {
    if (widget.mode == PracticeMode.sounds) {
      final state = AppState.instance;
      final forms = state.level == 'KG2'
          ? lessons.expand((e) => shortVowelForms(e.letter)).toList()
          : lessons.map((e) => e.soundCue).toList();
      return SpeechService.speakScreenEntry([forms[index]]);
    }
    final examples = AppState.instance.level == 'KG2'
        ? lessons.expand((e) => e.examples).toList()
        : lessons.map((e) => e.examples.first).toList();
    return SpeechService.speakScreenEntry([examples[index].word]);
  }

  void showItem(int value) {
    setState(() => index = value);
    autoSpeechContentChanged();
  }

  @override
  Widget build(BuildContext context) {
    final isSound = widget.mode == PracticeMode.sounds;
    final state = AppState.instance;
    final wordItems = state.level == 'KG2'
        ? lessons
            .expand((lesson) => lesson.examples
                .map((example) => (lesson: lesson, example: example)))
            .toList()
        : lessons
            .map((lesson) => (lesson: lesson, example: lesson.examples.first))
            .toList();
    final soundItems = state.level == 'KG2'
        ? lessons
            .expand((lesson) => shortVowelForms(lesson.letter)
                .asMap()
                .entries
                .map((entry) => (
                      lesson: lesson,
                      form: entry.value,
                      vowel: shortVowelNames[entry.key]
                    )))
            .toList()
        : lessons
            .map((lesson) => (
                  lesson: lesson,
                  form: shortVowelForms(lesson.letter).first,
                  vowel: shortVowelNames.first
                ))
            .toList();
    final lesson = isSound ? soundItems[index].lesson : wordItems[index].lesson;
    final ex = isSound ? lesson.examples.first : wordItems[index].example;
    final soundForm = isSound ? soundItems[index].form : lesson.soundCue;
    final vowelName = isSound ? soundItems[index].vowel : '';
    final total = isSound ? soundItems.length : wordItems.length;
    final color = isSound ? const Color(0xFFFFB622) : const Color(0xFF35C86A);
    final spoken = isSound ? soundForm : ex.word;

    return Scaffold(
      appBar: AppBar(
          title: Text(isSound ? 'الأصوات' : 'الكلمات',
              style: const TextStyle(fontWeight: FontWeight.w900))),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            LinearProgressIndicator(
                value: (index + 1) / total,
                minHeight: 9,
                color: color,
                borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // V1.5: لمس الحرف/الصورة/الكلمة نفسها ينطقها فورًا.
                    InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => SpeechService.speak(spoken),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 34, vertical: 20),
                        child: Column(
                          children: [
                            Text(
                              isSound ? soundForm : ex.emoji,
                              style: TextStyle(
                                  fontSize: isSound ? 130 : 105,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF17365D)),
                            ),
                            if (isSound)
                              Text(vowelName,
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: color)),
                            if (isSound)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('الحرف ${lesson.letter}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.bold)),
                              ),
                            if (!isSound)
                              Text(ex.word,
                                  style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                          backgroundColor: color,
                          minimumSize: const Size(82, 82)),
                      onPressed: () => SpeechService.speak(spoken),
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Colors.white, size: 43),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        isSound
                            ? 'المس الحرف أو اضغط واسمع'
                            : 'المس الصورة أو الكلمة واسمع',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: index > 0 ? () => showItem(index - 1) : null,
                        child: const Text('السابق'))),
                const SizedBox(width: 10),
                Expanded(
                    child: FilledButton(
                        onPressed: index < total - 1
                            ? () => showItem(index + 1)
                            : () => Navigator.pop(context),
                        child: Text(index < total - 1 ? 'التالي' : 'تم ⭐'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RepeatPracticeScreen extends StatefulWidget {
  const RepeatPracticeScreen({super.key});
  @override
  State<RepeatPracticeScreen> createState() => _RepeatPracticeScreenState();
}

class _RepeatPracticeScreenState extends State<RepeatPracticeScreen>
    with AutoSpeakPage<RepeatPracticeScreen> {
  final recording = RecordingService();
  int index = 0;
  bool isRecording = false;
  bool recordingBusy = false;
  int repeats = 0;
  bool changingWord = false;

  @override
  Object get autoSpeechKey => index;
  @override
  bool get canAutoSpeak => !isRecording && !recordingBusy;
  @override
  Future<void> speakVisibleContent() {
    final items = AppState.instance.level == 'KG2'
        ? lessons.expand((e) => e.examples).toList()
        : lessons.map((e) => e.examples.first).toList();
    return SpeechService.speakScreenEntry([items[index % items.length].word]);
  }

  @override
  void dispose() {
    recording.dispose();
    super.dispose();
  }

  Future<void> toggle() async {
    if (recordingBusy) return;
    recordingBusy = true;
    try {
      if (isRecording) {
        await recording.stop();
        await AppState.instance.recordRepeatAttempt();
        if (mounted) {
          setState(() {
            isRecording = false;
            repeats++;
          });
        }
        return;
      }
      final ok = await recording.start('repeat_$index');
      if (!mounted) return;
      if (!ok) {
        snack(context, 'اسمح للتطبيق باستخدام الميكروفون');
        return;
      }
      setState(() => isRecording = true);
    } finally {
      recordingBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final items = state.level == 'KG2'
        ? lessons.expand((lesson) => lesson.examples).toList()
        : lessons.map((lesson) => lesson.examples.first).toList();
    final ex = items[index % items.length];
    return Scaffold(
      appBar: AppBar(
          title: const Text('اسمع وكرر',
              style: TextStyle(fontWeight: FontWeight.w900))),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SectionTitle('اسمعها… وبعدها قولها',
                subtitle: 'اسمع النموذج، سجّل صوتك، ثم اسمع نفسك'),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => SpeechService.speak(ex.word),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 34, vertical: 16),
                        child: Column(
                          children: [
                            Text(ex.emoji,
                                style: const TextStyle(fontSize: 110)),
                            Text(ex.word,
                                style: const TextStyle(
                                    fontSize: 43, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _circle(Icons.volume_up_rounded, Colors.blue, 'استمع',
                            () => SpeechService.speak(ex.word)),
                        _circle(
                            isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            Colors.red,
                            isRecording ? 'إيقاف' : 'سجّل',
                            toggle),
                        _circle(Icons.play_arrow_rounded, Colors.green, 'صوتي',
                            () async {
                          if (!await recording.playLast() && mounted) {
                            snack(context, 'سجّل صوتك الأول');
                          }
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('محاولاتك: $repeats ⭐',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () async {
                  if (changingWord || isRecording || recordingBusy) return;
                  changingWord = true;
                  await AppState.instance.addLearningMinute();
                  if (!mounted) return;
                  setState(() {
                    changingWord = false;
                    index = (index + 1) % items.length;
                    repeats = 0;
                  });
                  autoSpeechContentChanged();
                },
                child: const Text('كلمة جديدة ➜',
                    style:
                        TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(IconData i, Color c, String t, VoidCallback f) => Column(
        children: [
          IconButton.filled(
              style: IconButton.styleFrom(
                  backgroundColor: c, minimumSize: const Size(70, 70)),
              onPressed: f,
              icon: Icon(i, color: Colors.white, size: 35)),
          Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
}
