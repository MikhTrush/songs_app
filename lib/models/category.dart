import 'package:flutter/material.dart';

class CategoryModel {
  String name;
  IconData icon;
  String colorHex; // Using hex color string for more flexibility

  CategoryModel({
    required this.name,
    required this.icon,
    required this.colorHex,
  });

  // Return a sample list of meaningful categories/tags
  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];

    categories.add(
      CategoryModel(
        name: 'Hymns',
        icon: Icons.music_note,
        colorHex: '#FF6B6B',
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Praise',
        icon: Icons.star,
        colorHex: '#4ECDC4',
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Worship',
        icon: Icons.favorite,
        colorHex: '#45B7D1',
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Gospel',
        icon: Icons.library_music,
        colorHex: '#96CEB4',
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Christmas',
        icon: Icons.ac_unit,
        colorHex: '#FFEAA7',
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Easter',
        icon: Icons.local_florist,
        colorHex: '#DDA0DD',
      ),
    );

    return categories;
  }
}