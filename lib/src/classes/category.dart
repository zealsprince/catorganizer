import 'package:catorganizer/src/classes/document.dart';

/// A placeholder class that represents an entity or model.
class Category {
  static const String uncategorizedIdentifier = "uncategorized";
  static const String uncategorizedTitle = "Uncategorized";

  final String id;
  final String title;
  final String description;
  final String color;
  final int icon;

  Category(
    this.id,
    this.title,
    this.description,
    this.color,
    this.icon,
  );

  Category.withDocuments(
    this.id,
    this.title,
    this.description,
    this.color,
    this.icon,
    this._documents,
  );

  Category.uncategorized({
    this.id = uncategorizedIdentifier,
    this.title = uncategorizedTitle,
    this.description = "Documents that have not been assigned to any category",
    this.color = "ff6750a4",
    this.icon = 0xf77e,
  });

  Map<String, Document> _documents = {};

  Map<String, Document> getDocumets() {
    return _documents;
  }

  void assignDocument(Document document) {
    _documents[document.uuid] = document;
  }

  void removeDocument(Document document) {
    _documents.remove(document.uuid);
  }
}
