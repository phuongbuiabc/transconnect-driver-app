import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/core/theme/app_colors.dart';

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        backgroundColor: red,
        child: Icon(Icons.route, color: gold),
      ),
      SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TransConnect',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          Text(
            'DRIVER',
            style: TextStyle(fontSize: 10, letterSpacing: 3, color: red),
          ),
        ],
      ),
    ],
  );
}
