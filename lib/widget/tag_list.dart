import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/provider/tags.dart';
import 'package:tagger/widget/color_picker.dart';
import 'package:tagger/widget/tag_view.dart';

class TagList extends HookConsumerWidget {
  const TagList({super.key});
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
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: addTag,
                  ),
                ),
                onSubmitted: (_) => addTag(),
              ),
              ColorPicker(nameFocusNode: nameFocusNode),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 120, right: 80),
            child: tags.when(
              data: (data) => ReorderableListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) => TagView(
                  tag: data[index],
                  key: ValueKey(data[index].id),
                ),
                onReorder: (oldIndex, newIndex) {},
              ),
              error: (error, stackTrace) => Center(
                child: Text(error.toString()),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
