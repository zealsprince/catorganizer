import 'package:file_selector/file_selector.dart';

import 'package:catorganizer/src/classes/category.dart';
import 'package:catorganizer/src/classes/document.dart';
import 'package:catorganizer/src/classes/tag.dart';
import 'package:flutter/material.dart';

class Manifest extends ChangeNotifier {
  final Map<String, Category> _categories = {};
  final Map<String, Document> _documents = <String, Document>{};

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
    _categories[Category.uncategorizedIdentifier] = Category.uncategorized();

    _documents["0"] = Document(
      "0",
      "Test A Document",
      "/testA.pdf",
      <Tag>[const Tag("shared")],
    );

    _documents["1"] = Document(
      "1",
      "Test B Document",
      "/testB.pdf",
      <Tag>[const Tag("shared"), const Tag("unique")],
    );

    _documents["2"] = Document(
      "2",
      "Test C Document",
      "/testC.pdf",
      <Tag>[],
    );

    for (final key in _documents.keys) {
      // Assign to a variable for easier reading.
      Document document = _documents[key]!;

      // Sub-par testing implementation...
      _categories[Category.uncategorizedIdentifier]!.assignDocument(document);
      document.assign(_categories[Category.uncategorizedIdentifier]!);
    }
  }

  Manifest() {
    initializeDummy();
  }

  Manifest.withDocuments(Map<String, Document> documents) {
    _categories[Category.uncategorizedIdentifier] = Category.uncategorized();

    for (final key in _documents.keys) {
      // Assign to a variable for easier reading.
      Document document = _documents[key]!;

      // Sub-par testing implementation...
      _categories[Category.uncategorizedIdentifier]!.assignDocument(document);
      document.assign(_categories[Category.uncategorizedIdentifier]!);
    }
  }

  Map<String, Category> getCategories() {
    return _categories;
  }

  Category? getCategory(String id) {
    return _categories[id];
  }

  Map<String, Document> getDocuments() {
    return _documents;
  }

  Document? getDocument(String id) {
    return _documents[id];
  }

  Future<void> setCategory(Category category) async {
    _categories[category.id] = category;

    await writeManifest();
  }

  Future<void> deleteCategory(Category category) async {
    _categories.remove(category.id);

    await writeManifest();
  }

  Future<void> setDocument(Document document) async {
    _documents[document.uuid] = document;

    document.category.assignDocument(document);

    await writeManifest();
  }

  Future<void> deleteDocument(Document document) async {
    _documents.remove(document.uuid);

    document.category.removeDocument(document);

    await writeManifest();
  }

  Future<void> addUncategorizedDocumentsSelection() async {
    late List<XFile> files;

    files = await openFiles();

    for (final file in files) {
      Document document = Document.withCategory(
        file.path,
        file.path,
        file.path,
        [],
        _categories[Category.uncategorizedIdentifier]!,
      );

      // Append this new document to the global document pool.
      _documents[document.uuid] = document;

      // The next step is to assign them to a category as well.
      _categories[Category.uncategorizedIdentifier]!.assignDocument(document);
    }

    await writeManifest();
  }

  Future<void> addCategorizedDocumentsSelection(String id) async {
    late List<XFile> files;

    files = await openFiles();

    for (final file in files) {
      Document document = Document(
        file.path,
        file.path,
        file.path,
        [],
      );

      // Append this new document to the global document pool.
      _documents[document.uuid] = document;

      // The next step is to assign them to a category as well.
      _categories[id]!.assignDocument(document);
    }

    await writeManifest();
  }
}
