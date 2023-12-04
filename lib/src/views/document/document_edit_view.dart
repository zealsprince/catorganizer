import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:catorganizer/src/helpers/helpers.dart';

import 'package:catorganizer/src/common_widgets/marked_icon.dart';
import 'package:catorganizer/src/common_widgets/tag_row.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/classes/document.dart';
import 'package:catorganizer/src/classes/category.dart';
import 'package:catorganizer/src/classes/tag.dart';

import 'package:catorganizer/src/views/document/document_list_view.dart';
import 'package:catorganizer/src/views/document/document_in_category_list_view.dart';
import 'package:flutter/services.dart';

class DocumentEditViewArguments {
  final String id;
  final Manifest manifest;

  DocumentEditViewArguments({
    required this.id,
    required this.manifest,
  });
}

class DocumentEditView extends StatefulWidget {
  final DocumentEditViewArguments arguments;

  const DocumentEditView({super.key, required this.arguments});

  static const routeName = '/document-edit';

  @override
  _DocumentEditViewState createState() => _DocumentEditViewState();
}

/// Displays detailed information about a Document.
class _DocumentEditViewState extends State<DocumentEditView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  void _changeCategory(Document document, Category category) {
    document.category = category;
  }

  void _addTag(String text, Document document) {
    // TODO: Make tags only apply on save.
    if (text == "") return;

    _tagController.text = ""; // Reset the tag controller input.

    document.addTag(Tag(text.toLowerCase()));

    widget.arguments.manifest.setDocument(document);
  }

  void _save(BuildContext context, Document document) {
    document.title = _titleController.text;

    widget.arguments.manifest.setDocument(document);

    Navigator.pop(context);
  }

  void _delete(BuildContext context, Document document) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Please Confirm'),
          content: const Text('Are you sure you want to delete this document?'),
          actions: [
            // The "Yes" button
            TextButton(
                onPressed: () {
                  widget.arguments.manifest.deleteDocument(document);

                  Navigator.popUntil(
                    context,
                    (route) =>
                        route.settings.name == DocumentListView.routeName ||
                        route.settings.name ==
                            DocumentInCategoryListView.routeName,
                  );
                },
                child: const Text('Yes')),
            TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('No'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Assign the document from the manifest by it's ID if it exists. Otherwise use an empty document.
    Document document =
        (widget.arguments.manifest.getDocument(widget.arguments.id) != null)
            ? widget.arguments.manifest.getDocument(widget.arguments.id)!
            : Document.empty();

    _titleController.text = document.title;

    List<DropdownMenuItem<Category>> categoryMenuItems = [];
    for (Category category in widget.arguments.manifest
        .getCategories()
        .entries
        .map((category) => category.value)
        .toList()) {
      categoryMenuItems.add(DropdownMenuItem(
        value: category,
        child: Row(
          children: [
            MarkedIcon(
              color: hexARGBToColor(document.category.color),
              icon: Icon(getMaterialIcon(document.category.icon)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(document.category.title),
            ),
          ],
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editing: ${document.title}'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------- Title text field ----------------------
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
            child: Row(
              children: [
                Text(
                  "Title:",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Document Title',
              ),
            ),
          ),
          const Divider(),
          // --------------------- Category selection ---------------------
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
            padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
            child: DropdownButton<Category>(
              alignment: Alignment.topLeft,
              isExpanded: true,
              value: document.category,
              onChanged: (category) => _changeCategory(document, category!),
              items: categoryMenuItems,
            ),
          ),
          const Divider(),
          // ----------------------------- Tags ----------------------------
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
            child: Row(
              children: [
                Text(
                  "Tags:",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: ListenableBuilder(
              listenable: widget.arguments.manifest,
              builder: (context, Widget? child) => TagRow(
                count: 100,
                size: 14,
                values: document.getTags().map((tag) => tag.value).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.tight(
                    const Size(240, 64),
                  ),
                  child: TextField(
                    maxLength: 24,
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9\-]'),
                      ),
                    ],
                    controller: _tagController,
                    onSubmitted: (text) => _addTag(text, document),
                    style: const TextStyle(
                      height: 1,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a tag',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => _addTag(_tagController.text, document),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(36),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const Divider(),
          // --------------------------- Buttons ---------------------------
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () => _save(context, document),
                    child: const Text("Save Changes"),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFFFF0000),
                    ),
                    overlayColor: MaterialStateProperty.all<Color>(
                      const Color(0x44FF0000),
                    ),
                  ),
                  onPressed: () => _delete(context, document),
                  child: const Text("Delete Document"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
