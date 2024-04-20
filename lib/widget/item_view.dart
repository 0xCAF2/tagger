import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/model/item.dart';
import 'package:tagger/provider/tags.dart';

class ItemView extends HookConsumerWidget {
  const ItemView({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);

    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.text),
          tags.when(
            data: (data) => Row(
              children: [
                for (final tag in data)
                  if (item.tags.contains(tag.id))
                    Chip(
                      avatar: Icon(Icons.label, color: Color(tag.colorValue)),
                      label: Text(tag.name),
                    ),
              ],
            ),
            loading: () => const SizedBox(),
            error: (error, stackTrace) => Text(error.toString()),
          ),
        ],
      ),
    );
  }
}
