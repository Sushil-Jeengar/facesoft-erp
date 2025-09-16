import 'package:facesoft/model/parties_model.dart';
import 'package:flutter/material.dart';
import 'package:facesoft/form/party.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/screens/home_screen.dart';
import 'package:facesoft/providers/party_provider.dart';
import 'package:provider/provider.dart';
import 'package:facesoft/providers/auth_provider.dart';
import 'package:facesoft/widget/skeletons.dart';

class PartyPage extends StatefulWidget {
  const PartyPage({super.key});

  @override
  State<PartyPage> createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.authData?.user.id;
      Provider.of<PartyProvider>(context, listen: false).fetchParties(userId: userId);
    });
  }

  String _getFullAddress(Party party) {
    List<String> addressParts = [];
    if (party.city != null && party.city!.isNotEmpty) {
      addressParts.add(party.city!);
    }
    if (party.state != null && party.state!.isNotEmpty) {
      addressParts.add(party.state!);
    }
    if (party.country != null && party.country!.isNotEmpty) {
      addressParts.add(party.country!);
    }
    return addressParts.join(', ');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Party'),
        ),
        body: Consumer<PartyProvider>(
          builder: (context, partyProvider, child) {
            if (partyProvider.isLoading) {
              return const SkeletonList();
            }
            if (partyProvider.error != null) {
              return Center(
                child: Text(
                  partyProvider.error!,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }
            if (partyProvider.parties.isEmpty) {
              return const Center(
                child: Text(
                  'No parties found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding of 80 to accommodate the FAB
              itemCount: partyProvider.parties.length,
              itemBuilder: (context, index) {
                      final party = partyProvider.parties[index];
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      party.contactPerson!,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (party.email != null && party.email!.isNotEmpty)
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
                                              party.email!,
                                              style: const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (party.email != null && party.email!.isNotEmpty)
                                      const SizedBox(height: 4),
                                    if (party.phone != null && party.phone!.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            party.phone!,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    if (party.phone != null && party.phone!.isNotEmpty)
                                      const SizedBox(height: 4),
                                    if (_getFullAddress(party).isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              _getFullAddress(party),
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>AddPartyPage(party: party)));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      // Show confirmation dialog
                                      bool shouldDelete = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            title: const Text("Confirm Delete"),
                                            content: const Text("Are you sure you want to delete this party? This action cannot be undone."),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  "Delete",
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      // If user confirms deletion
                                      if (shouldDelete == true) {
                                        final partyProvider = Provider.of<PartyProvider>(context, listen: false);
                                        final success = await partyProvider.deleteParty(party.id!);
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Party deleted successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(partyProvider.error ?? 'Failed to delete party.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Party", style: AppTextStyles.primaryButton),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPartyPage()),
            );
          },
        ),
      ),
    );
  }
}
