import 'package:flutter/material.dart';

class KidCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  const KidCard(
      {super.key, required this.child, this.color = Colors.white, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: .18),
                  blurRadius: 14,
                  offset: const Offset(0, 7))
            ],
          ),
          child: child,
        ),
      );
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
                color: Color(0xFF17365D))),
        if (subtitle != null)
          Text(subtitle!,
              style: const TextStyle(fontSize: 15, color: Color(0xFF66768A))),
      ]);
}

void snack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, textDirection: TextDirection.rtl)));
}
