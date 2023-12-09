import 'package:flutter/material.dart';

import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/document.dart';
import 'package:catorganizer/src/models/tag.dart';

class ManifestModel extends ChangeNotifier {
  final Map<String, CategoryModel> _categories = {};
  final Map<String, DocumentModel> _documents = <String, DocumentModel>{};

  Future<void> readManifest() async {
    notifyListeners();
  }

  Future<bool> writeManifest() async {
    notifyListeners();

    return true;
  }

  Future<void> initialize() async {
    await readManifest();
  }

  Future<void> initializeDummy() async {
    CategoryModel defaultCategory = CategoryModel.uncategorized();

    // Assign the dummy default category.
    _categories[CategoryModel.uncategorizedIdentifier] = defaultCategory;

    setDocument(DocumentModel(
      "/testA.pdf",
      "Test A Document",
      <TagModel>[const TagModel("shared")],
      defaultCategory,
    ));

    setDocument(DocumentModel(
      "/testB.pdf",
      "Test B Document",
      <TagModel>[const TagModel("shared"), const TagModel("unique")],
      defaultCategory,
    ));

    setDocument(DocumentModel(
      "/testC.pdf",
      "Test C Document",
      <TagModel>[],
      defaultCategory,
    ));

    for (final key in _documents.keys) {
      // Assign to a variable for easier reading.
      DocumentModel document = _documents[key]!;

      // Sub-par testing implementation...
      _categories[CategoryModel.uncategorizedIdentifier]!
          .assignDocument(document);
      document
          .assignCategory(_categories[CategoryModel.uncategorizedIdentifier]!);
    }
  }

  ManifestModel() {
    initializeDummy();
  }

  ManifestModel.withDocuments(Map<String, DocumentModel> documents) {
    _categories[CategoryModel.uncategorizedIdentifier] =
        CategoryModel.uncategorized();

    for (final key in _documents.keys) {
      // Assign to a variable for easier reading.
      DocumentModel document = _documents[key]!;

      // Sub-par testing implementation...
      _categories[CategoryModel.uncategorizedIdentifier]!
          .assignDocument(document);

      document
          .assignCategory(_categories[CategoryModel.uncategorizedIdentifier]!);
    }
  }

  Map<String, CategoryModel> getCategories() {
    return _categories;
  }

  CategoryModel? getCategory(String id) {
    return _categories[id];
  }

  Future<void> setCategory(CategoryModel category) async {
    _categories[category.id] = category;

    await writeManifest();
  }

  Future<void> deleteCategory(CategoryModel category) async {
    _categories.remove(category.id);

    await writeManifest();
  }

  Map<String, DocumentModel> getDocuments() {
    return _documents;
  }

  DocumentModel? getDocument(String id) {
    return _documents[id];
  }

  Future<void> setDocument(DocumentModel document) async {
    _documents[document.uuid] = document;

    document.category.assignDocument(document);

    await writeManifest();
  }

  Future<void> deleteDocument(DocumentModel document) async {
    _documents.remove(document.uuid);

    document.category.removeDocument(document);

    await writeManifest();
  }
}
