import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/auth_controller.dart';
import 'chat_list_screen.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  final AuthController authController = Get.find<AuthController>();

  final List<Widget> _screens = [
    const HomeScreen(),
    ChatListScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  final List<Color> _tabColors = [
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.tealAccent,
  ];

  final List<String> _lottieUrls = [
    "https://raw.githubusercontent.com/NotCapable1o/lottie/main/BottomNavigation/home.json",
    "https://raw.githubusercontent.com/NotCapable1o/lottie/main/BottomNavigation/Chat.json",
    "https://raw.githubusercontent.com/NotCapable1o/lottie/main/BottomNavigation/Cart.json",
    "https://raw.githubusercontent.com/NotCapable1o/lottie/main/BottomNavigation/profile.json",
  ];

  final String sellDonateLottie =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/buy_sell.json";

  double _getIconSize(int index) {
    switch (index) {
      case 0:
        return 25.0;
      case 1:
        return 30.0;
      case 2:
        return 30.0;
      case 3:
        return 30.0;
      default:
        return 25.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = _tabColors[_selectedIndex];

    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],

      floatingActionButton: _selectedIndex == 0
          ? GestureDetector(
              onTap: () {
                if (authController.isLoggedIn.value) {
                  Get.to(() => AddProductScreen());
                } else {
                  Get.to(() => const LoginScreen());
                }
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF2C2C2C)
                      : Colors.grey.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.0),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Lottie.network(
                  sellDonateLottie,
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: activeColor.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: GNav(
              rippleColor: activeColor.withOpacity(0.2),
              hoverColor: activeColor.withOpacity(0.1),
              haptic: true,
              gap: 6,
              activeColor: activeColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: activeColor.withOpacity(0.1),
              color: isDark ? Colors.white60 : Colors.black45,
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: activeColor,
              ),
              tabs: List.generate(4, (index) {
                return GButton(
                  icon: Icons.circle,
                  leading: SizedBox(
                    width: _getIconSize(index),
                    height: _getIconSize(index),
                    child: Opacity(
                      opacity: _selectedIndex == index ? 1.0 : 0.7,
                      child: Lottie.network(
                        _lottieUrls[index],
                        fit: BoxFit.contain,
                        animate: _selectedIndex == index,
                        repeat: true,
                      ),
                    ),
                  ),
                  text: _getLabel(index),
                );
              }),
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Chat";
      case 2:
        return "Cart";
      case 3:
        return "Profile";
      default:
        return "";
    }
  }
}
