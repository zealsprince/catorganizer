import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:catorganizer/src/constants.dart' as constants;
import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/document.dart';
import 'package:catorganizer/src/models/tag.dart';

class ManifestModel extends ChangeNotifier {
  final Map<String, CategoryModel> _categories = {};
  final Map<String, DocumentModel> _documents = <String, DocumentModel>{};

  // Store possible read errors in here to relay back to the application.
  String error = "";

  Future<void> readManifest() async {
    error = ""; // Reset our error in case a reload happens.

    final directory = Directory.current.path; // Get the current execution path.

    File configurationFile =
        File(path.join(directory, constants.manifestFileName));

    bool exists = false;
    String data = "";
    if (await configurationFile.exists()) {
      data = await configurationFile.readAsString();
      if (data != "") {
        exists = true;
      }
    }

    // Make sure that our file exists and has content.
    if (exists) {
      try {
        // Read the configuration file and contents as JSON into a dynamic string Map.
        Map<String, dynamic> contents = jsonDecode(data);

        // Handle categories.
        if (contents["categories"]) {
          Map<String, dynamic> categories =
              contents["categories"] as Map<String, dynamic>;

          // We can now let the categories deserialize themselves.
          for (Map<String, dynamic> json in categories.values) {
            CategoryModel category = CategoryModel.fromJson(json);

            // Insert the category by its ID.
            _categories[category.id] = category;
          }
        }

        // Handle documents.
        if (contents["documents"]) {
          Map<String, dynamic> documents =
              contents["documents"] as Map<String, dynamic>;

          // We can now let the categories deserialize themselves.
          for (Map<String, dynamic> json in documents.values) {
            DocumentModel document = DocumentModel.fromJson(json);

            // Insert the category by its UUID.
            _documents[document.getUUID()] = document;
          }
        }
      } catch (e) {
        error = e.toString();
      }
    } else {
      // Create the configuration file.
      configurationFile.create();

      // Write the empty sanitized data model.
      configurationFile.writeAsString(json.encode({
        "categories": {},
        "documents": {},
      }));
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
    _documents[document.getUUID()] = document;

    document.category.assignDocument(document);

    await writeManifest();
  }

  Future<void> deleteDocument(DocumentModel document) async {
    _documents.remove(document.getUUID());

    document.category.removeDocument(document);

    await writeManifest();
  }
}
