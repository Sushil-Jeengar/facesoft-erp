import 'package:flutter/material.dart';
import 'package:facesoft/model/agent_model.dart';
import 'package:facesoft/API_services/agent_api.dart';

class AgentProvider with ChangeNotifier {
  List<Agent> _agents = [];
  bool _isLoading = true;

  List<Agent> get agents => _agents;
  bool get isLoading => _isLoading;

  Future<void> fetchAgents({int? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedAgents = await AgentApiService.fetchAgents();
      if (fetchedAgents != null) {
        if (userId != null) {
          _agents = fetchedAgents.where((a) => a.userId == userId).toList();
        } else {
          _agents = fetchedAgents;
        }
      }
    } catch (e) {
      // Handle error (e.g., show a snackbar in the UI)
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> deleteAgent(int id) async {
    try {
      final success = await AgentApiService.deleteAgent(id);
      if (success) {
        _agents.removeWhere((agent) => agent.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      rethrow;
    }
  }


  Future<bool> createAgent(Agent agent) async {
    _isLoading = true;
    notifyListeners();
    try {
      final createdAgent = await AgentApiService.createAgent(agent);
      if (createdAgent != null) {
        _agents.add(createdAgent); // Add the updated agent from backend
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



  Future<bool> updateAgent(int id, Map<String, dynamic> updateData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedAgent = await AgentApiService.updateAgent(id, updateData);
      if (updatedAgent != null) {
        final index = _agents.indexWhere((a) => a.id == id);
        if (index != -1) {
          _agents[index] = updatedAgent;
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
