import 'package:flutter/material.dart';

import 'package:catorganizer/src/classes/category.dart';

import 'package:catorganizer/src/manifest/manifest.dart';

import 'package:catorganizer/src/views/settings/settings_view.dart';
import 'package:catorganizer/src/views/category/category_list_view.dart';
import 'package:catorganizer/src/views/document/document_list_view.dart';
import 'package:catorganizer/src/views/document/document_in_category_list_view.dart';

/// Displays a list of categories.
class CategoryGridView extends StatelessWidget {
  final Manifest manifest;

  late final List<Category> categoriesList;

  CategoryGridView({super.key, required this.manifest}) {
    categoriesList =
        manifest.categories.entries.map((category) => category.value).toList();
  }

  static const routeName = '/category-grid';

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
                arguments: manifest,
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
            onPressed: () => manifest.addUncategorizedDocumentsSelection(),
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
      body: Builder(
        builder: (context) {
          List<Widget> children = [];

          for (Category category in categoriesList) {
            children.add(
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                hoverColor: category.color.withAlpha(0x11),
                splashColor: category.color.withAlpha(0x44),
                highlightColor: category.color.withAlpha(0x33),
                onTap: () {
                  // Navigate to the details page. If the user leaves and returns to
                  // the app after it has been killed while running in the
                  // background, the navigation stack is restored.
                  Navigator.pushNamed(
                    context,
                    DocumentInCategoryListView.routeName,
                    arguments: DocumentInCategoryListViewArguments(
                        id: category.id, manifest: manifest),
                  );
                },
                child: Card(
                  color: const Color(0x00000000),
                  surfaceTintColor: category.color.withAlpha(0x44),
                  shadowColor: const Color(0x22000000),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category.icon.icon,
                        color: category.color,
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
