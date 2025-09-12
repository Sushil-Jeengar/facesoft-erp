import 'package:flutter/material.dart';
import 'package:facesoft/pages/payment.dart';
import 'package:facesoft/pages/plan.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/API_services/plan_api.dart';

class SpecialPlanSection extends StatefulWidget {
  const SpecialPlanSection({super.key});

  @override
  State<SpecialPlanSection> createState() => _SpecialPlanSectionState();
}

class _SpecialPlanSectionState extends State<SpecialPlanSection> {
  List<dynamic> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    try {
      final fetchedPlans = await PlanApiService.fetchPlans();
      setState(() {
        plans = fetchedPlans;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (plans.isEmpty) {
      return const Center(child: Text("No plans available"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Special Plans",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlanPage()),
                  );
                },
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

        // Horizontal Scroll
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: plans.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final plan = plans[index];

              return Container(
                width: 250,
                margin: EdgeInsets.only(right: index == plans.length - 1 ? 0 : 12),
                child: Card(
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          plan['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Offer Price
                        Text(
                          "Offer Price: ${plan['offer_price'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 13),
                        ),

                        // Duration
                        Text(
                          "Validity: ${plan['duration']} ${plan['interval']}",
                          style: const TextStyle(fontSize: 13),
                        ),

                        // Status
                        Text(
                          "Status: ${plan['status'] == true ? 'Active' : 'Inactive'}",
                          style: TextStyle(
                            fontSize: 13,
                            color: plan['status'] == true ? Colors.green : Colors.red,
                          ),
                        ),

                        const SizedBox(height: 4),
                        const Text(
                          "Features:",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Tags as features
                        Text(
                          (plan['tags'] as List).isNotEmpty
                              ? (plan['tags'] as List).join(", ")
                              : "No features",
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Buttons Row
                        Row(
                          children: [
                            // Purchase Button
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Add spacing between buttons if both are visible
                            if (plan['status'] != true) const SizedBox(width: 8),
                            
                            // Trial Button (only if not active)
                            if (plan['status'] != true)
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
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
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
            },
          ),
        ),
      ],
    );
  }
}
