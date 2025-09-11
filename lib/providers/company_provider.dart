import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:facesoft/API_services/company_api.dart';
import 'package:facesoft/model/company_model.dart';

class CompanyProvider with ChangeNotifier {
  List<Company> _companies = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all companies; optionally filter by userId
  Future<void> fetchCompanies({int? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final companies = await CompanyApiService.fetchCompanies();
      if (companies != null) {
        if (userId != null) {
          _companies = companies.where((c) => c.userId == userId).toList();
        } else {
          _companies = companies;
        }
      } else {
        _error = 'Failed to load companies';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new company
  Future<bool> addCompany(Company company, int userId, {File? imageFile}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final createdCompany = await CompanyApiService.createCompany(company, userId, imageFile: imageFile);
      if (createdCompany != null) {
        _companies.add(createdCompany); // Add the company with server-generated fields
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to add company';
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

  // Delete a company
  Future<bool> deleteCompany(String companyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await CompanyApiService.deleteCompany(companyId);
      if (success) {
        _companies.removeWhere((c) => c.id.toString() == companyId);
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete company';
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

// Update an existing company
  Future<bool> updateCompany(Company updatedCompany, {File? imageFile}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await CompanyApiService.updateCompany(updatedCompany, imageFile: imageFile);
      if (success) {
        // Ensure we have the latest data (e.g., updated image URL) from server
        await fetchCompanies();
        return true;
      } else {
        _error = 'Failed to update company';
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
