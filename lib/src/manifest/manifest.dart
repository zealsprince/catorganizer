import 'package:file_selector/file_selector.dart';

import 'package:catorganizer/src/classes/category.dart';
import 'package:catorganizer/src/classes/document.dart';
import 'package:catorganizer/src/classes/tag.dart';

class Manifest {
  Manifest() {
    readManifest();
  }

  Map<String, Category> categories = {};
  List<Document> documents = <Document>[];

  Manifest.withDocuments(this.documents) {
    categories[Category.uncategorizedIdentifier] = Category.uncategorized();

    for (final document in documents) {
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
      documents.add(document);

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
      documents.add(document);

      // The next step is to assign them to a category as well.
      categories[id]!.addDocument(document);
    }

    return;
  }

  // TODO: Create read write methods.
  Future<void> readManifest() async {}

  Future<bool> writeManifest() async {
    return true;
  }
}
