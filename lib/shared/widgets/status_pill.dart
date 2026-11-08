import 'package:flutter/material.dart';

enum StatusTone { positive, waiting, negative, neutral }

class StatusPill extends StatelessWidget {
  final String label;
  final StatusTone tone;
  const StatusPill(this.label, {super.key, this.tone = StatusTone.neutral});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (background, foreground) = switch (tone) {
      StatusTone.positive =>
        dark
            ? (const Color(0xFF1E3A28), const Color(0xFFB5E8C4))
            : (const Color(0xFFE3F4E8), const Color(0xFF0F5132)),
      StatusTone.waiting =>
        dark
            ? (const Color(0xFF3D3214), const Color(0xFFF5DE9A))
            : (const Color(0xFFFFF4D6), const Color(0xFF5C4300)),
      StatusTone.negative =>
        dark
            ? (const Color(0xFF4A1C1E), const Color(0xFFFFC9C6))
            : (const Color(0xFFFDECEC), const Color(0xFF8A1116)),
      StatusTone.neutral => (
        Theme.of(context).colorScheme.surfaceContainerHigh,
        Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
