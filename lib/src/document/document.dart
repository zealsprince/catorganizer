import '../category/category.dart';
import '../tag/tag.dart';

/// A placeholder class that represents an entity or model.
class Document {
  const Document(this.uuid, this.title, this.path, this.tags);

  final String uuid;
  final String title;
  final String path;
  final List<Tag> tags;
}
