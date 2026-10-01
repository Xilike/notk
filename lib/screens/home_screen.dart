import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/ui.dart';
import 'achievements_screen.dart';
import 'games_screens.dart';
import 'letters_screen.dart';
import 'parent_screens.dart';
import 'practice_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final state = AppState.instance;
  late final VoidCallback listener;
  @override
  void initState() {
    super.initState();
    listener = () => mounted ? setState(() {}) : null;
    state.addListener(listener);
  }

  @override
  void dispose() {
    state.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <({String title, IconData icon, Color color, Widget page})>[
      (
        title: 'الحروف',
        icon: Icons.abc_rounded,
        color: const Color(0xFFFF5361),
        page: const LettersScreen()
      ),
      (
        title: 'الأصوات',
        icon: Icons.volume_up_rounded,
        color: const Color(0xFFFFBC22),
        page: const WordCarouselScreen(mode: PracticeMode.sounds)
      ),
      (
        title: 'الكلمات',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF35C86A),
        page: const WordCarouselScreen(mode: PracticeMode.words)
      ),
      (
        title: 'اسمع وكرر',
        icon: Icons.mic_rounded,
        color: const Color(0xFF7957DE),
        page: const RepeatPracticeScreen()
      ),
      (
        title: 'ألعاب تعليمية',
        icon: Icons.sports_esports_rounded,
        color: const Color(0xFFFF5CB7),
        page: const GamesHubScreen()
      ),
      (
        title: 'إنجازاتي',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFF288CF0),
        page: const AchievementsScreen()
      ),
    ];
    final progress = state.completedLetters.length / 28;
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Column(children: [
                  Row(children: [
                    CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFE9F7FF),
                        child: Text(state.childGender == 'girl' ? '👧' : '👦',
                            style: const TextStyle(fontSize: 29))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('أهلًا يا ${state.childName} 👋',
                              style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF17365D))),
                          const Text('جاهز نكسب نجوم جديدة؟')
                        ])),
                    Column(children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFF0B8),
                              borderRadius: BorderRadius.circular(18)),
                          child: Text('⭐ ${state.stars}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900))),
                      const SizedBox(height: 4),
                      Text('🪙 ${state.coins}  🎁 ${state.rewardBoxes}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w900)),
                    ]),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const ParentGate()),
                        icon: const Icon(Icons.settings_rounded)),
                  ]),
                  const SizedBox(height: 18),
                  Expanded(
                      child: GridView.builder(
                          itemCount: items.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.05),
                          itemBuilder: (context, i) {
                            final x = items[i];
                            return KidCard(
                                color: x.color,
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => x.page));
                                  setState(() {});
                                },
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(x.icon,
                                          size: 56, color: Colors.white),
                                      const SizedBox(height: 10),
                                      Text(x.title,
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white))
                                    ]));
                          })),
                  const SizedBox(height: 10),
                  Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(23)),
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('تقدمي في الحروف',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w900)),
                              Text('${state.completedLetters.length} / 28')
                            ]),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(12)),
                        const SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('🔥 ${state.streak} يوم'),
                              Text(
                                  '⏱️ ${state.dailyMinutes}/${state.dailyGoalMinutes} دقيقة')
                            ])
                      ]))
                ]))));
  }
}
