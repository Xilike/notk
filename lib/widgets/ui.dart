import 'package:flutter/material.dart';

/// Design tokens for the "تأسيس النطق" kid-friendly theme v2.
/// Bright, rounded, high-contrast — based on the approved design reference.
class AppColors {
  static const navy = Color(0xFF17365D);
  static const muted = Color(0xFF66768A);

  static const skyTop = Color(0xFFE3F4FF);
  static const skyBottom = Color(0xFFF7FCFF);

  static const red = Color(0xFFFF5361);
  static const redDark = Color(0xFFE63E4C);
  static const yellow = Color(0xFFFFBC22);
  static const green = Color(0xFF35C86A);
  static const greenDark = Color(0xFF1FA84F);
  static const purple = Color(0xFF7957DE);
  static const pink = Color(0xFFFF5CB7);
  static const blue = Color(0xFF288CF0);

  static const cardBorder = Color(0xFFE1EAF2);

  /// Section gradient pairs used across the home grid.
  static const sectionGradients = <List<Color>>[
    [Color(0xFFFF6B76), Color(0xFFFF3D5A)], // الحروف
    [Color(0xFFFFC93D), Color(0xFFFF9F1A)], // الأصوات
    [Color(0xFF3ED598), Color(0xFF1FA84F)], // الكلمات
    [Color(0xFF9B7BF0), Color(0xFF6C4FD8)], // اسمع وكرر
    [Color(0xFFFF7EB8), Color(0xFFFF4F9A)], // ألعاب
    [Color(0xFF4FACFE), Color(0xFF1E88F0)], // إنجازاتي
  ];
}

/// Sky gradient background used by the main kid screens.
class SkyBackground extends StatelessWidget {
  final Widget child;
  const SkyBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyTop, AppColors.skyBottom],
          ),
        ),
        child: child,
      );
}

/// Big rounded card. Supports solid color or gradient with a soft shadow.
class KidCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final List<Color>? gradient;
  final VoidCallback? onTap;
  final double radius;
  final EdgeInsetsGeometry? padding;
  const KidCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.gradient,
    this.onTap,
    this.radius = 28,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final shadowColor = (gradient?.last ?? color).withValues(alpha: .22);
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient == null
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient!,
                ),
          borderRadius: BorderRadius.circular(radius),
          border: gradient == null
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Big pill button with gradient, for primary kid actions.
class KidButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final List<Color> gradient;
  final IconData? icon;
  const KidButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient = const [AppColors.green, AppColors.greenDark],
    this.icon,
  });
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onPressed == null ? .45 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: gradient.last.withValues(alpha: .35),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Round action button (listen / record / play) with label underneath.
class KidActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool busy;
  const KidActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.busy = false,
  });
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: color,
            borderRadius: BorderRadius.circular(26),
            elevation: 6,
            shadowColor: color.withValues(alpha: .4),
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: busy ? null : onTap,
              child: SizedBox(
                width: 68,
                height: 68,
                child: Icon(icon, color: Colors.white, size: 34),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.navy,
            ),
          ),
        ],
      );
}

/// Shows a bundled illustration when available, otherwise falls back to emoji.
/// Used everywhere pictures of words/animals appear.
class KidImage extends StatelessWidget {
  final String? asset;
  final String emoji;
  final double size;
  final double radius;
  const KidImage({
    super.key,
    this.asset,
    required this.emoji,
    this.size = 80,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (asset == null || asset!.isEmpty) {
      return Text(emoji, style: TextStyle(fontSize: size));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        asset!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Text(emoji, style: TextStyle(fontSize: size)),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionTitle(this.title, {super.key, this.subtitle});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.navy)),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle!,
                style: const TextStyle(fontSize: 15, color: AppColors.muted)),
          ),
      ]);
}

/// Pill badge for stars / coins / streak.
class KidBadge extends StatelessWidget {
  final String text;
  final Color bg;
  const KidBadge(this.text, {super.key, this.bg = const Color(0xFFFFF0B8)});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: AppColors.navy,
          ),
        ),
      );
}

void snack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, textDirection: TextDirection.rtl)));
}
