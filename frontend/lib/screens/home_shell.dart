import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'members_screen.dart';
// Import the other team members' screens and fix the class names if they differ:
import 'resources_screen.dart';   // Mufeeda
import 'new_booking_screen.dart'; // Karem
import 'bookings_screen.dart';    // Karem

/// Main window with a side navigation rail (desktop style).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    // Screens are rebuilt when selected, so each one reloads fresh data.
    final screens = <Widget>[
      DashboardScreen(onNavigate: _go),
      const ResourcesScreen(),
      const NewBookingScreen(),
      const BookingsScreen(),
      const MembersScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: _go,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(
                  icon: Icon(Icons.meeting_room), label: Text('Resources')),
              NavigationRailDestination(
                  icon: Icon(Icons.event_available), label: Text('New Booking')),
              NavigationRailDestination(
                  icon: Icon(Icons.list_alt), label: Text('Bookings')),
              NavigationRailDestination(
                  icon: Icon(Icons.people), label: Text('Members')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: screens[_index]),
        ],
      ),
    );
  }
}