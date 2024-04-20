import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/provider/items.dart';
import 'package:tagger/widget/item_view.dart';

class ItemList extends HookConsumerWidget {
  const ItemList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider);
    final textController = useTextEditingController();
    final textFocusNode = useFocusNode();
    final addItem = useCallback(() {
      if (textController.text.trim().isEmpty) return;
      ref.read(itemsProvider.notifier).add(textController.text);
      textController.clear();
      textFocusNode.requestFocus();
    }, const []);

    return items.when(
      data: (data) => Stack(
        children: [
          Positioned(
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: 400,
              child: TextField(
                controller: textController,
                focusNode: textFocusNode,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: addItem,
                  ),
                ),
                onSubmitted: (_) => addItem(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 120, right: 80),
            child: ReorderableListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => ItemView(
                item: data[index],
                key: ValueKey(data[index].id),
              ),
              onReorder: (oldIndex, newIndex) {
                ref.read(itemsProvider.notifier).reorder(oldIndex, newIndex);
              },
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
