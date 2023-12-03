import 'package:file_selector/file_selector.dart';

import 'package:catorganizer/src/classes/category.dart';
import 'package:catorganizer/src/classes/document.dart';
import 'package:catorganizer/src/classes/tag.dart';

class Manifest {
  Map<String, Category> categories = {};
  Map<String, Document> documents = <String, Document>{};

  Future<void> readManifest() async {}

  Future<bool> writeManifest() async {
    return true;
  }

  Future<void> initialize() async {}

  Future<void> initializeDummy() async {
    categories[Category.uncategorizedIdentifier] = Category.uncategorized();

    documents["0"] = Document(
      "0",
      "Test A Document",
      "/testA.pdf",
      <Tag>[const Tag("shared")],
    );

    documents["1"] = Document(
      "1",
      "Test B Document",
      "/testB.pdf",
      <Tag>[const Tag("shared"), const Tag("unique")],
    );

    documents["2"] = Document(
      "2",
      "Test C Document",
      "/testC.pdf",
      <Tag>[],
    );

    for (final key in documents.keys) {
      // Assign to a variable for easier reading.
      Document document = documents[key]!;

      // Sub-par testing implementation...
      categories[Category.uncategorizedIdentifier]!.addDocument(document);
      document.assign(categories[Category.uncategorizedIdentifier]!);
    }
  }

  Manifest() {
    initializeDummy();
  }

  Manifest.withDocuments(this.documents) {
    categories[Category.uncategorizedIdentifier] = Category.uncategorized();

    for (final key in documents.keys) {
      // Assign to a variable for easier reading.
      Document document = documents[key]!;

      // Sub-par testing implementation...
      categories[Category.uncategorizedIdentifier]!.addDocument(document);
      document.assign(categories[Category.uncategorizedIdentifier]!);
    }
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
        categories[Category.uncategorizedIdentifier]!,
      );

      // Append this new document to the global document pool.
      documents[document.uuid] = document;

      // The next step is to assign them to a category as well.
      categories[Category.uncategorizedIdentifier]!.addDocument(document);
    }

    return;
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
      documents[document.uuid] = document;

      // The next step is to assign them to a category as well.
      categories[id]!.addDocument(document);
    }

    return;
  }

  Future<void> registerCategory(Category category) async {
    categories[category.id] = category;

    await writeManifest();
  }

  Future<void> unregisterCategory(Category category) async {
    categories.remove(category.id);

    await writeManifest();
  }

  Future<void> registerDocument(Document document) async {
    documents[document.uuid] = document;

    await writeManifest();
  }

  Future<void> unregisterDocument(Document document) async {
    documents.remove(document.uuid);

    await writeManifest();
  }
}
