import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store_status.g.dart';

@Riverpod(keepAlive: true)
class StoreStatus extends _$StoreStatus {
  @override
  FutureOr<int> build() {
    return 0; // dummy
  }

  void begin() {
    state = const AsyncLoading();
  }

  void end() {
    state = const AsyncData(0);
  }
}
