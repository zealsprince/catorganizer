import 'package:flutter/material.dart';

import 'package:catorganizer/src/helpers/helpers.dart';

import 'package:catorganizer/src/common_widgets/tag_row.dart';
import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/classes/document.dart';

import 'package:catorganizer/src/views/document/document_edit_view.dart';

class DocumentDetailViewArguments {
  final String id;
  final Manifest manifest;

  DocumentDetailViewArguments({
    required this.id,
    required this.manifest,
  });
}

/// Displays detailed information about a Document.
class DocumentDetailView extends StatelessWidget {
  final DocumentDetailViewArguments arguments;

  const DocumentDetailView({super.key, required this.arguments});

  static const routeName = '/document';

  @override
  Widget build(BuildContext context) {
    // Assign the document from the manifest by it's ID if it exists. Otherwise use an empty document.
    Document document = (arguments.manifest.getDocument(arguments.id) != null)
        ? arguments.manifest.getDocument(arguments.id)!
        : Document.empty();

    return Scaffold(
      appBar: AppBar(title: Text(document.title), actions: [
        IconButton(
            icon: const Icon(Icons.edit_document),
            onPressed: () => Navigator.pushNamed(
                  context,
                  DocumentEditView.routeName,
                  arguments: DocumentEditViewArguments(
                    id: document.uuid,
                    manifest: arguments.manifest,
                  ),
                )),
      ]),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
            child: Row(
              children: [
                Text(
                  "Path:",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(document.path)),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
            child: Row(
              children: [
                Text(
                  "Category:",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                MarkedIcon(
                  color: hexARGBToColor(document.category.color),
                  icon: Icon(getMaterialIcon(document.category.icon)),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(document.category.title)),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
            child: Row(
              children: [
                Text(
                  document.tags.isEmpty ? "" : "Tags:",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                Tags(
                  count: 100,
                  size: 14,
                  values: document.tags.map((tag) => tag.value).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
