import 'package:flutter/material.dart';

import 'package:catorganizer/src/constants.dart' as constants;
import 'package:catorganizer/src/models/document.dart';

/// A placeholder class that represents an entity or model.
class CategoryModel {
  static const String uncategorizedIdentifier = "uncategorized";
  static const String uncategorizedTitle = "Uncategorized";

  String id = uncategorizedIdentifier;
  String title = "";
  String description = "";
  Color color = constants.defaultColor;
  Icon icon = constants.defaultIcon;

  Map<String, DocumentModel> _documents = {};

  CategoryModel({
    this.id = uncategorizedIdentifier,
    this.title = "",
    this.description = "",
    this.color = constants.defaultColor,
    this.icon = constants.defaultIcon,
  });

  CategoryModel.withDocuments(
    Map<String, DocumentModel> documents, {
    this.id = uncategorizedIdentifier,
    this.title = "",
    this.description = "",
    this.color = constants.defaultColor,
    this.icon = constants.defaultIcon,
  }) {
    _documents = documents;
  }

  CategoryModel.uncategorized()
      : this(
          id: uncategorizedIdentifier,
          title: uncategorizedTitle,
          description: "Documents that have not been assigned to any category",
          color: constants.defaultColor,
          icon: constants.defaultIcon,
        );

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    title = json['title'] as String;
    description = json['description'] as String;

    color = json['color']
        ? Color(
            json['color'] as int,
          )
        : constants.defaultColor;

    icon = json['icon']
        ? Icon(
            IconData(json['icon'] as int),
          )
        : constants.defaultIcon;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color.value,
      'icon': icon.icon!.codePoint,
    };
  }

  Map<String, DocumentModel> getDocumets() {
    return _documents;
  }

  String getID() {
    return id;
  }

  void assignDocument(DocumentModel document) {
    _documents[document.getUUID()] = document;
  }

  void removeDocument(DocumentModel document) {
    _documents.remove(document.getUUID());
  }
}
