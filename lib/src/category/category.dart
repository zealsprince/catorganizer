import 'package:flutter/material.dart';

import 'package:catorganizer/src/document/document.dart';

/// A placeholder class that represents an entity or model.
class Category {
  const Category(this.id, this.title, this.description, this.color, this.icon,
      this.documents);

  final String id;
  final String title;
  final String description;
  final Color color;
  final Icon icon;

  final List<Document> documents;
}
