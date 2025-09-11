import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/form/supplier.dart';
import 'package:facesoft/model/supplier_model.dart';
import 'package:facesoft/providers/supplier_provider.dart';
import 'package:facesoft/providers/auth_provider.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Supplier> filteredSuppliers = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = context.read<AuthProvider>().authData?.user.id;
      context.read<SupplierProvider>().fetchSuppliers(userId: userId);
    });
    _searchController.addListener(_filterSuppliers);
  }

  void _filterSuppliers() {
    final provider = context.read<SupplierProvider>();
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSuppliers = provider.suppliers.where((supplier) {
        //final title = supplier.title?.toLowerCase() ?? '';
        final email = supplier.email?.toLowerCase() ?? '';
        final phone = supplier.phone?.toLowerCase() ?? '';
        final city = supplier.city?.toLowerCase() ?? '';
        final address = supplier.address?.toLowerCase() ?? '';

        return
          //title.contains(query) ||
            email.contains(query) ||
            phone.contains(query) ||
            city.contains(query) ||
            address.contains(query);
      }).toList();
    });
  }

  String _getFullAddress(Supplier supplier) {
    List<String> addressParts = [];
    if (supplier.city != null && supplier.city!.isNotEmpty) {
      addressParts.add(supplier.city!);
    }
    if (supplier.state != null && supplier.state!.isNotEmpty) {
      addressParts.add(supplier.state!);
    }
    if (supplier.country != null && supplier.country!.isNotEmpty) {
      addressParts.add(supplier.country!);
    }
    return addressParts.isNotEmpty ? addressParts.join(', ') : 'No Address';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Supplier'),
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, supplierProvider, _) {
          final suppliers = filteredSuppliers.isEmpty && _searchController.text.isEmpty
              ? supplierProvider.suppliers
              : filteredSuppliers;

          if (supplierProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (supplierProvider.errorMessage != null) {
            return Center(child: Text(supplierProvider.errorMessage!));
          }

          if (suppliers.isEmpty) {
            return const Center(
              child: Text('No suppliers found',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return Column(
            children: [
              // 🔍 Search Field
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

              // 📋 Supplier List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = suppliers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 1,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📄 Supplier Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: supplier.image != null
                                            ? Image.network(
                                          supplier.image!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.business,
                                            size: 30,
                                            color: AppColors.primary,
                                          ),
                                        )
                                            : Container(
                                          width: 50,
                                          height: 50,
                                          color: AppColors.primary,
                                          child: const Icon(
                                            Icons.business,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        supplier.contactPerson ?? 'No Title',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.email,
                                          color: AppColors.primary, size: 20),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          supplier.email ?? 'No Email',
                                          style: const TextStyle(fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          color: AppColors.primary, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        supplier.phone ?? 'No Phone',
                                        style:
                                        const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: AppColors.primary, size: 20),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _getFullAddress(supplier),
                                          style:
                                          const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // ✏️ Edit/Delete
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: AppColors.primary),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => AddSupplierPage(
                                              supplier: supplier,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red[300]),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm Delete"),
                                          content: const Text("Are you sure you want to delete this supplier?"),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                            ),
                                            TextButton(
                                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                              onPressed: () async {
                                                Navigator.of(context).pop(); // Close the dialog
                                                final provider = context.read<SupplierProvider>();
                                                final success = await provider.deleteSupplier(supplier.id!);
                                                if (success) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Supplier deleted successfully')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Failed to delete supplier')),
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
          );
        },
      ),

      // ➕ Floating Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Supplier",
            style: AppTextStyles.primaryButton),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSupplierPage()),
          );
        },
      ),
    );
  }
}
