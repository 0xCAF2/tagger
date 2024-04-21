import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/model/tag.dart';

class TagView extends HookConsumerWidget {
  const TagView({
    super.key,
    required this.tag,
    required this.onTap,
    this.isEditing = false,
  });

  final Tag tag;
  final VoidCallback onTap;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.label, color: Color(tag.colorValue)),
      title: Text(tag.name),
      onTap: onTap,
      trailing: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: isEditing ? const Icon(Icons.edit) : null,
      ),
    );
  }
}
