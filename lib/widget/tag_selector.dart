import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tagger/provider/tags.dart';
import 'package:tagger/widget/tag_view.dart';

class TagSelector extends ConsumerWidget {
  const TagSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);

    return Center(
      child: SizedBox(
        width: 400,
        height: 240,
        child: Card(
          child: tags.when(
            data: (data) => ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final tag = data[index];
                return TagView(
                  tag: tag,
                  onTap: () {
                    Navigator.of(context).pop(tag);
                  },
                );
              },
            ),
            error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
