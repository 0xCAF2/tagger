import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagger/model/item.dart';
import 'package:tagger/model/tag.dart';
import 'package:tagger/provider/prefs.dart';
import 'package:tagger/provider/tags.dart';

part 'items.g.dart';

@Riverpod(keepAlive: true)
class Items extends _$Items {
  static const itemIdKey = 'itemId';
  static const itemsKey = 'items';

  static late int idCounter;

  @override
  List<Item> build() {
    final prefs = ref.watch(prefsProvider);
    idCounter = prefs.getInt(itemIdKey) ?? 0;
    try {
      final List<dynamic> items = jsonDecode(prefs.getString(itemsKey) ?? '[]');
      return items.map((itemStr) => Item.fromJson(itemStr)).toList();
    } catch (_) {
      return [];
    }
  }

  void add(String text, int? tagId) {
    late Tag defaultTag;
    final tags = ref.read(tagsProvider);
    defaultTag = tags.first;
    final item = Item(
      id: idCounter++,
      text: text,
      tags: [tagId ?? defaultTag.id],
    );
    state = [item, ...state];
  }

  void edit({required int id, required String text}) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final item = state[index];
    state = [
      ...state.sublist(0, index),
      item.copyWith(text: text),
      ...state.sublist(index + 1),
    ];
  }

  void delete(int id) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    state = [...state.sublist(0, index), ...state.sublist(index + 1)];
  }

  void reorder(int oldIndex, int newIndex) {
    final item = state.removeAt(oldIndex);
    if (oldIndex < newIndex) {
      --newIndex;
    }
    state.insert(newIndex, item);
    state = [...state];
  }

  void tag({required Item item, required Tag tag, Tag? clickedTag}) {
    final index = state.indexWhere((i) => i.id == item.id);
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
    state = [
      ...state.sublist(0, index),
      updatedItem,
      ...state.sublist(index + 1),
    ];
  }
}
