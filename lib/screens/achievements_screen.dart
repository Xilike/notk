import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/ui.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final badges = <({String emoji, String title, bool unlocked})>[
      (emoji: '🌟', title: 'أول درس', unlocked: s.completedLetters.isNotEmpty),
      (emoji: '🔥', title: '5 حروف', unlocked: s.completedLetters.length >= 5),
      (
        emoji: '🏆',
        title: '10 حروف',
        unlocked: s.completedLetters.length >= 10
      ),
      (
        emoji: '👑',
        title: 'كل الحروف',
        unlocked: s.completedLetters.length == 28
      ),
      (emoji: '💯', title: '100 نجمة', unlocked: s.stars >= 100),
      (emoji: '📚', title: 'مثابر', unlocked: s.streak >= 3),
      (emoji: '🎮', title: '5 جولات', unlocked: s.gameRounds >= 5),
      (emoji: '🎙️', title: '10 محاولات نطق', unlocked: s.repeatAttempts >= 10),
      (emoji: '🪙', title: '25 عملة', unlocked: s.coins >= 25),
      (emoji: '🎁', title: '3 صناديق', unlocked: s.rewardBoxes >= 3),
    ];
    return Scaffold(
        appBar: AppBar(
            title: const Text('إنجازاتي',
                style: TextStyle(fontWeight: FontWeight.w900))),
        body: SkyBackground(
          child: ListView(padding: const EdgeInsets.all(18), children: [
            Center(
                child: Image.asset('assets/images/trophy.png',
                    height: 120,
                    errorBuilder: (_, __, ___) =>
                        const Text('🏆', style: TextStyle(fontSize: 90)))),
            Center(
                child: Text(
                    '${s.stars} نجمة • ${s.coins} عملة • ${s.rewardBoxes} صندوق',
                    style: const TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF17365D)))),
            const SizedBox(height: 20),
            _progress('الحروف', '${s.completedLetters.length}/28',
                s.completedLetters.length / 28, const Color(0xFFFF5664)),
            _progress(
                'هدف اليوم',
                '${s.dailyMinutes}/${s.dailyGoalMinutes} دقيقة',
                (s.dailyMinutes / s.dailyGoalMinutes).clamp(0, 1).toDouble(),
                const Color(0xFF7A5AE0)),
            const SizedBox(height: 8),
            _progress('دقة الألعاب', '${s.gameAccuracy}%', s.gameAccuracy / 100,
                const Color(0xFF25A5E8)),
            const SizedBox(height: 18),
            const SectionTitle('شاراتي', subtitle: 'كل إنجاز بيفتح شارة جديدة'),
            const SizedBox(height: 12),
            GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: badges.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: .86),
                itemBuilder: (c, i) {
                  final b = badges[i];
                  return Container(
                      decoration: BoxDecoration(
                          color: b.unlocked
                              ? const Color(0xFFFFF5C8)
                              : const Color(0xFFF0F3F6),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(b.unlocked ? b.emoji : '🔒',
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 6),
                            Text(b.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: b.unlocked
                                        ? const Color(0xFF17365D)
                                        : Colors.grey))
                          ]));
                })
          ]),
        ));
  }

  Widget _progress(String title, String value, double progress, Color color) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: KidCard(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(value,
                  style: TextStyle(fontWeight: FontWeight.w900, color: color))
            ]),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                  value: progress, minHeight: 10, color: color),
            )
          ]),
        ),
      );
}
