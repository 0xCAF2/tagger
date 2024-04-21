import 'package:tagger/model/tag.dart';

extension ListTag on List<Tag> {
  Tag getTagById(int id) {
    return firstWhere((tag) => tag.id == id, orElse: () => first);
  }
}
