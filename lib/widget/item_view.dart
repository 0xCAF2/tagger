import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/extension/list_tag.dart';
import 'package:tagger/model/item.dart';
import 'package:tagger/model/tag.dart';
import 'package:tagger/provider/items.dart';
import 'package:tagger/provider/tags.dart';
import 'package:tagger/widget/tag_selector.dart';

class ItemView extends HookConsumerWidget {
  const ItemView({
    super.key,
    required this.item,
    required this.onTap,
    this.isEditing = false,
  });

  final Item item;
  final VoidCallback onTap;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);
    final selectTag = useCallback(
      ([Tag? clickedTag]) async {
        final tag = await showDialog(
          context: context,
          builder: (context) => const TagSelector(),
        );
        if (tag == null) return;
        ref
            .read(itemsProvider.notifier)
            .tag(item: item, tag: tag, clickedTag: clickedTag);
      },
      [item],
    );

    return ListTile(
      hoverColor: Colors.purple.withOpacity(0.05),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.text),
          tags.when(
            data: (data) => Wrap(
              children: [
                for (final tagId in item.tags) ...[
                  ActionChip(
                    key: ValueKey(tagId),
                    avatar: Icon(Icons.label,
                        color: Color(data.getTagById(tagId).colorValue)),
                    label: Text(data.getTagById(tagId).name),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: Color(data.getTagById(tagId).colorValue)
                        .withOpacity(0.1),
                    onPressed: () => selectTag(data.getTagById(
                        tagId)), // This argument is the clicked tag.
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: const Icon(Icons.label, size: 16),
                  onPressed: () => selectTag(),
                ),
              ],
            ),
            loading: () => const SizedBox(),
            error: (error, stackTrace) => Text(error.toString()),
          ),
        ],
      ),
      onTap: onTap,
      trailing: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: isEditing ? const Icon(Icons.edit) : null,
      ),
    );
  }
}
