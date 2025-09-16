  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:facesoft/form/quality.dart';
  import 'package:facesoft/style/app_style.dart';
  import 'package:facesoft/model/quality_model.dart';
  import 'package:facesoft/providers/quality_provider.dart';
  import 'package:facesoft/providers/auth_provider.dart';
  import 'package:facesoft/widget/skeletons.dart';
  
  class QualityPage extends StatefulWidget {

    const QualityPage({super.key});
  
    @override
    State<QualityPage> createState() => _QualityPageState();
  }
  
  class _QualityPageState extends State<QualityPage> {
    final TextEditingController _searchController = TextEditingController();
    List<Quality> filteredQualities = [];
  
    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final userId = auth.authData?.user.id;
        Provider.of<QualityProvider>(context, listen: false).fetchQualities(userId: userId);
      });
      _searchController.addListener(_filterQualities);
    }
  
    void _filterQualities() {
      final query = _searchController.text.toLowerCase();
      final provider = Provider.of<QualityProvider>(context, listen: false);
      setState(() {
        filteredQualities =
            provider.qualities.where((q) {
              return (q.qualityName?.toLowerCase() ?? '').contains(query) ||
                  (q.qualityCode?.toLowerCase() ?? '').contains(query) ||
                  (q.color?.toLowerCase() ?? '').contains(query);
            }).toList();
      });
    }
    
    Future<void> _showDeleteDialog(BuildContext context, int id) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this quality?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    final success = await Provider.of<QualityProvider>(
                      context,
                      listen: false,
                    ).deleteQuality(id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Quality deleted successfully'
                                : 'Failed to delete quality',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }
  
    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }
  
    @override
    Widget build(BuildContext context) {
      final provider = Provider.of<QualityProvider>(context);
      filteredQualities =
          provider.qualities.where((q) {
            final query = _searchController.text.toLowerCase();
            return (q.qualityName?.toLowerCase() ?? '').contains(query) ||
                (q.qualityCode?.toLowerCase() ?? '').contains(query) ||
                (q.color?.toLowerCase() ?? '').contains(query);
          }).toList();
  
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Quality'),
        ),
        body: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: TextField(
            //     controller: _searchController,
            //     decoration: InputDecoration(
            //       hintText: 'Search by name, code, or color',
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
            Expanded(
              child:
                  provider.isLoading
                      ? const SkeletonList()
                      : filteredQualities.isEmpty
                      ? const Center(
                        child: Text(
                          'No qualities found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredQualities.length,
                        itemBuilder: (context, index) {
                          final quality = filteredQualities[index];
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
                                          quality.qualityName ?? 'No Name',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Code: ${quality.qualityCode}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        if (quality.details != null &&
                                            quality.details!.isNotEmpty)
                                          Text(
                                            quality.details!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => AddQualityPage(
                                                    quality: quality,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
  
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red[300],
                                        ),
                                        onPressed:
                                            () => _showDeleteDialog(
                                              context,
                                              quality.id!,
                                            ),
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
          label: const Text("Add Quality", style: AppTextStyles.primaryButton),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddQualityPage()),
            );
          },
        ),
      );
    }
  }
