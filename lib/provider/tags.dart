import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagger/model/tag.dart';
import 'package:tagger/provider/prefs.dart';
import 'package:tagger/provider/selected_color.dart';

part 'tags.g.dart';

@Riverpod(keepAlive: true)
class Tags extends _$Tags {
  static const tagIdKey = 'tagId';
  static const tagsKey = 'tags';

  static late int idCounter;

  @override
  List<Tag> build() {
    final prefs = ref.watch(prefsProvider);
    idCounter = prefs.getInt(tagIdKey) ?? 0;
    try {
      final List<dynamic> tagsListStr =
          jsonDecode(prefs.getString(tagsKey) ?? '[]');
      final tags = tagsListStr.map((tagStr) => Tag.fromJson(tagStr)).toList();
      if (tags.isEmpty) {
        tags.add(Tag(
          id: idCounter++,
          name: 'ToDo',
          colorValue: Colors.purple.value,
        ));
      }
      return tags;
    } catch (_) {
      return [];
    }
  }

  void add({required String name}) {
    final color = ref.read(selectedColorProvider);
    final tag = Tag(
      id: idCounter++,
      name: name,
      colorValue: color.value,
    );
    state = [...state, tag];
  }

  void edit({required int id, required String name, required Color color}) {
    final index = state.indexWhere((tag) => tag.id == id);
    if (index == -1) {
      return;
    }

    final newTags = List<Tag>.from(state);
    newTags[index] = Tag(
      id: id,
      name: name,
      colorValue: color.value,
    );
    state = newTags;
  }

  void delete(int id) {
    if (state.length == 1) {
      return;
    }
    final newTags = List<Tag>.from(state);
    newTags.removeWhere((tag) => tag.id == id);
    state = newTags;
  }

  void reorder(int oldIndex, int newIndex) {
    final item = state.removeAt(oldIndex);
    if (oldIndex < newIndex) {
      --newIndex;
    }
    state.insert(newIndex, item);
    state = [...state];
  }
}
