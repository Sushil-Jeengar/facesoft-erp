import 'package:flutter/foundation.dart';
import 'package:facesoft/API_services/item_api.dart';
import 'package:facesoft/model/item_model.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchItems() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _items = await ItemApiService.fetchItems();
    } catch (e) {
      _errorMessage = 'Failed to load items: $e';
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteItem(String itemId) async {
    _isLoading = true;
    notifyListeners();
    try {
      bool success = await ItemApiService.deleteItem(itemId);
      if (success) {
        _items.removeWhere((item) => item.id.toString() == itemId);
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to delete item';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete item: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ///Create item
  Future<bool> createItem(Item item) async {
    _isLoading = true;
    notifyListeners();
    try {
      final createdItem = await ItemApiService.createItem(item);
      if (createdItem != null) {
        _items.add(createdItem); // Add fresh item from backend
        _errorMessage = '';
        return true;
      } else {
        _errorMessage = 'Failed to create item';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to create item: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ///Update item
  Future<bool> updateItem(String itemId, Item updatedItem) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newItem = await ItemApiService.updateItem(itemId, updatedItem);
      if (newItem != null) {
        int index = _items.indexWhere((item) => item.id.toString() == itemId);
        if (index != -1) {
          _items[index] = newItem; // Replace with updated version from backend
        }
        _errorMessage = '';
        return true;
      } else {
        _errorMessage = 'Failed to update item';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update item: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
