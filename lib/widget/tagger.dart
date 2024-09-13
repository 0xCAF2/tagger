import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/provider/store.dart';
import 'package:tagger/provider/store_status.dart';
import 'package:tagger/provider/tags.dart';
import 'package:tagger/widget/item_list.dart';
import 'package:tagger/widget/tag_list.dart';

class Tagger extends HookConsumerWidget {
  const Tagger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(storeStatusProvider);
    final tags = ref.watch(tagsProvider);

    final selectedIndex = useState(0);
    final storeIndex = useState(0);
    useEffect(() {
      storeIndex.addListener(() {
        ref.read(storeStatusProvider.notifier).begin();
      });
      return null;
    }, const []);

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              ...[
                for (var tag in tags)
                  NavigationRailDestination(
                    icon: Icon(
                      Icons.label,
                      color: Color(tag.colorValue),
                    ),
                    label: SizedBox(
                      width: 96,
                      child: Text(
                        tag.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
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
                ...[
                  for (var i = 0; i < tags.length; ++i)
                    ItemList(
                      key: ValueKey(tags[i].id),
                      storeIndex: storeIndex,
                      tagId: tags[i].id,
                      hasFocus: selectedIndex.value == i + 2,
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: status.when(
                    data: (data) => storeIndex.value == 0
                        ? const SizedBox.shrink()
                        : const Icon(Icons.check),
                    error: (error, stackTrace) => Text(error.toString()),
                    loading: () => const CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
