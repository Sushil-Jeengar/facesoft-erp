import 'package:flutter/foundation.dart';
import 'package:facesoft/API_services/order_api.dart';
import 'package:facesoft/model/order_model.dart';

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
}
