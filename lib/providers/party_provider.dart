import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:facesoft/model/parties_model.dart';
import 'package:facesoft/API_services/parties_api.dart';

class PartyProvider with ChangeNotifier {
  List<Party> _parties = [];
  bool _isLoading = false;
  String? _error;

  List<Party> get parties => _parties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchParties({int? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await PartiesApiService.fetchParties();
      if (result != null) {
        if (userId != null) {
          _parties = result.where((p) => p.userId == userId).toList();
        } else {
          _parties = result;
        }
      } else {
        _error = "Failed to load parties";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteParty(int partyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await PartiesApiService.deleteParty(partyId);
      if (success) {
        _parties.removeWhere((party) => party.id == partyId);
        notifyListeners();
        return true;
      } else {
        _error = "Failed to delete party";
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

  //Create Party with Image Support
  Future<Map<String, dynamic>> createParty(Party party, {File? imageFile}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await PartiesApiService.createParty(party, imageFile: imageFile);
      if (result['success']) {
        await fetchParties(userId: party.userId); // Refresh the list
        return {'success': true, 'message': 'Party created successfully'};
      } else {
        _error = result['message'];
        notifyListeners();
        return {'success': false, 'message': _error};
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
    }
  }

  // Updated: Update Party with Image Support
  Future<Map<String, dynamic>> updateParty(Party party, {File? imageFile}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await PartiesApiService.updateParty(party, imageFile: imageFile);
      if (result['success']) {
        await fetchParties(userId: party.userId); // Refresh the list
        return {'success': true, 'message': 'Party updated successfully'};
      } else {
        _error = result['message'];
        notifyListeners();
        return {'success': false, 'message': _error};
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
    }
  }
}
