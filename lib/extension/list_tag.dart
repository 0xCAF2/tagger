import 'package:tagger/model/tag.dart';

extension ListTag on List<Tag> {
  Tag findTagById(int id) {
    return firstWhere((tag) => tag.id == id, orElse: () => first);
  }
}
