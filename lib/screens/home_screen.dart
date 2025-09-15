import 'package:flutter/material.dart';
import 'package:facesoft/screens/add_order.dart';
import 'package:facesoft/screens/home.dart';
import 'package:facesoft/screens/company.dart';
import 'package:facesoft/screens/order.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/widget/app_bar.dart';
import 'package:facesoft/widget/drawer.dart';
import 'package:facesoft/model/order_model.dart';
import 'package:facesoft/pages/supplier.dart';
import 'package:facesoft/pages/party.dart';
import 'package:facesoft/pages/quality.dart';
import 'package:facesoft/pages/transport.dart';
import 'package:facesoft/pages/item.dart';
import 'package:facesoft/pages/agent.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Order? _editingOrder;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        onSeeAllPressed: () {
          setState(() {
            currentIndex = 4; // Updated index for CompanyPage
          });
        },
      ),
      OrderPage(
        onTabSelected: (index) {
          setState(() => currentIndex = index);
        },
        onEditOrder: (order) {
          setState(() {
            _editingOrder = order;
            currentIndex = 3; // Updated index for AddOrderPage
          });
        },
      ),
      const Center(child: Text('Menu')), // Placeholder for menu
      AddOrderPage(editingOrder: _editingOrder),
      const CompanyPage(),
    ];

    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      drawer: const CustomDrawer(),
      body: pages[currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.white),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 2) {
              _showMenuOptions(context);
            } else {
              setState(() => currentIndex = index);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.home_outlined, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.shopping_cart_outlined, 1),
              label: 'Order',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu, size: 28),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.add_shopping_cart, 3),
              label: 'Add Orders',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.business_outlined, 4),
              label: 'Company',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData iconData, int index) {
    bool isSelected = currentIndex == index;
    return isSelected
        ? Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Icon(iconData, color: Colors.white, size: 24),
        )
        : Icon(iconData, color: Colors.grey);
  }

  void _showMenuOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Menu Options',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildMenuOption(
                context,
                'Suppliers',
                Icons.people_outline,
                () => _navigateToPage(context, const SupplierPage()),
              ),
              _buildMenuOption(
                context,
                'Parties',
                Icons.group_outlined,
                () => _navigateToPage(context, const PartyPage()),
              ),
              _buildMenuOption(
                context,
                'Qualities',
                Icons.star_border,
                () => _navigateToPage(context, const QualityPage()),
              ),
              _buildMenuOption(
                context,
                'Transports',
                Icons.local_shipping_outlined,
                () => _navigateToPage(context, const TransportPage()),
              ),
              _buildMenuOption(
                context,
                'Items',
                Icons.inventory_2_outlined,
                () => _navigateToPage(context, const ItemsPage()),
              ),
              _buildMenuOption(
                context,
                'Agents',
                Icons.person_outline,
                () => _navigateToPage(context, const AgentPage()),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context); // Close the bottom sheet
        onTap();
      },
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
