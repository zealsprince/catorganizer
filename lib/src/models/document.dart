import 'package:uuid/uuid.dart';

import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/tag.dart';

/// A placeholder class that represents an entity or model.
class DocumentModel {
  String _uuid = "";

  String path = "";
  String title = "";
  List<TagModel> _tags = [];
  CategoryModel category = CategoryModel.uncategorized();

  DocumentModel(
    this.path,
    this.title,
    List<TagModel> tags,
    this.category,
  )   : _uuid = const Uuid().v4(),
        _tags = tags;

  DocumentModel.empty({
    this.path = "",
    this.title = "",
  }) : _uuid = const Uuid().v4();

  DocumentModel.fromJson(Map<String, dynamic> json) {
    _uuid = json['uuid'] as String;
    path = json['path'] as String;
    title = json['title'] as String;
    _tags = json['tags'] as List<TagModel>;
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': _uuid,
      'path': path,
      'title': title,
      'tags': _tags,
    };
  }

  void assignCategory(CategoryModel category) {
    category.removeDocument(this); // Make sure we unassign this document first.

    this.category = category;
    category.assignDocument(this);
  }

  String getUUID() {
    return _uuid;
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
