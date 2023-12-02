import 'package:flutter/material.dart';

import 'package:catorganizer/src/classes/document.dart';

/// A placeholder class that represents an entity or model.
class Category {
  static const String uncategorizedIdentifier = "uncategorized";
  static const String uncategorizedTitle = "Uncategorized";

  final String id;
  final String title;
  final String description;
  final Color color;
  final Icon icon;

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
    this.documents,
  );

  Category.uncategorized({
    this.id = uncategorizedIdentifier,
    this.title = uncategorizedTitle,
    this.description = "Documents that have not been assigned to any category",
    this.color = const Color(0xFF000000),
    this.icon = const Icon(Icons.folder),
  });

  Map<String, Document> documents = {};

  void addDocument(Document document) {
    documents[document.uuid] = document;
  }

  void removeDocument(Document document) {
    documents.remove(document.uuid);
  }
}
