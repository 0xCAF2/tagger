import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/model/item.dart';
import 'package:tagger/provider/tags.dart';

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

    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.text),
          tags.when(
            data: (data) => Wrap(
              children: [
                for (final tag in data)
                  if (item.tags.contains(tag.id))
                    ActionChip(
                      avatar: Icon(Icons.label, color: Color(tag.colorValue)),
                      label: Text(tag.name),
                      onPressed: () {},
                    ),
                IconButton(
                  icon: const Icon(Icons.label, size: 16),
                  onPressed: () {},
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
