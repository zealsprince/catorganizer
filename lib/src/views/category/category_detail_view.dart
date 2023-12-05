import 'package:flutter/material.dart';

import 'package:catorganizer/src/models/category.dart';

/// Displays detailed information about a Document.
class CategoryDetailView extends StatelessWidget {
  final CategoryModel category;

  const CategoryDetailView({super.key, required this.category});

  static const routeName = '/category-details';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category'),
      ),
      body: const Center(
        child: Text('Category options here'),
      ),
    );
  }
}
