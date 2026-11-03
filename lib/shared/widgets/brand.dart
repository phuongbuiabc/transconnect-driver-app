import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/shared/theme/app_colors.dart';

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const CircleAvatar(
        backgroundColor: red,
        child: Icon(Icons.route, color: gold),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VieGo',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          Text(
            'DRIVER',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    ],
  );
}
