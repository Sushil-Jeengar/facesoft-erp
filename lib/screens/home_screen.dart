import 'package:flutter/material.dart';
import 'package:facesoft/screens/add_order.dart';
import 'package:facesoft/screens/home.dart';
import 'package:facesoft/screens/company.dart';
import 'package:facesoft/screens/order.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/widget/app_bar.dart';
import 'package:facesoft/widget/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        onSeeAllPressed: () {
          setState(() {
            currentIndex = 3; // Navigate to CompanyPage (index 3)
          });
        },
      ),
      OrderPage(
        onTabSelected: (index) {
          setState(() => currentIndex = index);
        },
      ),
      const AddOrderPage(),
      CompanyPage(),
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

          onTap: (index) => setState(() => currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.home_outlined, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.shopping_cart_outlined, 1),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.add_shopping_cart, 2),
              label: 'Add Orders',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.business_outlined, 3),
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
}
