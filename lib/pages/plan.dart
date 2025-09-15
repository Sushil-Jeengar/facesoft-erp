import 'package:facesoft/pages/purchase_history.dart';
import 'package:flutter/material.dart';
import 'package:facesoft/pages/payment.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/API_services/plan_api.dart';
import 'package:facesoft/widget/skeletons.dart';

class PlanPage extends StatelessWidget {
  PlanPage({super.key});
  final List<Map<String, dynamic>> plans = [
    {
      'title': 'Starter Plan',
      'validity': '30 days',
      'price': '₹199',
      'features': 'Basic invoicing, 5GB storage',
      'status': 'Active',
      'trial': '7 days',
    },
    {
      'title': 'Pro Plan',
      'validity': '90 days',
      'price': '₹499',
      'features': 'All features, 50GB storage',
      'status': 'Active',
      'trial': '14 days',
    },
    {
      'title': 'Enterprise Plan',
      'validity': '180 days',
      'price': '₹999',
      'features': 'Unlimited storage, all features',
      'status': 'Inactive',
      'trial': '30 days',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('Plans')),
      body: FutureBuilder<List<dynamic>>(
        future: PlanApiService.fetchPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList(padding: EdgeInsets.fromLTRB(12, 12, 12, 80));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load plans:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final fetched = snapshot.data ?? [];
          final items = fetched.isEmpty ? plans : fetched;

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80), // Added bottom padding of 80 to accommodate the FAB
            children: [
              // Enhanced Banner Widget
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      // ignore: deprecated_member_use
                      AppColors.primary.withOpacity(0.9),
                      // ignore: deprecated_member_use
                      AppColors.primary.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/banner.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.yellow, size: 24),
                        SizedBox(width: 2),
                        Text(
                          'Upgrade Your Experience',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black45,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unlock premium features with our tailored plans for your business.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to a specific plan or scroll to plans
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Explore our plans below!')),
                        );
                      },
                      style: AppButtonStyles.primaryButton.copyWith(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      child: const Text(
                        'Explore Plans',
                        style: AppTextStyles.primaryButton,
                      ),
                    ),
                  ],
                ),
              ),

              // Plan Cards (from API or fallback)
              ...items.map<Widget>((raw) {
                final plan = _normalizePlan(raw);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 1,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['title'],
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _infoRow(Icons.attach_money, "Offer Price: ${plan['price']}") ,
                          _infoRow(Icons.calendar_today, "Validity: ${plan['validity']}",
                          ),
                          Row(
                            children: [
                              Icon(
                                plan['statusBool'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 14,
                                color: plan['statusBool'] == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Status: ${plan['status']}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: plan['statusBool'] == true
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Features:",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            plan['features'].toString().isNotEmpty ? plan['features'] : 'No features',
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (plan['statusBool'] != true)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Free Trial Activated"),
                                        ),
                                      );
                                    },
                                    style: AppButtonStyles.secondaryButton,
                                    child: const Text(
                                      "Free Trial",
                                      style: AppTextStyles.secondryButton,
                                    ),
                                  ),
                                ),
                              if (plan['statusBool'] != true) const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PaymentPage(),
                                      ),
                                    );
                                  },
                                  style: AppButtonStyles.primaryButton,
                                  child: const Text(
                                    "Purchase",
                                    style: AppTextStyles.primaryButton,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: AppColors.primary,
      //   icon: const Icon(Icons.add, color: Colors.white),
      //   label: const Text("Add Plan", style: AppTextStyles.primaryButton),
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const AddPlanPage()),
      //     );
      //   },
      // ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        label: const Text("See Your Plans", style: AppTextStyles.primaryButton),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PurchaseHistory()),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  // Normalize API plan object to UI-friendly map keys similar to SpecialPlanSection
  Map<String, dynamic> _normalizePlan(dynamic raw) {
    if (raw is Map) {
      final m = raw as Map;

      // Title
      final name = (m['title'] ?? m['name'] ?? m['planName'] ?? 'Plan').toString();

      // Offer price
      String price = 'N/A';
      if (m['offer_price'] != null) {
        price = m['offer_price'].toString();
      } else if (m['price'] != null) {
        price = m['price'].toString();
      } else if (m['amount'] != null) {
        price = m['amount'].toString();
      }

      // Validity: duration + interval
      String validity = '—';
      if (m['duration'] != null && m['interval'] != null) {
        validity = '${m['duration']} ${m['interval']}';
      } else if (m['validity'] != null) {
        validity = m['validity'].toString();
      } else if (m['validityDays'] != null) {
        validity = '${m['validityDays']} days';
      }

      // Status as bool and string
      final bool statusBool = m['status'] is bool
          ? (m['status'] as bool)
          : (m['isActive'] == true || m['status']?.toString().toLowerCase() == 'active');
      final statusStr = statusBool ? 'Active' : 'Inactive';

      // Features from tags or features list/string
      final features = m['tags'] is List
          ? (m['tags'] as List).join(', ')
          : (m['features'] is List
              ? (m['features'] as List).join(', ')
              : (m['features']?.toString() ?? ''));

      return {
        'name': name,
        'price': price,
        'validity': validity,
        'features': features,
        'status': statusStr,
        'statusBool': statusBool,
      };
    }

    return {
      'name': 'Plan',
      'price': 'N/A',
      'validity': '—',
      'features': '',
      'status': 'Inactive',
      'statusBool': false,
    };
  }
}
