import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/provider/store.dart';
import 'package:tagger/provider/tags.dart';
import 'package:tagger/widget/item_list.dart';
import 'package:tagger/widget/tag_list.dart';

class Tagger extends HookConsumerWidget {
  const Tagger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);

    final selectedIndex = useState(0);
    final storeIndex = useState(0);
    final debouncedStoreIndex = useDebounced(
      storeIndex.value,
      const Duration(seconds: 5),
    );
    useEffect(() {
      if (debouncedStoreIndex == 0) return;
      ref.read(storeProvider.notifier).save();
      return null;
    }, [debouncedStoreIndex]);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (index) {
              selectedIndex.value = index;
            },
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.list),
                selectedIcon: Icon(Icons.list_outlined),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.label_outline),
                selectedIcon: Icon(Icons.label),
                label: Text(''),
              ),
              ...tags.when(
                data: (data) => [
                  for (var tag in data)
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.label,
                        color: Color(tag.colorValue),
                      ),
                      label: Text(tag.name),
                    ),
                ],
                error: (error, stackTrace) => [
                  const NavigationRailDestination(
                    icon: Icon(Icons.error),
                    label: Text(''),
                  ),
                ],
                loading: () => [
                  const NavigationRailDestination(
                    icon: Icon(Icons.timer),
                    label: Text(''),
                  ),
                ],
              )
            ],
            selectedIndex: selectedIndex.value,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: selectedIndex.value,
              children: [
                ItemList(
                  storeIndex: storeIndex,
                  hasFocus: selectedIndex.value == 0,
                ),
                TagList(
                  storeIndex: storeIndex,
                  hasFocus: selectedIndex.value == 1,
                ),
                ...tags.when(
                  data: (data) => [
                    for (var i = 0; i < data.length; ++i)
                      ItemList(
                        key: ValueKey(data[i].id),
                        storeIndex: storeIndex,
                        tagId: data[i].id,
                        hasFocus: selectedIndex.value == i + 2,
                      ),
                  ],
                  error: (error, stackTrace) => [
                    Center(child: Text(error.toString())),
                  ],
                  loading: () => [
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
