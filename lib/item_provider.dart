import 'dart:io';
import 'package:flutter/material.dart';
import './item_model.dart';

class ItemProvider with ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => [..._items];

  void addItem(String title, String description, File image) {
    final newItem = Item(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      image: image,
    );
    _items.add(newItem);
    notifyListeners();
  }

  void updateItem(String id, String newTitle, String newDescription, File newImage) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      final updatedItem = Item(
        id: id,
        title: newTitle,
        description: newDescription,
        image: newImage,
      );
      _items[itemIndex] = updatedItem;
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
