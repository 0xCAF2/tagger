import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagger/provider/items.dart';
import 'package:tagger/provider/prefs.dart';
import 'package:tagger/provider/tags.dart';

part 'store.g.dart';

@Riverpod(keepAlive: true)
class Store extends _$Store {
  @override
  FutureOr<int> build() {
    return 0; // dummy
  }

  Future<void> save() async {
    final items = ref.read(itemsProvider);
    final tags = ref.read(tagsProvider);
    final prefs = ref.read(prefsProvider);

    // Save items and tags to a prefs.
    final itemsStr = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(Items.itemsKey, itemsStr);
    final tagsStr = jsonEncode(tags.map((tag) => tag.toJson()).toList());
    await prefs.setString(Tags.tagsKey, tagsStr);

    // Save id counters.
    await prefs.setInt(Items.itemIdKey, Items.idCounter);
    await prefs.setInt(Tags.tagIdKey, Tags.idCounter);
  }
}
