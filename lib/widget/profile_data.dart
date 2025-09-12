import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facesoft/providers/company_provider.dart';
import 'package:facesoft/providers/order_provider.dart';
import 'package:facesoft/providers/auth_provider.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<CompanyProvider, OrderProvider, AuthProvider>(
      builder: (context, companyProvider, orderProvider, authProvider, _) {
        // Fetch orders if not already loaded
        if (orderProvider.orders.isEmpty && !orderProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final userId = authProvider.authData?.user.id;
            orderProvider.fetchOrders(userId: userId);
          });
        }

        // Get company and orders count from providers
        final companyCount = companyProvider.companies.length;
        final ordersCount = orderProvider.orders.length;

        return _buildDashboardCards(companyCount, ordersCount);
      },
    );
  }

  Widget _buildDashboardCards(int companyCount, int ordersCount) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Orders Card
          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
                child: _buildItem(
                  icon: Icons.shopping_bag_outlined,
                  label: "Orders",
                  count: ordersCount,
                  iconColor: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Companies Card
          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
                child: _buildItem(
                  icon: Icons.business_outlined,
                  label: "Companies",
                  count: companyCount,
                  iconColor: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required int count,
    required Color iconColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          // ignore: deprecated_member_use
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          '$count',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}
