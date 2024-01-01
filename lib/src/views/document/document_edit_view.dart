import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/document.dart';
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

// Custom class to handle the dropdown button list changes.
final class _DocumentEditViewCategoryController extends ChangeNotifier {
  CategoryModel _category = CategoryModel.uncategorized();

  setCategory(CategoryModel category) {
    _category = category;

    notifyListeners();
  }

  CategoryModel getCategory() {
    return _category;
  }
}

// This custom class handles the tag adding / removing dialog as we don't want
// to bind directly to the document as this would manipulate it before
// performing the save action.
final class _DocumentEditViewTagsController extends ChangeNotifier {
  final List<TagModel> _tags = [];

  List<TagModel> getTags() {
    return _tags;
  }

  // Return a boolean to confirm if a tag was added without duplication.
  bool addTag(TagModel tag) {
    for (TagModel existingTag in _tags) {
      if (existingTag.value == tag.value) {
        return false;
      }
    }

    _tags.add(tag);

    notifyListeners();

    return true;
  }

  // Return a boolean to confirm if a tag was removed.
  bool removeTag(TagModel tag) {
    for (int i = 0; i < _tags.length; i++) {
      if (_tags[i].value == tag.value) {
        _tags.removeAt(i);

        notifyListeners();

        return true;
      }
    }

    return false;
  }
}

class DocumentEditView extends StatefulWidget {
  final DocumentEditViewArguments arguments;

  const DocumentEditView({super.key, required this.arguments});

  static const routeName = '/document-edit';

  @override
  State<DocumentEditView> createState() => _DocumentEditViewState();
}

/// Displays detailed information about a Document.
class _DocumentEditViewState extends State<DocumentEditView> {
  DocumentModel document = DocumentModel.empty();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController tagCreateController = TextEditingController();

  final _DocumentEditViewCategoryController categoryController =
      _DocumentEditViewCategoryController();

  final SingleValueDropDownController tagDropdownController =
      SingleValueDropDownController();

  final _DocumentEditViewTagsController tagsController =
      _DocumentEditViewTagsController();

  void changeCategory(CategoryModel category) {
    categoryController.setCategory(category);
  }

  // We have to mask our tag controller function here to additionally get access
  // to the input field form text.
  void addTag(TagModel tag) {
    if (tag.value == "") return;

    if (tagsController.addTag(tag)) {
      tagCreateController.text = ""; // Reset the tag controller input.
    }
  }

  // Modify our document and then update the manifest to propgate changes
  // across other views. Additionally flag writing of changes.
  void save(BuildContext context) {
    // FIXME: The manifest architecture should be rewritten to perform this step...
    CategoryModel category =
        widget.arguments.manifest.getCategory(document.category)!;

    // Make sure we remove the document from the old category.
    category.unassignDocument(document);

    // Re-assign to the new category.
    document.category = categoryController.getCategory().id;
    categoryController.getCategory().assignDocument(document);

    // Update the document information.
    document.title = titleController.text;
    document.setTags(tagsController.getTags());

    widget.arguments.manifest.setDocument(document);

    Navigator.pop(context);
  }

  // Delete this document with a confirmation dialog and routes pop.
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
    // Fetch the document from the manifest by the ID.
    document =
        (widget.arguments.manifest.getDocument(widget.arguments.id) != null)
            ? widget.arguments.manifest.getDocument(widget.arguments.id)!
            : DocumentModel.empty();

    // Fetch the document's category so we can display its information.
    CategoryModel? category =
        widget.arguments.manifest.getCategory(document.category);

    // If the category for some reason is unvailable fall back to the default.
    categoryController.setCategory(category ?? CategoryModel.uncategorized());

    titleController.text = document.title;

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
              color: category.color,
              icon: category.icon,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(category.title),
            ),
          ],
        ),
      ));
    }

    List<DropDownValueModel> tagDropdownItems = [];
    for (DocumentModel document
        in widget.arguments.manifest.getDocuments().values) {
      for (TagModel tag in document.getTags()) {
        bool found = false;

        for (DropDownValueModel item in tagDropdownItems) {
          if (item.value == tag.value) {
            found = true;
            break;
          }
        }

        if (!found) {
          tagDropdownItems.add(
            DropDownValueModel(name: '#${tag.value}', value: tag.value),
          );
        }
      }
    }

    // Create tags in the tags controller from the document by value.
    for (TagModel tag in document.getTags()) {
      tagsController.addTag(TagModel(tag.value));
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
              child: ListenableBuilder(
                listenable: categoryController,
                builder: (context, Widget? child) {
                  return DropdownButton<CategoryModel>(
                    alignment: Alignment.topLeft,
                    isExpanded: true,
                    value: categoryController.getCategory(),
                    onChanged: (category) => changeCategory(category!),
                    items: categoryMenuItems,
                  );
                },
              )),
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
            padding: const EdgeInsets.only(left: 16),
            child: ListenableBuilder(
                listenable: tagsController,
                builder: (context, Widget? child) {
                  List<Widget> tagItems = []; // Prepare our children list.

                  // Iterate over values and build out the tag widgets accordingly.
                  for (TagModel tag in tagsController.getTags()) {
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
                                  onPressed: () =>
                                      tagsController.removeTag(tag),
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
          // ------------------------- Tags Dropdown ------------------------
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                ListenableBuilder(
                  listenable: tagDropdownController,
                  builder: (context, Widget? child) => ConstrainedBox(
                    constraints: BoxConstraints.tight(
                      const Size(308, 42),
                    ),
                    child: DropDownTextField(
                      controller: tagDropdownController,
                      clearOption: false,
                      enableSearch: true,
                      dropdownColor: Colors.white,
                      textFieldDecoration: const InputDecoration(
                        hintStyle: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                        hintText: "Select an existing tag",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(36),
                          ),
                        ),
                      ),
                      dropDownList: tagDropdownItems,
                      onChanged: (value) {
                        tagDropdownController.clearDropDown();

                        DropDownValueModel v = value as DropDownValueModel;

                        addTag(TagModel(v.value));
                      },
                    ),
                  ),
                ),
                // ----------------------- Create Tag ----------------------
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 8),
                  child: ConstrainedBox(
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
                          RegExp(r'[a-zA-Z0-9\-\s]'),
                        ),
                      ],
                      controller: tagCreateController,
                      onChanged: (text) => tagCreateController.text =
                          tagCreateController
                              .text // Make sure we can't add extra whitespace.
                              .replaceAll(RegExp(r'\s+'), '-')
                              .replaceAll(RegExp(r'-+'), '-'),
                      onSubmitted: (text) => addTag(TagModel(text)),
                      style: const TextStyle(
                        height: 1,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Create a tag',
                        prefix: const Text('#'),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: () =>
                              addTag(TagModel(tagCreateController.text)),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(36),
                          ),
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
