import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      // elevation: 1,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Drawer
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.black, size: 35),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),

          // Center: App Logo
          Image.asset('assets/images/FaceLogoE.png', height: 60, width: 100),

          // Right: Notifications
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // // Go to Notification Page
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (_) => const NotificationPage()));
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
