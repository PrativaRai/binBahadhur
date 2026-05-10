import 'package:flutter/material.dart';

// 1. DATA MODEL
// This allows you to define what each tab looks like outside of the UI code.
class NavItem {
  final String label;
  final IconData icon;

  NavItem({required this.label, required this.icon});
}

// 2. DYNAMIC NAVBAR WIDGET
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items; // This makes it dynamic

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xFF00872D),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.green,
      // We map the list of NavItem objects into BottomNavigationBarItems
      items: items.map((NavItem item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}
