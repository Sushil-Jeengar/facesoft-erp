import 'package:flutter/material.dart';
import 'package:facesoft/style/app_style.dart';

class PurchaseHistory extends StatelessWidget {
  PurchaseHistory({super.key});

  // Mock: Assume this data comes from backend
  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Pro Plan',
      'company': 'Invoice IQ Pvt Ltd',
      'validity': '90 days',
      'price': '₹499',
      'features': 'All features, 50GB storage',
      'status': 'Active',
      'trial': '14 days',
      'startDate': '01 Jul 2025',
      'endDate': '30 Sep 2025',
    },
    {
      'name': 'Basic Plan',
      'company': 'Starter Ltd',
      'validity': '30 days',
      'price': '₹199',
      'features': 'Limited features, 10GB storage',
      'status': 'Expired',
      'trial': '7 days',
      'startDate': '01 Jun 2025',
      'endDate': '30 Jun 2025',
    },
    // Add more plans if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Purchase History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoRow(Icons.business, "Company: ${plan['company']}"),
                    _infoRow(
                      Icons.date_range,
                      "Start Date: ${plan['startDate']}",
                    ),
                    _infoRow(Icons.event, "End Date: ${plan['endDate']}"),
                    _infoRow(
                      Icons.calendar_today,
                      "Validity: ${plan['validity']}",
                    ),
                    _infoRow(Icons.attach_money, "Price: ${plan['price']}"),
                    _infoRow(Icons.timer, "Trial: ${plan['trial']}"),
                    _infoRow(
                      plan['status'] == 'Active'
                          ? Icons.check_circle
                          : Icons.cancel,
                      "Status: ${plan['status']}",
                      color:
                          plan['status'] == 'Active'
                              ? Colors.green
                              : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text, {
    Color color = AppColors.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
