import 'package:facesoft/model/company_model.dart';
import 'package:facesoft/providers/company_provider.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/providers/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CompanyOverviewCard extends StatefulWidget {
  final VoidCallback? onSeeAllPressed;
  const CompanyOverviewCard({super.key, this.onSeeAllPressed});

  @override
  State<CompanyOverviewCard> createState() => _CompanyOverviewCardState();
}

class _CompanyOverviewCardState extends State<CompanyOverviewCard> {
  final PageController _pageController = PageController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Fetch companies when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CompanyProvider>(context, listen: false);
      int? userId;
      try {
        userId = Provider.of<AuthProvider>(context, listen: false).authData?.user.id;
      } catch (_) {}
      provider.fetchCompanies(userId: userId).then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = e.toString();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProvider>(
      builder: (context, provider, _) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_error != null) {
          return Center(child: Text(_error!));
        }
        final companies = provider.companies;
        if (companies.isEmpty) {
          return const Center(child: Text('No companies found'));
        }
        return Column(
          children: [
            // Heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Company",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: widget.onSeeAllPressed,
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Company List
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCompanyCard(companies[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Extracted card content to reuse for each company
  Widget _buildDefaultLogo() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.business, size: 30, color: Colors.grey),
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo and name
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: company.image != null && company.image!.isNotEmpty
                      ? Image.network(
                    company.image!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
                  )
                      : _buildDefaultLogo(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (company.ownerName != null && company.ownerName!.isNotEmpty)
                        Text(
                          'Owner: ${company.ownerName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Info rows
            _infoRow(Icons.email, "Email", company.email),
            _infoRow(Icons.phone, "Mobile", "${company.phoneCode} ${company.phone}"),
            _infoRow(
              Icons.location_on,
              "Location",
              "${company.city ?? ''}, ${company.state ?? ''}, ${company.country ?? ''}",
            ),
          ],
        ),
      ),
    );
  }



  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text("$label: "),
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
