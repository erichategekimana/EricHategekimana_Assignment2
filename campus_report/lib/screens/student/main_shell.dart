import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../staff/staff_dashboard_screen.dart';
import 'home_screen.dart';
import 'my_reports_screen.dart';
import 'report_incident_screen.dart';
import 'reports_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _openReportForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportIncidentScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthProvider>().isStaff;

    final pages = [
      HomeScreen(
        onSeeAllTapped: () => setState(() => _currentIndex = 1),
      ),
      const ReportsListScreen(),
      const MyReportsScreen(),
      if (isStaff) const StaffDashboardScreen(),
    ];

    final safeIndex = _currentIndex >= pages.length ? 0 : _currentIndex;

    return Scaffold(
      body: pages[safeIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _openReportForm,
        backgroundColor: const Color(0xFF6347EB),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: safeIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavBarItem(
                icon: Icons.description_outlined,
                label: 'Reports',
                isSelected: safeIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 44), // Space for center + Report FAB
              _NavBarItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isSelected: safeIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              if (isStaff)
                _NavBarItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Staff',
                  isSelected: safeIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? const Color(0xFF6347EB) : Colors.grey.shade500;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}