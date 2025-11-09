import 'package:flutter/material.dart';

/// Model for AI Action items
class ActionItem {
  final String name;
  final String description;
  final IconData icon;
  final Widget page;

  const ActionItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.page,
  });
}
