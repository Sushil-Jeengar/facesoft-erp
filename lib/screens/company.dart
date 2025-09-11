import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facesoft/providers/company_provider.dart';
import 'package:facesoft/form/company.dart';
import 'package:facesoft/style/app_style.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  @override
  void initState() {
    super.initState();
    // Fetch companies when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CompanyProvider>(context, listen: false);
      provider.fetchCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<CompanyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final companies = provider.companies;
          if (companies.isEmpty) {
            return const Center(child: Text('No companies found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 1,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: company.image != null
                                        ? Image.network(
                                            company.image!,
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
                                  Expanded(
                                    child: Text(
                                      company.name!,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.email, "${company.email}"),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                  Icons.phone,
                                  "${company.phoneCode ?? '+91'} ${_last10(company.phone)}"),
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.location_on, "${company.city}, ${company.state}, ${company.country}"),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary, size: 28),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCompanyPage(company: company),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[300], size: 28),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text("Are you sure you want to delete this company?"),
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
                                            final provider = Provider.of<CompanyProvider>(context, listen: false);
                                            final success = await provider.deleteCompany(company.id.toString());
                                            if (success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Company deleted successfully')),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to delete company: ${provider.error}')),
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Company", style: AppTextStyles.primaryButton),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCompanyPage()),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
  
  String _last10(String? value) {
    if (value == null) return '';
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 10) return digits;
    return digits.substring(digits.length - 10);
  }
}
