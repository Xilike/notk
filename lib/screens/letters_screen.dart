import 'package:flutter/material.dart';
import '../data/lesson_data.dart';
import '../services/app_state.dart';
import '../services/recording_service.dart';
import '../services/speech_service.dart';
import '../widgets/ui.dart';
import '../widgets/auto_speak_page.dart';
import '../services/child_speech_text.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});
  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen>
    with AutoSpeakPage<LettersScreen> {
  @override
  Object get autoSpeechKey => 'letters';
  @override
  Future<void> speakVisibleContent() => SpeechService.speakScreenEntry([
        SpeechService.text.instruction(ChildInstruction.chooseLetter),
      ]);
  final state = AppState.instance;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('الحروف العربية',
                style: TextStyle(fontWeight: FontWeight.w900))),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const SectionTitle('اختار حرفًا',
                  subtitle: 'كل درس فيه صوت + 3 كلمات + تدريب بالنطق'),
              const SizedBox(height: 14),
              Expanded(
                  child: GridView.builder(
                      itemCount: lessons.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10),
                      itemBuilder: (context, i) {
                        final open = i < state.unlockedLetters;
                        final done = state.completedLetters.contains(i);
                        return InkWell(
                            onTap: open
                                ? () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                LetterLessonScreen(index: i)));
                                    if (mounted) setState(() {});
                                  }
                                : null,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: open
                                        ? const Color(0xFFFF5A67)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: open
                                            ? Colors.transparent
                                            : const Color(0xFFE1EAF2))),
                                child: Stack(children: [
                                  Center(
                                      child: Text(lessons[i].letter,
                                          style: TextStyle(
                                              fontSize: 38,
                                              fontWeight: FontWeight.w900,
                                              color: open
                                                  ? Colors.white
                                                  : const Color(0xFF91A0B2)))),
                                  Positioned(
                                      left: 5,
                                      bottom: 4,
                                      child: Text(
                                          done
                                              ? '⭐'
                                              : open
                                                  ? '▶️'
                                                  : '🔒',
                                          style: const TextStyle(fontSize: 14)))
                                ])));
                      }))
            ])),
      );
}

class LetterLessonScreen extends StatefulWidget {
  final int index;
  const LetterLessonScreen({super.key, required this.index});
  @override
  State<LetterLessonScreen> createState() => _LetterLessonScreenState();
}

class _LetterLessonScreenState extends State<LetterLessonScreen>
    with AutoSpeakPage<LetterLessonScreen> {
  final recording = RecordingService();
  int page = 0;
  bool isRecording = false;
  bool recordingBusy = false;
  bool completing = false;

  @override
  Object get autoSpeechKey => (widget.index, page);
  @override
  bool get canAutoSpeak => !completing && !isRecording && !recordingBusy;
  @override
  Future<void> speakVisibleContent() {
    final lesson = lessons[widget.index];
    return SpeechService.speakLessonTarget(
        lesson.soundCue, lesson.examples[page].word);
  }

  void showExample(int value) {
    setState(() => page = value);
    autoSpeechContentChanged();
  }

  Future<void> toggleRecord() async {
    if (recordingBusy) return;
    recordingBusy = true;
    try {
      if (isRecording) {
        await recording.stop();
        if (mounted) setState(() => isRecording = false);
        return;
      }
      final ok = await recording.start('${widget.index}_$page');
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
  void dispose() {
    recording.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = lessons[widget.index];
    final examples = AppState.instance.level == 'KG1'
        ? lesson.examples.take(2).toList()
        : lesson.examples;
    if (page >= examples.length) page = examples.length - 1;
    final ex = examples[page];
    return Scaffold(
      appBar: AppBar(
          title: Text('حرف ${lesson.letter}',
              style: const TextStyle(fontWeight: FontWeight.w900))),
      body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            LinearProgressIndicator(
                value: (page + 1) / examples.length,
                minHeight: 9,
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFF5966)),
            const SizedBox(height: 15),
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
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => SpeechService.speak(lesson.soundCue),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 8),
                              child: Text(lesson.letter,
                                  style: const TextStyle(
                                      fontSize: 115,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFFF5361),
                                      height: .95)),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => SpeechService.speak(ex.word),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 8),
                              child: Column(children: [
                                Text(ex.emoji,
                                    style: const TextStyle(fontSize: 78)),
                                Text(ex.word,
                                    style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF17365D))),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('صوت الحرف: ${lesson.soundCue}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF59718A))),
                          const SizedBox(height: 22),
                          Wrap(
                              spacing: 18,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                _action(
                                    Icons.volume_up_rounded,
                                    const Color(0xFF248FF0),
                                    'استمع',
                                    () => SpeechService.speakLessonTarget(
                                        lesson.soundCue, ex.word,
                                        automatic: false)),
                                _action(
                                    isRecording
                                        ? Icons.stop_rounded
                                        : Icons.mic_rounded,
                                    const Color(0xFFFF4F5E),
                                    isRecording ? 'إيقاف' : 'سجّل',
                                    toggleRecord),
                                _action(
                                    Icons.play_arrow_rounded,
                                    const Color(0xFF35B96A),
                                    'اسمع نفسك', () async {
                                  final ok = await recording.playLast();
                                  if (!ok && mounted) {
                                    snack(context, 'سجّل صوتك الأول 🎙️');
                                  }
                                }),
                              ]),
                          if (isRecording)
                            const Padding(
                                padding: EdgeInsets.only(top: 14),
                                child: Text('🎙️ جاري التسجيل...',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w900)))
                        ]))),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: page > 0 && !isRecording && !recordingBusy
                          ? () => showExample(page - 1)
                          : null,
                      child: const Text('السابق'))),
              const SizedBox(width: 10),
              Expanded(
                  flex: 2,
                  child: FilledButton(
                      onPressed: () async {
                        if (recordingBusy || isRecording || completing) return;
                        if (page < examples.length - 1) {
                          showExample(page + 1);
                          return;
                        }
                        if (completing) return;
                        setState(() => completing = true);
                        await AppState.instance.completeLetter(widget.index);
                        if (!mounted) return;
                        await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                    title: const Text('اكتمل الدرس 🎉',
                                        textAlign: TextAlign.center),
                                    content: const Text(
                                        'أنهيت الدرس وحصلت على 10 نجوم ⭐',
                                        textAlign: TextAlign.center),
                                    actions: [
                                      FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('تمام'))
                                    ]));
                        if (mounted) Navigator.pop(context);
                      },
                      child: Text(
                          page < examples.length - 1
                              ? 'التالي'
                              : 'أنهيت الدرس ⭐',
                          style: const TextStyle(fontWeight: FontWeight.w900))))
            ])
          ])),
    );
  }

  Widget _action(
          IconData icon, Color color, String label, VoidCallback onTap) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        IconButton.filled(
            style: IconButton.styleFrom(
                backgroundColor: color, minimumSize: const Size(64, 64)),
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white, size: 33)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold))
      ]);
}
