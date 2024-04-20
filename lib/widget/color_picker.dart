import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/provider/selected_color.dart';

class ColorPicker extends HookConsumerWidget {
  const ColorPicker({super.key, required this.nameFocusNode});

  final FocusNode nameFocusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Container(
        width: 240,
        height: 280,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Wrap(
              children: [
                for (final color in Colors.primaries)
                  _ColorButton(color: color, focusNode: nameFocusNode),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorButton extends ConsumerWidget {
  const _ColorButton({super.key, required this.color, this.focusNode});

  final Color color;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.transparent,
        ),
      ),
      child: IconButton(
        isSelected: color == ref.watch(selectedColorProvider),
        icon: const Icon(Icons.circle),
        selectedIcon: const Icon(Icons.check_circle),
        iconSize: 32,
        color: color,
        onPressed: () {
          ref.read(selectedColorProvider.notifier).select(color);
          focusNode?.requestFocus();
        },
      ),
    );
  }
}
