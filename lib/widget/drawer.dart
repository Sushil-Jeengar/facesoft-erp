import 'package:facesoft/providers/user_profile_provider.dart';
import 'package:facesoft/screens/complete_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:facesoft/providers/auth_provider.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/screens/login.dart';
import 'package:facesoft/screens/home_screen.dart';
import 'package:facesoft/pages/agent.dart';
import 'package:facesoft/pages/item.dart';
import 'package:facesoft/pages/purchase_history.dart';
import 'package:facesoft/pages/party.dart';
import 'package:facesoft/pages/plan.dart';
import 'package:facesoft/pages/quality.dart';
import 'package:facesoft/pages/supplier.dart';
import 'package:facesoft/pages/transport.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchUserData());
  }

  Future<void> _fetchUserData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      final userId = authProvider.authData?.user.id;
      if (userId != null) {
        await userProfileProvider.fetchUserProfile(userId);
      }
    } catch (e) {
      print("Error in CustomDrawer: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to fetch data"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Consumer<UserProfileProvider>(
                  builder: (context, userProfileProvider, child) {
                    final userProfile = userProfileProvider.userProfile;
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userProfile?.firstName ?? userProfile?.userName ?? "No Name",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userProfile?.email ?? "No Mail",
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
                          return CompleteProfile(initialProfile: userProfileProvider.userProfile);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Section: Navigation
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 12, bottom: 4),
                  child: Text(
                    "Navigation",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Plans'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlanPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.manage_history_outlined),
                  title: const Text('Purchase History'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseHistory(),
                      ),
                    );
                  },
                ),
                const Divider(thickness: 1, indent: 16, endIndent: 16),
                // Section: Master Data
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 12, bottom: 4),
                  child: Text(
                    "Master Data",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.manage_accounts_outlined),
                  title: const Text('Supplier'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SupplierPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group_outlined),
                  title: const Text('Party'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PartyPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star_border_outlined),
                  title: const Text('Quality'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QualityPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: const Text('Transport'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TransportPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.fastfood_outlined),
                  title: const Text('Item'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ItemsPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.support_agent_outlined),
                  title: const Text('Agents'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AgentPage()),
                    );
                  },
                ),
                const Divider(thickness: 1, indent: 16, endIndent: 16),
                // Section: Legal
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 12, bottom: 4),
                  child: Text(
                    "Legal",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('Privacy Policy'),
                ),
                const ListTile(
                  leading: Icon(Icons.rule_folder_outlined),
                  title: Text('Terms & Conditions'),
                ),
                const ListTile(
                  leading: Icon(Icons.rule_folder_outlined),
                  title: Text('Disclaimer'),
                ),
                const Divider(thickness: 1, indent: 16, endIndent: 16),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: () {
                Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).clearAuthData();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout", style: AppTextStyles.primaryButton),
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                        'Are you sure you want to delete your account? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  try {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
                    final userId = authProvider.authData?.user.id;

                    if (userId != null) {
                      final success = await userProfileProvider.deleteUser(userId);
                      
                      if (success) {
                        if (mounted) {
                          authProvider.clearAuthData();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(userProfileProvider.error ?? 'Failed to delete account'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('An error occurred while deleting your account'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text("Delete Account", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
