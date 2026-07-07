import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'status_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [HomeScreen(), WishlistScreen(), StatusScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFFF5EDD8),
        selectedItemColor: const Color(0xFFFF9500),
        unselectedItemColor: const Color(0xFF8B5E3C),
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '时光'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: '心愿'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'TA'),
        ],
      ),
    );
  }
}
