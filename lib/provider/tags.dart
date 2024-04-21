import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagger/model/tag.dart';
import 'package:tagger/provider/selected_color.dart';

part 'tags.g.dart';

@Riverpod(keepAlive: true)
class Tags extends _$Tags {
  static const _tagIdKey = 'tagId';
  static const tagsKey = 'tags';

  static late int _idCounter;

  @override
  FutureOr<List<Tag>> build() async {
    final prefs = await SharedPreferences.getInstance();
    _idCounter = prefs.getInt(_tagIdKey) ?? 0;
    try {
      final List<dynamic> tagsListStr =
          jsonDecode(prefs.getString(tagsKey) ?? '[]');
      final tags = tagsListStr.map((tagStr) => Tag.fromJson(tagStr)).toList();
      if (tags.isEmpty) {
        tags.add(Tag(
          id: _idCounter++,
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
    final tags = state.value;
    if (tags == null) {
      return;
    }

    final color = ref.read(selectedColorProvider);
    final tag = Tag(
      id: _idCounter++,
      name: name,
      colorValue: color.value,
    );
    state = AsyncData([...tags, tag]);
  }

  void edit({required int id, required String name, required Color color}) {
    final tags = state.value;
    if (tags == null) {
      return;
    }

    final index = tags.indexWhere((tag) => tag.id == id);
    if (index == -1) {
      return;
    }

    final newTags = List<Tag>.from(tags);
    newTags[index] = Tag(
      id: id,
      name: name,
      colorValue: color.value,
    );
    state = AsyncData(newTags);
  }

  void delete(int id) {
    final tags = state.value;
    if (tags == null) {
      return;
    }

    if (tags.length == 1) {
      return;
    }
    final newTags = List<Tag>.from(tags);
    newTags.removeWhere((tag) => tag.id == id);
    state = AsyncData(newTags);
  }

  void reorder(int oldIndex, int newIndex) {
    final tags = state.value;
    if (tags == null) {
      return;
    }

    final item = tags.removeAt(oldIndex);
    if (oldIndex < newIndex) {
      --newIndex;
    }
    tags.insert(newIndex, item);
    state = AsyncData([...tags]);
  }
}
