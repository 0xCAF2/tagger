import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagger/model/item.dart';
import 'package:tagger/model/tag.dart';
import 'package:tagger/provider/tags.dart';

part 'items.g.dart';

@riverpod
class Items extends _$Items {
  static const _itemIdKey = 'itemId';
  static const _itemsKey = 'items';

  static late int _idCounter;

  @override
  FutureOr<List<Item>> build() async {
    final prefs = await SharedPreferences.getInstance();
    _idCounter = prefs.getInt(_itemIdKey) ?? 0;
    final List<dynamic> items = jsonDecode(prefs.getString(_itemsKey) ?? '[]');
    return items.map((itemStr) => Item.fromJson(jsonDecode(itemStr))).toList();
  }

  void add(String text) {
    final items = state.value;
    if (items == null) {
      return;
    }

    late Tag defaultTag;
    ref.read(tagsProvider.future).then((tags) {
      defaultTag = tags.first;
      final item = Item(
        id: _idCounter++,
        text: text,
        tags: [defaultTag.id],
      );
      state = AsyncData([...items, item]);
    });
  }

  void edit({required int id, required String text}) {
    final items = state.value;
    if (items == null) {
      return;
    }

    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final item = items[index];
    state = AsyncData([
      ...items.sublist(0, index),
      item.copyWith(text: text),
      ...items.sublist(index + 1),
    ]);
  }

  void delete(int id) {
    final items = state.value;
    if (items == null) {
      return;
    }

    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    state =
        AsyncData([...items.sublist(0, index), ...items.sublist(index + 1)]);
  }

  void reorder(int oldIndex, int newIndex) {
    final items = state.value;
    if (items == null) {
      return;
    }

    final item = items.removeAt(oldIndex);
    if (oldIndex < newIndex) {
      --newIndex;
    }
    items.insert(newIndex, item);
    state = AsyncData([...items]);
  }
}
