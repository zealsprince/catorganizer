import 'package:catorganizer/src/classes/category.dart';
import 'package:catorganizer/src/classes/tag.dart';

/// A placeholder class that represents an entity or model.
class Document {
  final String uuid;
  final String path;

  String title;
  List<Tag> _tags = [];

  Document(
    this.uuid,
    this.title,
    this.path,
    List<Tag> tags,
  ) : _tags = tags;

  Document.empty({
    this.uuid = "",
    this.title = "",
    this.path = "",
  });

  Document.withCategory(
    this.uuid,
    this.title,
    this.path,
    List<Tag> tags,
    this.category,
  ) : _tags = tags;

  // Should probably assign this to some "Default" for null safety.
  late Category category = Category.uncategorized();

  void assign(Category category) {
    category.removeDocument(this); // Make sure we unassign this document first.

    this.category = category;
    category.assignDocument(this);
  }

  List<Tag> getTags() {
    return _tags;
  }

  bool hasTag(Tag tag) {
    for (Tag existingTag in _tags) {
      if (tag.value == existingTag.value) return true;
    }

    return false;
  }

  void addTag(Tag tag) {
    if (!hasTag(tag)) {
      _tags.add(tag);
    }
  }

  void removeTag(Tag tag) {
    for (int i = 0; i < _tags.length; i++) {
      if (_tags[i].value == tag.value) {
        _tags.removeAt(i);
        return;
      }
    }
  }
}
