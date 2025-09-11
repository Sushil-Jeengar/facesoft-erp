import 'package:flutter/material.dart';
import 'package:facesoft/API_services/quality_api.dart';
import 'package:facesoft/model/quality_model.dart';

class QualityProvider with ChangeNotifier {
  List<Quality> _qualities = [];
  bool _isLoading = true;

  List<Quality> get qualities => _qualities;
  bool get isLoading => _isLoading;

  Future<void> fetchQualities() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fetchedQualities = await QualityApiService.fetchQualities();
      if (fetchedQualities != null) {
        _qualities = fetchedQualities;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> createQuality(Quality quality) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await QualityApiService.createQuality(quality);
      if (success) {
        await fetchQualities();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> deleteQuality(int id) async {
    try {
      final success = await QualityApiService.deleteQuality(id);
      if (success) {
        _qualities.removeWhere((quality) => quality.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      rethrow;
    }
  }


  Future<bool> updateQuality(int id, Map<String, dynamic> updateData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await QualityApiService.updateQuality(id, updateData);
      if (success) {
        // Fetch the updated list of qualities to ensure the UI is up-to-date
        final updatedQualities = await QualityApiService.fetchQualities();
        if (updatedQualities != null) {
          _qualities = updatedQualities;
        }
        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
