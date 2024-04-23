import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/model/item.dart';
import 'package:tagger/provider/items.dart';
import 'package:tagger/widget/item_view.dart';

class ItemList extends HookConsumerWidget {
  const ItemList({
    super.key,
    required this.storeIndex,
    this.tagId,
    this.hasFocus = false,
  });

  final ValueNotifier<int> storeIndex;
  final int? tagId;
  final bool hasFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider);
    final textController = useTextEditingController();
    final textFocusNode = useFocusNode();
    final addItem = useCallback(() {
      if (textController.text.trim().isEmpty) return;
      ref.read(itemsProvider.notifier).add(textController.text, tagId);
      textController.clear();
      textFocusNode.requestFocus();
      storeIndex.value++;
    }, const []);

    final canAddItem = useState(false);
    useEffect(() {
      textController.addListener(() {
        canAddItem.value = textController.text.trim().isNotEmpty;
      });
      return null;
    }, const []);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasFocus) {
          textFocusNode.requestFocus();
        }
      });
      return null;
    }, [hasFocus]);

    final editingItem = useState<Item?>(null);

    final editItem = useCallback(() {
      if (editingItem.value == null) return;
      if (textController.text.trim().isEmpty) {
        ref.read(itemsProvider.notifier).delete(editingItem.value!.id);
        textController.clear();
        textFocusNode.requestFocus();
        editingItem.value = null;
        storeIndex.value++;
        return;
      }
      ref.read(itemsProvider.notifier).edit(
            id: editingItem.value!.id,
            text: textController.text,
          );
      textController.clear();
      textFocusNode.requestFocus();
      editingItem.value = null;
      storeIndex.value++;
    }, const []);

    return items.when(
      data: (data) => Stack(
        children: [
          Positioned(
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: 560,
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
            child: tagId == null
                ? ReorderableListView.builder(
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
                        storeIndex: storeIndex,
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(itemsProvider.notifier)
                          .reorder(oldIndex, newIndex);
                      storeIndex.value++;
                    },
                  )
                : ListView.builder(
                    itemBuilder: (context, index) {
                      final item = data
                          .where((item) => item.tags.contains(tagId))
                          .elementAt(index);
                      return ItemView(
                        item: item,
                        key: ValueKey(item.id),
                        onTap: () {
                          textController.text = item.text;
                          textFocusNode.requestFocus();
                          editingItem.value = item;
                        },
                        isEditing: editingItem.value == item,
                        storeIndex: storeIndex,
                      );
                    },
                    itemCount:
                        data.where((item) => item.tags.contains(tagId)).length,
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
