import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagger/model/item.dart';
import 'package:tagger/model/tag.dart';
import 'package:tagger/provider/tags.dart';

part 'items.g.dart';

@Riverpod(keepAlive: true)
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

  void tag({required Item item, required Tag tag, Tag? clickedTag}) {
    final items = state.value;
    if (items == null) {
      return;
    }

    final index = items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      return;
    }

    late Item updatedItem;

    if (item.tags.contains(tag.id)) {
      if (clickedTag == null) {
        // Move to last if the tag is already added.
        updatedItem = item.copyWith(
          tags: [
            ...item.tags.where((id) => id != tag.id),
            tag.id,
          ],
        );
      } else if (clickedTag.id == tag.id) {
        // Remove the tag if it's clicked again.
        updatedItem = item.copyWith(
          tags: item.tags.where((id) => id != tag.id).toList(),
        );
      } else {
        // Move the tag if it's already added.
        final newIndex = item.tags.indexOf(clickedTag.id);
        final oldIndex = item.tags.indexOf(tag.id);
        if (oldIndex < newIndex) {
          final updatedTags = [
            ...item.tags.sublist(0, oldIndex),
            ...item.tags.sublist(oldIndex + 1, newIndex + 1),
            tag.id,
            ...item.tags.sublist(newIndex + 1),
          ];
          updatedItem = item.copyWith(tags: updatedTags);
        } else {
          final updatedTags = [
            ...item.tags.sublist(0, newIndex),
            tag.id,
            ...item.tags.sublist(newIndex, oldIndex),
            ...item.tags.sublist(oldIndex + 1),
          ];
          updatedItem = item.copyWith(tags: updatedTags);
        }
      }
    } else if (clickedTag != null) {
      // Replace the tag if another tag is clicked.
      final clickedIndex = item.tags.indexOf(clickedTag.id);
      final updatedTags = [
        ...item.tags.sublist(0, clickedIndex),
        tag.id,
        ...item.tags.sublist(clickedIndex + 1),
      ];
      updatedItem = item.copyWith(tags: updatedTags);
    } else {
      // Add the tag if it's not added yet.
      updatedItem = item.copyWith(tags: [...item.tags, tag.id]);
    }
    state = AsyncData([
      ...items.sublist(0, index),
      updatedItem,
      ...items.sublist(index + 1),
    ]);
  }
}
