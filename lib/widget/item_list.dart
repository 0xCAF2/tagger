import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/model/item.dart';
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

    final canAddItem = useState(false);
    useEffect(() {
      textController.addListener(() {
        canAddItem.value = textController.text.trim().isNotEmpty;
      });
      return null;
    }, const []);

    final editingItem = useState<Item?>(null);

    final editItem = useCallback(() {
      if (editingItem.value == null) return;
      if (textController.text.trim().isEmpty) {
        ref.read(itemsProvider.notifier).delete(editingItem.value!.id);
        textController.clear();
        textFocusNode.requestFocus();
        editingItem.value = null;
        return;
      }
      ref.read(itemsProvider.notifier).edit(
            id: editingItem.value!.id,
            text: textController.text,
          );
      textController.clear();
      textFocusNode.requestFocus();
      editingItem.value = null;
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
                  suffixIcon: editingItem.value == null
                      ? IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: canAddItem.value ? addItem : null,
                        )
                      : IconButton(
                          icon: const Icon(Icons.done),
                          onPressed: editItem,
                        ),
                ),
                onSubmitted: (_) =>
                    editingItem.value == null ? addItem() : editItem(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 120, right: 80),
            child: ReorderableListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return ItemView(
                  item: item,
                  key: ValueKey(item.id),
                  onTap: () {
                    textController.text = item.text;
                    textFocusNode.requestFocus();
                    editingItem.value = item;
                  },
                  isEditing: editingItem.value == item,
                );
              },
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
