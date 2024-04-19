import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Tagger extends HookConsumerWidget {
  const Tagger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            elevation: 4.0,
            onDestinationSelected: (index) {
              selectedIndex.value = index;
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.list),
                selectedIcon: Icon(Icons.list_outlined),
                label: Text('List'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.label_outline),
                selectedIcon: Icon(Icons.label),
                label: Text('Label'),
              ),
            ],
            selectedIndex: selectedIndex.value,
          ),
          Expanded(
            child: IndexedStack(
              index: selectedIndex.value,
              children: const [
                Center(child: Text('List')),
                Center(child: Text('Label')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
