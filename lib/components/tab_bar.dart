import 'package:flutter/material.dart';

class MyTabBar extends StatelessWidget {
  const MyTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabs: [
        Tab(
          icon: Icon(
            Icons.home_rounded,
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 32,
          ),
        ),
        Tab(
          icon: Icon(
            Icons.dashboard_rounded,
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 32,
          ),
        )
      ],
      padding: const EdgeInsets.symmetric(vertical: 7),
      indicatorSize: TabBarIndicatorSize.tab,
    );
  }
}