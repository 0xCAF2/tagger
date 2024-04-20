import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_color.g.dart';

@Riverpod(keepAlive: true)
class SelectedColor extends _$SelectedColor {
  @override
  Color build() {
    return Colors.purple;
  }

  void select(Color color) {
    state = color;
  }
}
