import 'package:flutter/material.dart';

import 'package:catorganizer/src/classes/category.dart';

/// Displays detailed information about a Document.
class CategoryDetailView extends StatelessWidget {
  final Category category;

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
