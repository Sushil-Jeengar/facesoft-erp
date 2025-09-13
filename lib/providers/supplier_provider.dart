import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:facesoft/model/supplier_model.dart';
import 'package:facesoft/API_services/supplier_api.dart';

class SupplierProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSuppliers({int? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fetchedSuppliers = await SupplierApiService.fetchSuppliers();
      if (fetchedSuppliers != null) {
        if (userId != null) {
          _suppliers = fetchedSuppliers.where((s) => s.userId == userId).toList();
        } else {
          _suppliers = fetchedSuppliers;
        }
      } else {
        _errorMessage = "Failed to load suppliers";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteSupplier(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await SupplierApiService.deleteSupplier(id);
      if (success) {
        _suppliers.removeWhere((s) => s.id == id);
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to delete supplier";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<Map<String, dynamic>> addSupplier(Map<String, dynamic> supplierData, {File? imageFile}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await SupplierApiService.createSupplier(supplierData, imageFile: imageFile);
      if (result['success']) {
        await fetchSuppliers();
        return {'success': true};
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return {'success': false, 'message': _errorMessage};
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    } finally {
      _isLoading = false;
    }
  }

  Future<Map<String, dynamic>> updateSupplier(int id, Map<String, dynamic> updateData, {File? imageFile}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await SupplierApiService.updateSupplier(id, updateData, imageFile: imageFile);
      if (result['success']) {
        final userId = updateData['user_id'];
        await fetchSuppliers(userId: userId);
        return {'success': true, 'message': 'Supplier updated successfully'};
      } else {
        _errorMessage = "Failed to update supplier";
        notifyListeners();
        return {'success': false, 'message': _errorMessage};
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    } finally {
      _isLoading = false;
    }
  }
}
