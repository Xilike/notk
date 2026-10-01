import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final name = TextEditingController();
  String gender = 'boy';
  String level = 'KG1';
  bool saving = false;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color(0xFF35BBF5),
                Color(0xFFF5FCFF),
                Color(0xFFFFE8A7)
              ])),
          child: SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    const SizedBox(height: 20),
                    Image.asset('assets/images/mascot.png',
                        height: 165,
                        errorBuilder: (_, __, ___) => const Text('🗣️⭐',
                            style: TextStyle(fontSize: 100))),
                    const Text('تأسيس النطق',
                        style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF123A67))),
                    const Text('رحلة ممتعة للحروف والأصوات والكلمات',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF375A78))),
                    const SizedBox(height: 24),
                    Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .92),
                            borderRadius: BorderRadius.circular(28)),
                        child: Column(children: [
                          const Align(
                              alignment: Alignment.centerRight,
                              child: Text('أنا...',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17))),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                  value: 'boy',
                                  icon: Text('👦',
                                      style: TextStyle(fontSize: 24)),
                                  label: Text('ولد')),
                              ButtonSegment(
                                  value: 'girl',
                                  icon: Text('👧',
                                      style: TextStyle(fontSize: 24)),
                                  label: Text('بنت')),
                            ],
                            selected: {gender},
                            onSelectionChanged: (s) =>
                                setState(() => gender = s.first),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                              controller: name,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                  labelText: gender == 'girl'
                                      ? 'اسم البطلة'
                                      : 'اسم البطل',
                                  prefixIcon: Icon(gender == 'girl'
                                      ? Icons.face_3_rounded
                                      : Icons.face_6_rounded),
                                  border: const OutlineInputBorder())),
                          const SizedBox(height: 16),
                          const Align(
                              alignment: Alignment.centerRight,
                              child: Text('المستوى',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17))),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'KG1', label: Text('KG1')),
                                ButtonSegment(value: 'KG2', label: Text('KG2'))
                              ],
                              selected: {
                                level
                              },
                              onSelectionChanged: (s) =>
                                  setState(() => level = s.first)),
                          const SizedBox(height: 18),
                          SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFB900)),
                                onPressed: saving
                                    ? null
                                    : () async {
                                        setState(() => saving = true);
                                        await AppState.instance
                                            .finishOnboarding(
                                                name.text, level, gender);
                                        if (!mounted) return;
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const HomeScreen()));
                                      },
                                child: const Text('يلا نبدأ 🚀',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF17365D))),
                              ))
                        ])),
                    const SizedBox(height: 18),
                    const Text(
                        'بدون إعلانات • التقدم والتسجيلات محفوظة على الجهاز',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF60758B))),
                  ]))),
        ),
      );
}
