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
    final items = <({String title, IconData icon, Widget page})>[
      (
        title: 'الحروف',
        icon: Icons.abc_rounded,
        page: const LettersScreen()
      ),
      (
        title: 'الأصوات',
        icon: Icons.volume_up_rounded,
        page: const WordCarouselScreen(mode: PracticeMode.sounds)
      ),
      (
        title: 'الكلمات',
        icon: Icons.menu_book_rounded,
        page: const WordCarouselScreen(mode: PracticeMode.words)
      ),
      (
        title: 'اسمع وكرر',
        icon: Icons.mic_rounded,
        page: const RepeatPracticeScreen()
      ),
      (
        title: 'ألعاب تعليمية',
        icon: Icons.sports_esports_rounded,
        page: const GamesHubScreen()
      ),
      (
        title: 'إنجازاتي',
        icon: Icons.emoji_events_rounded,
        page: const AchievementsScreen()
      ),
    ];
    final progress = state.completedLetters.length / 28;
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Column(
              children: [
                // Greeting header with mascot
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.asset(
                          'assets/images/mascot.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            state.childGender == 'girl' ? '👧' : '👦',
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أهلًا يا ${state.childName} 👋',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                            ),
                          ),
                          const Text(
                            'جاهز نكسب نجوم جديدة؟',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        KidBadge('⭐ ${state.stars}'),
                        const SizedBox(height: 5),
                        Text(
                          '🪙 ${state.coins}   🎁 ${state.rewardBoxes}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const ParentGate(),
                      ),
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.04,
                    ),
                    itemBuilder: (context, i) {
                      final x = items[i];
                      return KidCard(
                        gradient: AppColors.sectionGradients[i],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => x.page),
                          );
                          setState(() {});
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .28),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Icon(
                                x.icon,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              x.title,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Progress card
                KidCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Text('⭐',
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(width: 6),
                              Text(
                                'مستواي في الحروف',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${state.completedLetters.length} / 28',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor:
                              const Color(0xFFE8F0F7),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.yellow,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          KidBadge(
                            '🔥 ${state.streak} يوم',
                            bg: const Color(0xFFFFE4DE),
                          ),
                          KidBadge(
                            '⏱️ ${state.dailyMinutes}/${state.dailyGoalMinutes} دقيقة',
                            bg: const Color(0xFFE3F4FF),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
