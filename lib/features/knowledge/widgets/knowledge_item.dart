// lib/models/knowledge_item.dart
import 'package:flutter/material.dart';

class KnowledgeItem {
  final String id; // <-- THÊM MỚI
  String title;
  String description;

  KnowledgeItem({
    required this.title,
    required this.description,
    String? id, // <-- THÊM MỚI
  }) : id = id ?? UniqueKey().toString(); // <-- THÊM MỚI: Tự động tạo ID nếu không có
}