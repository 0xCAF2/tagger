import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagger/provider/items.dart';
import 'package:tagger/provider/tags.dart';

part 'store.g.dart';

@riverpod
class Store extends _$Store {
  @override
  FutureOr<int> build() {
    return 0;
  }

  Future<void> save() async {
    final items = await ref.read(itemsProvider.future);
    final tags = await ref.read(tagsProvider.future);
    final prefs = await SharedPreferences.getInstance();
    // Save items and tags to a prefs
    final itemsStr = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(Items.itemsKey, itemsStr);
    final tagsStr = jsonEncode(tags.map((tag) => tag.toJson()).toList());
    await prefs.setString(Tags.tagsKey, tagsStr);
  }
}
