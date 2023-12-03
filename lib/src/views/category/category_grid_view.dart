import 'package:flutter/material.dart';

import 'package:catorganizer/src/helpers/helpers.dart';

import 'package:catorganizer/src/classes/category.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/views/settings/settings_view.dart';
import 'package:catorganizer/src/views/category/category_list_view.dart';
import 'package:catorganizer/src/views/document/document_list_view.dart';
import 'package:catorganizer/src/views/document/document_in_category_list_view.dart';

/// Displays a grid of categories.
class CategoryGridView extends StatefulWidget {
  final Manifest manifest;

  const CategoryGridView({super.key, required this.manifest});

  static const routeName = '/category-grid';

  @override
  _CategoryGridViewState createState() => _CategoryGridViewState();
}

class _CategoryGridViewState extends State<CategoryGridView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                DocumentListView.routeName,
                arguments: widget.manifest,
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              CategoryListView.routeName,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                widget.manifest.addUncategorizedDocumentsSelection(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // Create a custom builder that iterates over categories and creates tiles
      // for each one with the category's styling.
      body: ListenableBuilder(
        listenable: widget.manifest,
        builder: (context, Widget? child) {
          List<Category> categoriesList = widget.manifest
              .getCategories()
              .entries
              .map((category) => category.value)
              .toList();

          List<Widget> children = [];

          for (Category category in categoriesList) {
            children.add(
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                hoverColor: hexARGBToColor(category.color).withAlpha(0x11),
                splashColor: hexARGBToColor(category.color).withAlpha(0x44),
                highlightColor: hexARGBToColor(category.color).withAlpha(0x33),
                onTap: () {
                  // Navigate to the details page. If the user leaves and returns to
                  // the app after it has been killed while running in the
                  // background, the navigation stack is restored.
                  Navigator.pushNamed(
                    context,
                    DocumentInCategoryListView.routeName,
                    arguments: DocumentInCategoryListViewArguments(
                        id: category.id, manifest: widget.manifest),
                  );
                },
                child: Card(
                  color: const Color(0x00000000),
                  surfaceTintColor:
                      hexARGBToColor(category.color).withAlpha(0x44),
                  shadowColor: const Color(0x22000000),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        getMaterialIcon(category.icon),
                        color: hexARGBToColor(category.color),
                        size: 64,
                      ),
                      Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 21,
                        ),
                      ),
                      Text(
                        '(${category.documents.length})',
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: children,
          );
        },
      ),
    );
  }
}
