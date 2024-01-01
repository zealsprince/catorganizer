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

    File manifestFile = File(path.join(directory, constants.manifestFileName));

    bool exists = false;
    String data = "";
    if (await manifestFile.exists()) {
      data = await manifestFile.readAsString();
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
        if (contents.containsKey('categories')) {
          Map<String, dynamic> categories =
              contents['categories'] as Map<String, dynamic>;

          // We can now let the categories deserialize themselves.
          for (String key in categories.keys) {
            CategoryModel category =
                CategoryModel.fromJson(key, categories[key]);

            // Insert the category by its ID.
            _categories[category.id] = category;
          }
        }

        // Handle documents.
        if (contents.containsKey('documents')) {
          Map<String, dynamic> documents =
              contents['documents'] as Map<String, dynamic>;

          // We can now let the categories deserialize themselves.
          for (String key in documents.keys) {
            DocumentModel document =
                DocumentModel.fromJson(key, documents[key]);

            // Insert the category by its UUID.
            _documents[document.getUUID()] = document;

            // Assign the document to its category if it exists.
            CategoryModel? category = getCategory(document.category);

            // Make sure we can and have found the category the document specifies.
            if (category != null) {
              category.assignDocument(document); // If so, assign.
            } else {
              // If not, check if we have the default category. If not, create it.
              if (getCategory(CategoryModel.uncategorizedIdentifier) == null) {
                setCategory(CategoryModel.uncategorized());
              }

              // We can be sure it exists now. Assign the document.
              getCategory(CategoryModel.uncategorizedIdentifier)!
                  .assignDocument(document);
            }
          }
        }
      } catch (e, s) {
        error = 'Error: ${e.toString()}\n\nStack Trace:\n${s.toString()}';
      }
    } else {
      // Create the configuration file.
      manifestFile.create();

      JsonEncoder encoder = const JsonEncoder.withIndent('  ');

      // Write the empty sanitized data model with the default category.
      manifestFile.writeAsString(encoder.convert({
        "categories": {
          CategoryModel.uncategorizedIdentifier: CategoryModel.uncategorized()
        },
        "documents": {},
      }));

      // Assign the default category as otherwise non are present.
      _categories[CategoryModel.uncategorizedIdentifier] =
          CategoryModel.uncategorized();
    }

    notifyListeners();
  }

  Future<bool> writeManifest() async {
    error = ""; // Reset our error in case a reload happens.

    final directory = Directory.current.path; // Get the current execution path.

    File manifestFile = File(path.join(directory, constants.manifestFileName));

    // If for some reason the manifest file doesn't exist, create it again.
    if (!await manifestFile.exists()) {
      manifestFile.create();
    }

    try {
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');

      // Write the current state to the manifest file.
      manifestFile.writeAsString(encoder.convert({
        "categories": _categories,
        "documents": _documents,
      }));
    } catch (e, s) {
      error = 'Error: ${e.toString()}\n\nStack Trace:\n${s.toString()}';
    }

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
      defaultCategory.id,
      "/testA.pdf",
      "Test A Document",
      <TagModel>[const TagModel("shared")],
    ));

    setDocument(DocumentModel(
      defaultCategory.id,
      "/testB.pdf",
      "Test B Document",
      <TagModel>[const TagModel("shared"), const TagModel("unique")],
    ));

    setDocument(DocumentModel(
      defaultCategory.id,
      "/testC.pdf",
      "Test C Document",
      <TagModel>[],
    ));

    for (final key in _documents.keys) {
      // Assign to a variable for easier reading.
      DocumentModel document = _documents[key]!;

      // Sub-par testing implementation...
      _categories[CategoryModel.uncategorizedIdentifier]!
          .assignDocument(document);
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

    // Make sure we can and have found the category the document specifies.
    CategoryModel? category = getCategory(document.category);
    if (category != null) {
      category.assignDocument(document); // If so, assign.
    } else {
      // If not, check if we have the default category. If not, create it.
      if (getCategory(CategoryModel.uncategorizedIdentifier) == null) {
        setCategory(CategoryModel.uncategorized());
      }

      // We can be sure it exists now. Assign the document.
      getCategory(CategoryModel.uncategorizedIdentifier)!
          .assignDocument(document);
    }

    await writeManifest();
  }

  Future<void> deleteDocument(DocumentModel document) async {
    _documents.remove(document.getUUID());

    // Make sure we can and have found the category the document specifies.
    CategoryModel? category = getCategory(document.category);
    if (category != null) {
      category.unassignDocument(document); // If so, unassign.
    }

    await writeManifest();
  }
}
