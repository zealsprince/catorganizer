import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:catorganizer/src/constants.dart' as constants;
import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/document.dart';
import 'package:catorganizer/src/models/tag.dart';

class ManifestDataModel {
  final Map<String, CategoryModel> categories = {};
  final Map<String, DocumentModel> documents = <String, DocumentModel>{};
}

class ManifestModel extends ChangeNotifier {
  final Map<String, CategoryModel> _categories = {};
  final Map<String, DocumentModel> _documents = <String, DocumentModel>{};

  Future<void> readManifest() async {
    final directory = Directory.current.path; // Get the current execution path.

    ManifestDataModel data = ManifestDataModel(); // Create a sanitized model.

    File configurationFile =
        File(path.join(directory, constants.manifestFileName));

    if (await configurationFile.exists()) {
      // Read the configuration file.
      String contents = await configurationFile.readAsString();

      data = jsonDecode(contents)
          as ManifestDataModel; // Attempt to read as our sanitized Manifest data model.

      _categories.addAll(data.categories);
      _documents.addAll(data.documents);
    } else {
      // Create the configuration file.
      configurationFile.create();

      // Write the empty sanitized data model.
      configurationFile.writeAsString(json.encode(data));
    }

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
    initialize();
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
