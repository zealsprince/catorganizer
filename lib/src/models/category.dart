import 'package:flutter/material.dart';

import 'package:catorganizer/src/models/document.dart';

/// A placeholder class that represents an entity or model.
class CategoryModel {
  static const String uncategorizedIdentifier = "uncategorized";
  static const String uncategorizedTitle = "Uncategorized";

  final String id;
  String title;
  String description;
  Color color;
  Icon icon;

  Map<String, DocumentModel> _documents = {};

  CategoryModel({
    this.id = uncategorizedIdentifier,
    this.title = "",
    this.description = "",
    this.color = const Color(0xff6750a4),
    this.icon = const Icon(Icons.folder),
  });

  CategoryModel.withDocuments(Map<String, DocumentModel> documents,
      {this.id = uncategorizedIdentifier,
      this.title = "",
      this.description = "",
      this.color = const Color(0xff6750a4),
      this.icon = const Icon(Icons.folder)}) {
    _documents = documents;
  }

  CategoryModel.uncategorized()
      : this(
          id: uncategorizedIdentifier,
          title: uncategorizedTitle,
          description: "Documents that have not been assigned to any category",
          color: const Color(0xff6750a4),
          icon: const Icon(Icons.folder),
        );

  Map<String, DocumentModel> getDocumets() {
    return _documents;
  }

  void assignDocument(DocumentModel document) {
    _documents[document.uuid] = document;
  }

  void removeDocument(DocumentModel document) {
    _documents.remove(document.uuid);
  }
}
