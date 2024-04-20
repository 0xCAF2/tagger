import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagger/model/tag.dart';

part 'tags.g.dart';

@riverpod
class Tags extends _$Tags {
  static const _key = 'tags';

  @override
  FutureOr<List<Tag>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tags = jsonDecode(prefs.getString(_key) ?? '[]');
    return tags.map((tagStr) => Tag.fromJson(jsonDecode(tagStr))).toList();
  }
}
