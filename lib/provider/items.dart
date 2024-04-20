import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagger/model/item.dart';

part 'items.g.dart';

@riverpod
class Items extends _$Items {
  static const _idCounterKey = 'idCounter';
  static const _itemsKey = 'items';

  static late int _idCounter;

  @override
  FutureOr<List<Item>> build() async {
    final prefs = await SharedPreferences.getInstance();
    _idCounter = prefs.getInt(_idCounterKey) ?? 0;
    final List<dynamic> items = jsonDecode(prefs.getString(_itemsKey) ?? '[]');
    return items.map((itemStr) => Item.fromJson(jsonDecode(itemStr))).toList();
  }

  void add(String text) {
    final items = state.value;
    if (items == null) {
      return;
    }

    final item = Item(
      id: _idCounter++,
      text: text,
      tags: [],
    );
    state = AsyncData([...items, item]);
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
