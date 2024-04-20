import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagger/model/item.dart';

part 'items.g.dart';

@riverpod
class Items extends _$Items {
  static const _key = 'items';

  @override
  FutureOr<List<Item>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> items = jsonDecode(prefs.getString(_key) ?? '[]');
    return items.map((itemStr) => Item.fromJson(jsonDecode(itemStr))).toList();
  }
}
