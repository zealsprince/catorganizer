import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_selector/file_selector.dart';

import 'package:catorganizer/src/models/manifest.dart';
import 'package:catorganizer/src/models/document.dart';
import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/tag.dart';

import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/views/document/document_list_view.dart';
import 'package:catorganizer/src/views/document/document_in_category_list_view.dart';

class DocumentNewViewArguments {
  final ManifestModel manifest;
  final XFile file;
  final CategoryModel? category;

  DocumentNewViewArguments({
    required this.manifest,
    required this.file,
    this.category,
  });
}

// This custom class handles the tag adding / removing dialog as we don't want
// to bind directly to the document as this would manipulate it before
// performing the save action.
final class _DocumentNewViewTagsController extends ChangeNotifier {
  List<TagModel> tags = [];

  // Return a boolean to confirm if a tag was added without duplication.
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

  // Return a boolean to confirm if a tag was removed.
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

class DocumentNewView extends StatefulWidget {
  final DocumentNewViewArguments arguments;

  const DocumentNewView({super.key, required this.arguments});

  static const routeName = '/document-new';

  @override
  State<DocumentNewView> createState() => _DocumentNewViewState();
}

/// Displays detailed information about a Document.
class _DocumentNewViewState extends State<DocumentNewView> {
  final DocumentModel document = DocumentModel.empty();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController tagCreateController = TextEditingController();
  final SingleValueDropDownController tagDropdownController =
      SingleValueDropDownController();

  final _DocumentNewViewTagsController tagsController =
      _DocumentNewViewTagsController();

  void changeCategory(CategoryModel category) {
    document.category = category;
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
    document.title = titleController.text;
    document.setTags(tagsController.tags);

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
    // Make sure to build the widget from the supplied file.
    document.path = widget.arguments.file.path;

    // Remove the file extension and path for the placeholder title.
    document.title = widget.arguments.file.path
        .replaceAll(
          RegExp(r'\..+$'),
          '',
        )
        .replaceAll(
          RegExp(r'.+[\\\/]'),
          '',
        );

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
              color: document.category.color,
              icon: document.category.icon,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(document.category.title),
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
        title: const Text('New document'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------- Path ----------------------------
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
            padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      document.path,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
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
              value: widget.arguments.category,
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
            padding: const EdgeInsets.only(left: 16),
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
                          RegExp(r'[a-zA-Z0-9\-]'),
                        ),
                      ],
                      controller: tagCreateController,
                      onSubmitted: (text) => addTag(TagModel(text)),
                      style: const TextStyle(
                        height: 1,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Create a tag',
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
