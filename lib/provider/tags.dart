import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagger/model/tag.dart';
import 'package:tagger/provider/selected_color.dart';

part 'tags.g.dart';

@riverpod
class Tags extends _$Tags {
  static const _tagIdKey = 'tagId';
  static const _tagsKey = 'tags';

  static late int _idCounter;

  @override
  FutureOr<List<Tag>> build() async {
    final prefs = await SharedPreferences.getInstance();
    _idCounter = prefs.getInt(_tagIdKey) ?? 0;
    final List<dynamic> tagsListStr =
        jsonDecode(prefs.getString(_tagsKey) ?? '[]');
    final tags =
        tagsListStr.map((tagStr) => Tag.fromJson(jsonDecode(tagStr))).toList();
    if (tags.isEmpty) {
      tags.add(Tag(
        id: _idCounter++,
        name: 'ToDo',
        colorValue: Colors.purple.value,
      ));
    }
    return tags;
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
}
