// lib/models/knowledge_item.dart
import 'package:flutter/material.dart';

class KnowledgeItem {
  final String id;
  String title;
  String description;

  KnowledgeItem({required this.title, required this.description, String? id})
    : id = id ?? UniqueKey().toString();
}
