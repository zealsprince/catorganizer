import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:catorganizer/src/helpers/helpers.dart';

import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/models/document.dart';
import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/tag.dart';

import 'package:catorganizer/src/views/document/document_list_view.dart';
import 'package:catorganizer/src/views/document/document_in_category_list_view.dart';

class DocumentEditViewArguments {
  final String id;
  final ManifestModel manifest;

  DocumentEditViewArguments({
    required this.id,
    required this.manifest,
  });
}

// This custom class handles the tag adding / removing dialog as we don't want
// to bind directly to the document as this would manipulate it before
// performing the save action.
final class _DocumentEditViewTagsController extends ChangeNotifier {
  List<TagModel> tags = [];

  bool addTag(TagModel tag) {
    for (TagModel existingTag in tags) {
      if (existingTag.value == tag.value) {
        return false;
      }
    }

    tags.add(tag);

    notifyListeners();

    return true;
  }

  bool removeTag(TagModel tag) {
    for (int i = 0; i < tags.length; i++) {
      if (tags[i].value == tag.value) {
        tags.removeAt(i);

        notifyListeners();

        return true;
      }
    }

    return false;
  }
}

class DocumentEditView extends StatefulWidget {
  final DocumentEditViewArguments arguments;

  DocumentModel _document = DocumentModel.empty();

  DocumentEditView({super.key, required this.arguments}) {
    _document = (arguments.manifest.getDocument(arguments.id) != null)
        ? arguments.manifest.getDocument(arguments.id)!
        : DocumentModel.empty();
  }

  static const routeName = '/document-edit';

  @override
  _DocumentEditViewState createState() => _DocumentEditViewState();
}

/// Displays detailed information about a Document.
class _DocumentEditViewState extends State<DocumentEditView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final _DocumentEditViewTagsController tagsController =
      _DocumentEditViewTagsController();

  void changeCategory(CategoryModel category) {
    widget._document.category = category;
  }

  void addTag(TagModel tag) {
    if (tag.value == "") return;

    if (tagsController.addTag(tag)) {
      tagController.text = ""; // Reset the tag controller input.
    }
  }

  void removeTag(TagModel tag) {
    if (tagsController.removeTag(tag)) {
      tagController.text = ""; // Reset the tag controller input.
    }
  }

  void save(BuildContext context) {
    widget._document.title = titleController.text;
    widget._document.setTags(tagsController.tags);

    widget.arguments.manifest.setDocument(widget._document);

    Navigator.pop(context);
  }

  void delete(BuildContext context) {
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
                  widget.arguments.manifest.deleteDocument(widget._document);

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
    titleController.text = widget._document.title;

    // Construct the category dropdown menu items.
    List<DropdownMenuItem<CategoryModel>> categoryMenuItems = [];
    for (CategoryModel category in widget.arguments.manifest
        .getCategories()
        .entries
        .map((category) => category.value)
        .toList()) {
      categoryMenuItems.add(DropdownMenuItem(
        value: category,
        child: Row(
          children: [
            MarkedIcon(
              color: widget._document.category.color,
              icon: widget._document.category.icon,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(widget._document.category.title),
            ),
          ],
        ),
      ));
    }

    // Create tags in the tags controller from the document by value.
    for (TagModel tag in widget._document.getTags()) {
      tagsController.addTag(TagModel(tag.value));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editing: ${widget._document.title}'),
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
              controller: titleController,
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
            child: DropdownButton<CategoryModel>(
              alignment: Alignment.topLeft,
              isExpanded: true,
              value: widget._document.category,
              onChanged: (category) => changeCategory(category!),
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
                listenable: tagsController,
                builder: (context, Widget? child) {
                  List<Widget> tagItems = []; // Prepare our children list.

                  // Iterate over values and build out the tag widgets accordingly.
                  for (TagModel tag in tagsController.tags) {
                    tagItems.add(
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 8),
                        child: Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32)),
                              color: Color(0x11000000)),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => removeTag(tag),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Text(
                                    '#${tag.value}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Wrap(children: tagItems);
                }),
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
                    controller: tagController,
                    onSubmitted: (text) => addTag(TagModel(text)),
                    style: const TextStyle(
                      height: 1,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a tag',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => addTag(TagModel(tagController.text)),
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
                    onPressed: () => save(context),
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
                  onPressed: () => delete(context),
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
