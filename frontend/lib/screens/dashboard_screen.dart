import 'package:flutter/material.dart';

import '../services/api_service.dart';

/// Home screen: summary cards + shortcuts to the other screens.
/// [onNavigate] switches the tab in HomeShell (index of the NavigationRail).
class DashboardScreen extends StatefulWidget {
  final void Function(int index) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = ApiService();

  bool _loading = true;
  String? _error;
  int _resources = 0, _members = 0, _confirmed = 0, _cancelled = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Run the three requests at the same time
      final results = await Future.wait([
        _api.getResources(),
        _api.getMembers(),
        _api.getBookings(),
      ]);
      _resources = (results[0] as List).length;
      _members = (results[1] as List).length;
      final bookings = results[2] as List;
      _confirmed = bookings.where((b) => b.status == 'CONFIRMED').length;
      _cancelled = bookings.where((b) => b.status == 'CANCELLED').length;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 8),
          Text('Cannot reach the server: $_error'),
          const SizedBox(height: 8),
          FilledButton(onPressed: _load, child: const Text('Retry')),
        ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('CoWorkHub Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              IconButton(
                  tooltip: 'Refresh',
                  onPressed: _load,
                  icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _card('Resources', _resources, Icons.meeting_room, 1),
              _card('Members', _members, Icons.people, 4),
              _card('Confirmed bookings', _confirmed, Icons.event_available, 3),
              _card('Cancelled bookings', _cancelled, Icons.event_busy, 3),
            ],
          ),
          const SizedBox(height: 32),
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(spacing: 12, children: [
            FilledButton.icon(
                onPressed: () => widget.onNavigate(2),
                icon: const Icon(Icons.add),
                label: const Text('New booking')),
            OutlinedButton.icon(
                onPressed: () => widget.onNavigate(4),
                icon: const Icon(Icons.person_add),
                label: const Text('Add member')),
          ]),
        ],
      ),
    );
  }

  Widget _card(String title, int value, IconData icon, int targetIndex) {
    return SizedBox(
      width: 220,
      child: Card(
        child: InkWell(
          onTap: () => widget.onNavigate(targetIndex),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32),
                const SizedBox(height: 12),
                Text('$value',
                    style: Theme.of(context).textTheme.headlineMedium),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}