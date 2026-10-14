import 'package:flutter/material.dart';

class Notice extends StatelessWidget {
  final String text;
  final bool failure;
  const Notice(this.text, {super.key, this.failure = false});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: failure ? const Color(0xFFFDECEC) : const Color(0xFFFFF8E7),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      text,
      style: TextStyle(
        height: 1.5,
        color: failure ? const Color(0xFFB31016) : const Color(0xFF594100),
      ),
    ),
  );
}
