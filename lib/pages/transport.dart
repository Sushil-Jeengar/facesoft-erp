// transport_page.dart
import 'package:flutter/material.dart';
import 'package:facesoft/form/transport.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/model/transport_model.dart';
import 'package:facesoft/providers/transport_provider.dart';
import 'package:provider/provider.dart';
import 'package:facesoft/providers/auth_provider.dart';
import 'package:facesoft/widget/skeletons.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({super.key});

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Transport> filteredTransports = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTransports);
    
    // Use addPostFrameCallback to ensure this runs after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transportProvider = Provider.of<TransportProvider>(context, listen: false);
      if (transportProvider.transports.isEmpty) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final userId = auth.authData?.user.id;
        transportProvider.fetchTransports(userId: userId);
      } else {
        _filterTransports();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No need to fetch data here anymore
  }

  void _filterTransports() {
    final transportProvider = Provider.of<TransportProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredTransports = transportProvider.transports.where((transport) {
        final transportName = transport.transportName?.toLowerCase() ?? '';
        final email = transport.email?.toLowerCase() ?? '';
        final phone = transport.phone?.toLowerCase() ?? '';
        final address = _getFullAddress(transport).toLowerCase();

        return transportName.contains(query) ||
            email.contains(query) ||
            phone.contains(query) ||
            address.contains(query);
      }).toList();
    });
  }

  String _getFullAddress(Transport transport) {
    List<String> addressParts = [];
    if (transport.city != null && transport.city!.isNotEmpty) {
      addressParts.add(transport.city!);
    }
    if (transport.state != null && transport.state!.isNotEmpty) {
      addressParts.add(transport.state!);
    }
    if (transport.country != null && transport.country!.isNotEmpty) {
      addressParts.add(transport.country!);
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
    final transportProvider = Provider.of<TransportProvider>(context);
    
    // Update filtered transports when provider data changes
    if (filteredTransports.isEmpty || _searchController.text.isEmpty) {
      filteredTransports = List.from(transportProvider.transports);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Transport'),
      ),
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
          // Transport List
          Expanded(
            child: transportProvider.isLoading
                ? const SkeletonList()
                : filteredTransports.isEmpty
                ? const Center(
              child: Text(
                'No transports found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all (16),
              itemCount: filteredTransports.length,
              itemBuilder: (context, index) {
                final transport = filteredTransports[index];
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
                                transport.transportName ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (transport.transportType != null && transport.transportType!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_shipping,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      transport.transportType!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              if (transport.transportType != null && transport.transportType!.isNotEmpty)
                                const SizedBox(height: 4),
                              // if (transport.partyType != null && transport.partyType!.isNotEmpty)
                              //   Row(
                              //     children: [
                              //       const Icon(
                              //         Icons.category,
                              //         color: AppColors.primary,
                              //         size: 20,
                              //       ),
                              //       const SizedBox(width: 6),
                              //       Text(
                              //         transport.partyType!,
                              //         style: const TextStyle(fontSize: 16),
                              //       ),
                              //     ],
                              //   ),
                                const SizedBox(height: 4),
                              if (transport.contactPerson != null && transport.contactPerson!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      transport.contactPerson!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              if (transport.contactPerson != null && transport.contactPerson!.isNotEmpty)
                                const SizedBox(height: 4),
                              if (transport.phone != null && transport.phone!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      transport.phone!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              if (transport.phone != null && transport.phone!.isNotEmpty)
                                const SizedBox(height: 4),
                              if (transport.email != null && transport.email!.isNotEmpty)
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
                                        transport.email!,
                                        style: const TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              if (transport.email != null && transport.email!.isNotEmpty)
                                const SizedBox(height: 4),
                              if (_getFullAddress(transport).isNotEmpty && _getFullAddress(transport) != 'No address')
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4.0),
                                      child: Icon(
                                        Icons.location_on,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _getFullAddress(transport),
                                        style: const TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
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
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTransportPage(transport: transport,)));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[300]),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Text('Confirm Delete'),
                                      content: const Text('Are you sure you want to delete this transport?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            bool success = await Provider.of<TransportProvider>(context, listen: false)
                                                .deleteTransport(transport.id!);
                                            if (success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Transport deleted successfully')),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Failed to delete transport')),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Transport", style: AppTextStyles.primaryButton),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransportPage()),
          );
        },
      ),
    );
  }
}
