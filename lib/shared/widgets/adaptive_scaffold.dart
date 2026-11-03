import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<NavigationDestination> destinations;
  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final expanded = constraints.maxWidth >= 720;
      return Scaffold(
        body: Row(
          children: [
            if (expanded)
              SafeArea(
                child: NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final destination in destinations)
                      NavigationRailDestination(
                        icon: destination.icon,
                        label: Text(destination.label),
                      ),
                  ],
                ),
              ),
            Expanded(child: body),
          ],
        ),
        bottomNavigationBar: expanded
            ? null
            : SafeArea(
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onSelected,
                  destinations: destinations,
                ),
              ),
      );
    },
  );
}
