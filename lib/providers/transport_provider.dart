import 'package:flutter/foundation.dart';
import 'package:facesoft/API_services/transport_api.dart';
import 'package:facesoft/model/transport_model.dart';

class TransportProvider with ChangeNotifier {
  List<Transport> _transports = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Transport> get transports => _transports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all transports
  Future<void> fetchTransports({int? userId}) async {

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final transports = await TransportApiService.fetchTransports();
      if (transports != null) {
        if (userId != null) {
          _transports = transports.where((t) => t.userId == userId).toList();
        } else {
          _transports = transports;
        }
      } else {
        _error = 'Failed to load transports';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a transport
  Future<bool> deleteTransport(int transportId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await TransportApiService.deleteTransport(transportId);
      if (success) {
        await fetchTransports();
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete transport';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Create a new transport
  Future<bool> createTransport(Transport transport) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final createdTransport = await TransportApiService.createTransport(transport);
      if (createdTransport != null) {
        await fetchTransports(); // Refresh the list after creation
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create transport';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Update a transport
  Future<bool> updateTransport(int id, Map<String, dynamic> updateData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedTransport = await TransportApiService.updateTransport(id, updateData);
      if (updatedTransport != null) {
        final userId = updateData['user_id'];
        await fetchTransports(userId: userId); // Refresh the list after update
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update transport';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }
}
