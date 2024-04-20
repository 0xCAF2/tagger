import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/model/tag.dart';

class TagView extends HookConsumerWidget {
  const TagView({super.key, required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.label, color: Color(tag.colorValue)),
      title: Text(tag.name),
    );
  }
}
