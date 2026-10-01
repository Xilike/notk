import 'dart:math';
import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/speech_service.dart';

class ParentGate extends StatefulWidget {
  const ParentGate({super.key});
  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate> {
  final input = TextEditingController();
  late final int a, b;
  String? error;
  @override
  void initState() {
    super.initState();
    final r = Random();
    a = 4 + r.nextInt(5);
    b = 3 + r.nextInt(5);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title:
            const Text('لولي الأمر فقط 👨‍👩‍👦', textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('حل المسألة البسيطة للمتابعة',
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('$a + $b = ؟',
              style:
                  const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          TextField(
              controller: input,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: 'الإجابة',
                  errorText: error,
                  border: const OutlineInputBorder()))
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () {
                if (int.tryParse(input.text) == a + b) {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ParentDashboardScreen()));
                } else {
                  setState(() => error = 'الإجابة غير صحيحة');
                }
              },
              child: const Text('دخول'))
        ],
      );
}

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});
  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final state = AppState.instance;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('منطقة ولي الأمر',
                style: TextStyle(fontWeight: FontWeight.w900))),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                      radius: 28,
                      child: Text(state.childGender == 'girl' ? '👧' : '👦',
                          style: const TextStyle(fontSize: 30))),
                  title: Text(state.childName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900)),
                  subtitle: Text('${state.level} • رحلة تأسيس النطق'),
                  trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditChildScreen()))
                          .then((_) => setState(() {}))))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _metric(
                    '⭐', 'النجوم', '${state.stars}', const Color(0xFFFFB700))),
            const SizedBox(width: 10),
            Expanded(
                child: _metric(
                    '🪙', 'العملات', '${state.coins}', const Color(0xFFFFA000)))
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _metric('🎁', 'الصناديق', '${state.rewardBoxes}',
                    const Color(0xFF35C86A))),
            const SizedBox(width: 10),
            Expanded(
                child: _metric('🔥', 'الاستمرار', '${state.streak} يوم',
                    const Color(0xFFFF7043)))
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _metric(
                    '🔤',
                    'الحروف',
                    '${state.completedLetters.length}/28',
                    const Color(0xFFFF5361))),
            const SizedBox(width: 10),
            Expanded(
                child: _metric('⏱️', 'اليوم', '${state.dailyMinutes} دقيقة',
                    const Color(0xFF7A5AE0)))
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _metric('🎮', 'جولات اللعب', '${state.gameRounds}',
                    const Color(0xFFFF5CB7))),
            const SizedBox(width: 10),
            Expanded(
                child: _metric('🎙️', 'محاولات النطق',
                    '${state.repeatAttempts}', const Color(0xFF25A5E8)))
          ]),
          const SizedBox(height: 10),
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(22)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('أداء الألعاب',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 17)),
                          Text('${state.gameAccuracy}% دقة',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF25A5E8)))
                        ]),
                    const SizedBox(height: 9),
                    LinearProgressIndicator(
                        value: state.gameAccuracy / 100,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10))
                  ])),
          const SizedBox(height: 18),
          const Text('نشاط آخر 7 أيام',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _weeklyChart(),
          const SizedBox(height: 20),
          const Text('الهدف اليومي',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Slider(
              value: state.dailyGoalMinutes.toDouble(),
              min: 5,
              max: 30,
              divisions: 5,
              label: '${state.dailyGoalMinutes} دقيقة',
              onChanged: (v) =>
                  setState(() => state.dailyGoalMinutes = v.round()),
              onChangeEnd: (v) => state.setDailyGoal(v.round())),
          Text('الهدف الحالي: ${state.dailyGoalMinutes} دقيقة يوميًا',
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          SwitchListTile(
              value: state.soundEnabled,
              onChanged: (v) async {
                await state.setSound(v);
                setState(() {});
              },
              secondary: const Icon(Icons.volume_up_rounded),
              title: const Text('تشغيل أصوات التعلم'),
              subtitle: const Text('يمكن إيقاف النطق والمؤثرات من هنا')),
          SwitchListTile(
            value: state.autoSpeakEnabled,
            onChanged: (value) async {
              await state.setAutoSpeak(value);
              if (mounted) setState(() {});
            },
            secondary: const Icon(Icons.play_circle_outline_rounded),
            title: const Text('النطق التلقائي'),
            subtitle: const Text(
                'نطق الدرس والسؤال عند ظهورهما، مع بقاء النطق باللمس'),
          ),
          ListTile(
            leading: const Icon(Icons.record_voice_over_rounded,
                color: Color(0xFF1677FF)),
            title: const Text('اختبار صيغة الصوت',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                'الصيغة الحالية: ${state.childGender == 'girl' ? 'بنت 👧' : 'ولد 👦'}'),
            trailing: const Icon(Icons.play_circle_fill_rounded),
            onTap: () => SpeechService.speakCorrectFeedback(),
          ),
          const Divider(height: 28),
          const ListTile(
              leading: Icon(Icons.privacy_tip_rounded, color: Colors.green),
              title: Text('الخصوصية',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'لا توجد إعلانات أو تحليلات في هذه النسخة. التقدم والتسجيلات محفوظة محليًا على الجهاز.')),
          ListTile(
              leading: const Icon(Icons.restart_alt_rounded, color: Colors.red),
              title: const Text('إعادة ضبط التقدم',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text('يحذف النجوم والدروس والإحصائيات التعليمية'),
              onTap: () => _confirmReset(context)),
        ]),
      );

  Widget _weeklyChart() {
    final now = DateTime.now();
    const names = ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];
    final days = List<DateTime>.generate(
        7,
        (i) => DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - i)));
    final values = days.map(state.minutesForDate).toList();
    final maxValue =
        [state.dailyGoalMinutes, ...values].reduce((a, b) => a > b ? a : b);
    return Container(
        height: 150,
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final value = values[i];
              final height = 18 + (value / maxValue) * 75;
              return Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                    Text('$value',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                            color: value >= state.dailyGoalMinutes
                                ? const Color(0xFF35C86A)
                                : const Color(0xFF7A5AE0),
                            borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 5),
                    Text(names[days[i].weekday - 1],
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ]));
            })));
  }

  Widget _metric(String emoji, String title, String value, Color color) =>
      Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: color))
          ]));

  Future<void> _confirmReset(BuildContext context) async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('إعادة ضبط التقدم؟'),
                content: const Text(
                    'سيتم حذف التقدم والنجوم وإحصائيات اللعب والنطق. اسم الطفل والإعدادات سيظلان محفوظين.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء')),
                  FilledButton(
                      style:
                          FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('إعادة الضبط'))
                ]));
    if (yes == true) {
      await state.resetProgress();
      if (mounted) setState(() {});
    }
  }
}

class EditChildScreen extends StatefulWidget {
  const EditChildScreen({super.key});
  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  late final TextEditingController name =
      TextEditingController(text: AppState.instance.childName);
  String gender = AppState.instance.childGender;
  String level = AppState.instance.level;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('بيانات الطفل')),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              CircleAvatar(
                  radius: 45,
                  child: Text(gender == 'girl' ? '👧' : '👦',
                      style: const TextStyle(fontSize: 48))),
              const SizedBox(height: 20),
              TextField(
                  controller: name,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                      labelText: 'اسم الطفل', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              SegmentedButton<String>(segments: const [
                ButtonSegment(
                    value: 'boy', icon: Text('👦'), label: Text('ولد')),
                ButtonSegment(
                    value: 'girl', icon: Text('👧'), label: Text('بنت'))
              ], selected: {
                gender
              }, onSelectionChanged: (s) => setState(() => gender = s.first)),
              const SizedBox(height: 16),
              SegmentedButton<String>(segments: const [
                ButtonSegment(value: 'KG1', label: Text('KG1')),
                ButtonSegment(value: 'KG2', label: Text('KG2'))
              ], selected: {
                level
              }, onSelectionChanged: (s) => setState(() => level = s.first)),
              const Spacer(),
              SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setState(() => saving = true);
                              await AppState.instance.setGender(gender);
                              await AppState.instance.setChildName(name.text);
                              await AppState.instance.setLevel(level);
                              if (mounted) Navigator.pop(context);
                            },
                      child: const Text('حفظ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900))))
            ])),
      );
}
