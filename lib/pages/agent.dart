import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facesoft/providers/agent_provider.dart';
import 'package:facesoft/model/agent_model.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/form/agent.dart';
import 'package:facesoft/providers/auth_provider.dart';

class AgentPage extends StatefulWidget {
  const AgentPage({super.key});

  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Agent> filteredAgents = [];

  @override
  void initState() {
    super.initState();
    // Fetch agents when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).authData?.user.id;
      Provider.of<AgentProvider>(context, listen: false).fetchAgents(userId: userId);
    });
    _searchController.addListener(_filterAgents);
  }

  void _filterAgents() {
    final query = _searchController.text.toLowerCase();
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);
    setState(() {
      filteredAgents =
          agentProvider.agents.where((agent) {
            final agentName = agent.agentName?.toLowerCase() ?? '';
            final email = agent.email?.toLowerCase() ?? '';
            final phone = agent.phone?.toLowerCase() ?? '';
            final address = _getFullAddress(agent).toLowerCase();

            return agentName.contains(query) ||
                email.contains(query) ||
                phone.contains(query) ||
                address.contains(query);
          }).toList();
    });
  }

  String _getFullAddress(Agent agent) {
    List<String> addressParts = [];
    if (agent.city != null && agent.city!.isNotEmpty) {
      addressParts.add(agent.city!);
    }
    if (agent.state != null && agent.state!.isNotEmpty) {
      addressParts.add(agent.state!);
    }
    if (agent.country != null && agent.country!.isNotEmpty) {
      addressParts.add(agent.country!);
    }
    return addressParts.isNotEmpty ? addressParts.join(', ') : 'No address';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agentProvider = Provider.of<AgentProvider>(context);
    final agents = agentProvider.agents;
    filteredAgents = agents; // Reset filtered list on rebuild

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('Agent')),
      body: Column(
        children: [
          // Search Field
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextField(
          //     controller: _searchController,
          //     decoration: InputDecoration(
          //       hintText: 'Search by name, email, mobile, or location',
          //       prefixIcon: const Icon(Icons.search),
          //       filled: true,
          //       fillColor: Colors.white,
          //       contentPadding: const EdgeInsets.symmetric(
          //         vertical: 10,
          //         horizontal: 20,
          //       ),
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(12),
          //         borderSide: const BorderSide(color: Colors.grey),
          //       ),
          //     ),
          //   ),
          // ),
          // Agent List
          Expanded(
            child:
                agentProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredAgents.isEmpty
                    ? const Center(
                      child: Text(
                        'No agents found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredAgents.length,
                      itemBuilder: (context, index) {
                        final agent = filteredAgents[index];
                        return Card(
                          elevation: 1,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        agent.agentName ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (agent.email != null &&
                                          agent.email!.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.email,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                agent.email!,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (agent.email != null &&
                                          agent.email!.isNotEmpty)
                                        const SizedBox(height: 4),
                                      if (agent.phone != null &&
                                          agent.phone!.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              agent.phone!,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (agent.phone != null &&
                                          agent.phone!.isNotEmpty)
                                        const SizedBox(height: 4),
                                      if (_getFullAddress(agent).isNotEmpty)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Icon(
                                                Icons.location_on,
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                _getFullAddress(agent),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                // Edit/Delete Buttons
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AppColors.primary,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    AddAgentPage(agent: agent),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red[300],
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Delete Agent"),
                                              content: const Text(
                                                "Are you sure you want to delete this agent?",
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop(); // Close the dialog
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop(); // Close the dialog
                                                    bool success =
                                                        await Provider.of<AgentProvider>(
                                                          context,
                                                          listen: false,
                                                        ).deleteAgent(
                                                          agent.id!,
                                                        );
                                                    if (success) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Agent deleted successfully',
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Failed to delete agent',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      // Floating Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Agent", style: AppTextStyles.primaryButton),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAgentPage()),
          );
        },
      ),
    );
  }
}
