import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'prefs.g.dart';

@Riverpod(keepAlive: true)
SharedPreferencesWithCache prefs(PrefsRef ref) {
  throw UnimplementedError();
}
