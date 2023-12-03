import 'package:catorganizer/src/classes/category.dart';
import 'package:catorganizer/src/classes/tag.dart';

/// A placeholder class that represents an entity or model.
class Document {
  Document(this.uuid, this.title, this.path, this.tags);

  Document.empty({
    this.uuid = "",
    this.title = "",
    this.path = "",
    this.tags = const [],
  });

  Document.withCategory(
    this.uuid,
    this.title,
    this.path,
    this.tags,
    this.category,
  );

  final String uuid;
  final String title;
  final String path;
  final List<Tag> tags;

  // Should probably assign this to some "Default" for null safety.
  late Category category = Category.uncategorized();

  void assign(Category category) {
    category.removeDocument(this); // Make sure we unassign this document first.

    this.category = category;
    category.addDocument(this);
  }
}
