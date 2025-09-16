import 'package:flutter/foundation.dart';
import 'package:facesoft/API_services/order_api.dart';
import 'package:facesoft/model/order_model.dart';
import 'package:collection/collection.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchOrders({int? userId}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final fetchedOrders = await OrderApiService.fetchOrders(userId: userId);
      if (fetchedOrders != null) {
        if (userId != null) {
          _orders = fetchedOrders.where((order) => order.userId == userId).toList();
        } else {
          _orders = fetchedOrders;
        }
      } else {
        _orders = [];
      }
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await OrderApiService.deleteOrder(orderId);
      if (success) {
        _orders.removeWhere((order) => order.orderNumber == orderId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> getOrderById(int orderId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // First check if order exists in local list
      final existingOrder = _orders.firstWhereOrNull((order) => order.id == orderId);
      if (existingOrder != null) {
        return existingOrder;
      }
      
      // If not found locally, fetch from API
      final order = await OrderApiService.getOrderById(orderId);
      if (order != null) {
        // Add to local list if not already present
        if (!_orders.any((o) => o.id == order.id)) {
          _orders.add(order);
        }
        return order;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to load order: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
