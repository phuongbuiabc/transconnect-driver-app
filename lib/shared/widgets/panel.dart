import 'package:flutter/material.dart';

class Panel extends StatelessWidget {
  final Widget child;
  const Panel({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE5E5EA)),
    ),
    child: child,
  );
}
