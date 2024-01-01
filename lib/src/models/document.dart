import 'package:uuid/uuid.dart';

import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/tag.dart';

/// A placeholder class that represents an entity or model.
class DocumentModel {
  String _uuid = "";
  String category = CategoryModel.uncategorizedIdentifier;

  String path = "";
  String title = "";
  List<TagModel> _tags = [];

  DocumentModel(this.category, this.path, this.title, List<TagModel> tags)
      : _uuid = const Uuid().v4(),
        _tags = tags;

  DocumentModel.empty({
    this.path = "",
    this.title = "",
  }) : _uuid = const Uuid().v4();

  DocumentModel.fromJson(String uuid, Map<String, dynamic> json) {
    _uuid = uuid;
    category = json['category'] as String;
    path = json['path'] as String;
    title = json['title'] as String;

    for (String tag in json['tags'] as List<dynamic>) {
      _tags.add(TagModel(tag));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'path': path,
      'title': title,
      'tags': _tags,
    };
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
