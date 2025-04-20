import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/extension/list_tag.dart';
import 'package:tagger/model/item.dart';
import 'package:tagger/model/tag.dart';
import 'package:tagger/provider/items.dart';
import 'package:tagger/provider/tags.dart';

class ItemView extends HookConsumerWidget {
  const ItemView({
    super.key,
    required this.item,
    required this.onTap,
    this.isEditing = false,
    required this.storeIndex,
  });

  final Item item;
  final VoidCallback onTap;
  final bool isEditing;
  final ValueNotifier<int> storeIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);
    final selectTag = useCallback(
      ({required Tag selectedTag, Tag? clickedTag}) async {
        ref
            .read(itemsProvider.notifier)
            .tag(item: item, tag: selectedTag, clickedTag: clickedTag);
        storeIndex.value++;
      },
      [item],
    );

    return ListTile(
      hoverColor: Colors.purple.withValues(alpha: 0.05),
      focusColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.text),
          Wrap(
            children: [
              for (final tagId in item.tags) ...[
                if (tags.any((tag) => tag.id == tagId))
                  _TagMenu(
                    selectTag: selectTag,
                    tagId: tagId,
                    tags: tags,
                    builder: (context, onPressed) => ActionChip(
                      key: ValueKey(tagId),
                      avatar: Icon(
                        Icons.label,
                        color: Color(tags.findTagById(tagId).colorValue),
                      ),
                      label: Text(tags.findTagById(tagId).name),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor: Color(
                        tags.findTagById(tagId).colorValue,
                      ).withValues(alpha: 0.1),
                      onPressed: onPressed,
                    ),
                  )
                else
                  () {
                    Future(() {
                      final deletedTag = Tag(
                        id: tagId,
                        name: 'Deleted Tag',
                        colorValue: 0,
                      );
                      ref.read(itemsProvider.notifier).tag(
                            item: item,
                            tag: deletedTag,
                            clickedTag: deletedTag,
                          );
                      storeIndex.value++;
                    });
                    return const SizedBox();
                  }(),
                const SizedBox(width: 8),
              ],
              _TagMenu(
                selectTag: selectTag,
                tags: tags,
                builder: (context, onPressed) => IconButton(
                  onPressed: onPressed,
                  icon: const Icon(Icons.label, size: 16),
                ),
              ),
            ],
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

class _TagMenu extends StatelessWidget {
  const _TagMenu({
    this.tagId,
    required this.tags,
    required this.selectTag,
    required this.builder,
  });

  final int? tagId;
  final List<Tag> tags;
  final void Function({required Tag selectedTag, Tag? clickedTag}) selectTag;
  final Widget Function(BuildContext context, VoidCallback onPressed) builder;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        for (final tag in tags)
          MenuItemButton(
            onPressed: () => selectTag(
              selectedTag: tag,
              clickedTag: tagId == null ? null : tags.findTagById(tagId!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.label,
                  color: Color(tag.colorValue),
                ),
                const SizedBox(width: 8),
                Text(tag.name),
              ],
            ),
          )
      ],
      builder: (_, controller, __) => builder(
        context,
        () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
      ),
    );
  }
}
