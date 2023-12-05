import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

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

  Future<void> addUncategorizedDocumentsSelection() async {
    late List<XFile> files;

    files = await openFiles();

    for (final file in files) {
      DocumentModel document = DocumentModel(
        file.path,
        file.path,
        [],
        _categories[CategoryModel.uncategorizedIdentifier]!,
      );

      // Append this new document to the global document pool.
      _documents[document.uuid] = document;

      // The next step is to assign them to a category as well.
      _categories[CategoryModel.uncategorizedIdentifier]!
          .assignDocument(document);
    }

    await writeManifest();
  }

  Future<void> addCategorizedDocumentsSelection(String id) async {
    late List<XFile> files;

    files = await openFiles();

    for (final file in files) {
      DocumentModel document = DocumentModel(
        file.path,
        file.path,
        [],
        getCategory(id) == null
            ? _categories[CategoryModel.uncategorizedIdentifier]!
            : getCategory(id)!,
      );

      // Append this new document to the global document pool.
      _documents[document.uuid] = document;

      // The next step is to assign them to a category as well.
      _categories[id]!.assignDocument(document);
    }

    await writeManifest();
  }
}
