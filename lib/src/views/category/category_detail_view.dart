import 'package:flutter/material.dart';

/// Displays detailed information about a Document.
class CategoryDetailView extends StatelessWidget {
  const CategoryDetailView({super.key});

  static const routeName = '/category';

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
