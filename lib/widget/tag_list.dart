import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/model/tag.dart';
import 'package:tagger/provider/selected_color.dart';
import 'package:tagger/provider/tags.dart';
import 'package:tagger/widget/color_picker.dart';
import 'package:tagger/widget/tag_view.dart';

class TagList extends HookConsumerWidget {
  const TagList({super.key, required this.storeIndex, this.hasFocus = false});

  final ValueNotifier<int> storeIndex;
  final bool hasFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);
    final nameController = useTextEditingController();
    final nameFocusNode = useFocusNode();

    final addTag = useCallback(() {
      if (nameController.text.trim().isEmpty) return;
      ref.read(tagsProvider.notifier).add(name: nameController.text);
      nameController.clear();
      nameFocusNode.requestFocus();
      storeIndex.value++;
    }, const []);

    final canAddTag = useState(false);
    useEffect(() {
      nameController.addListener(() {
        canAddTag.value = nameController.text.trim().isNotEmpty;
      });
      return null;
    }, const []);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasFocus) {
          nameFocusNode.requestFocus();
        }
      });
      return null;
    }, [hasFocus]);

    final editingTag = useState<Tag?>(null);

    final editTag = useCallback(() {
      if (editingTag.value == null) return;
      if (nameController.text.trim().isEmpty) {
        ref.read(tagsProvider.notifier).delete(editingTag.value!.id);
        nameController.clear();
        nameFocusNode.requestFocus();
        editingTag.value = null;
        storeIndex.value++;
        return;
      }
      ref.read(tagsProvider.notifier).edit(
            id: editingTag.value!.id,
            name: nameController.text,
            color: ref.read(selectedColorProvider),
          );
      nameController.clear();
      nameFocusNode.requestFocus();
      editingTag.value = null;
      storeIndex.value++;
    }, const []);

    return Row(
      children: [
        Container(
          width: 280,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                focusNode: nameFocusNode,
                decoration: InputDecoration(
                  suffixIcon: editingTag.value == null
                      ? IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: canAddTag.value ? addTag : null,
                        )
                      : IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: editTag,
                        ),
                ),
                onSubmitted: (_) =>
                    editingTag.value == null ? addTag() : editTag(),
              ),
              ColorPicker(nameFocusNode: nameFocusNode),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 120, right: 80),
            child: ReorderableListView.builder(
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return TagView(
                  tag: tag,
                  key: ValueKey(tag.id),
                  onTap: () {
                    editingTag.value = tag;
                    ref
                        .read(selectedColorProvider.notifier)
                        .select(Color(tag.colorValue));
                    nameController.text = tag.name;
                    nameFocusNode.requestFocus();
                  },
                  isEditing: editingTag.value == tag,
                );
              },
              onReorder: (oldIndex, newIndex) {
                ref.read(tagsProvider.notifier).reorder(oldIndex, newIndex);
                storeIndex.value++;
              },
            ),
          ),
        ),
      ],
    );
  }
}
