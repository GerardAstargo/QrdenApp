import 'dart:io';

class Item {
  final String id;
  final String title;
  final String description;
  final File image;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });
}
