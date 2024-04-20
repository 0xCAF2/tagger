import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/model/item.dart';

class ItemView extends HookConsumerWidget {
  const ItemView({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(item.text),
    );
  }
}
