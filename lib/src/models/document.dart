import 'package:uuid/uuid.dart';

import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/tag.dart';

/// A placeholder class that represents an entity or model.
class DocumentModel {
  final String uuid;

  String path;
  String title;
  List<TagModel> _tags = [];
  CategoryModel category = CategoryModel.uncategorized();

  DocumentModel(
    this.path,
    this.title,
    List<TagModel> tags,
    this.category,
  )   : uuid = const Uuid().v4(),
        _tags = tags;

  DocumentModel.empty({
    this.path = "",
    this.title = "",
  }) : uuid = const Uuid().v4();

  void assignCategory(CategoryModel category) {
    category.removeDocument(this); // Make sure we unassign this document first.

    this.category = category;
    category.assignDocument(this);
  }

  List<TagModel> getTags() {
    return _tags;
  }

  void setTags(List<TagModel> tags) {
    _tags = tags;
  }

  bool hasTag(TagModel tag) {
    for (TagModel existingTag in _tags) {
      if (tag.value == existingTag.value) return true;
    }

    return false;
  }
}
