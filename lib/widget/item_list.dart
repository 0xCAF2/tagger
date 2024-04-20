import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ItemList extends HookConsumerWidget {
  const ItemList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final textFocusNode = useFocusNode();

    return Stack(
      children: [
        Positioned(
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: 400,
            child: TextField(
              controller: textController,
              focusNode: textFocusNode,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    textController.clear();
                    textFocusNode.requestFocus();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
