import 'package:flutter/material.dart';

import '../models/booking.dart'; // Karem's Booking model
import '../models/member.dart';
import '../services/api_service.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  List<Member> _members = [];
  List<Booking> _bookings = [];
  Member? _selected;

  bool _loading = true;
  bool _saving = false;
  bool _loadingBookings = false;
  String? _error;
  String? _bookingsError;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _members = await _api.getMembers();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return; // validate before sending
    setState(() => _saving = true);
    try {
      await _api.createMember(
        Member(fullName: _nameCtrl.text.trim(), email: _emailCtrl.text.trim()),
      );
      _nameCtrl.clear();
      _emailCtrl.clear();
      _formKey.currentState!.reset();
      _showMessage('Member created successfully');
      await _loadMembers(); // refresh the list
    } catch (e) {
      _showMessage(e.toString(), isError: true); // e.g. "email already exists"
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _selectMember(Member m) async {
    setState(() {
      _selected = m;
      _loadingBookings = true;
      _bookingsError = null;
    });
    try {
      _bookings = await _api.getMemberBookings(m.id!);
    } catch (e) {
      _bookings = [];
      _bookingsError = e.toString();
    }
    if (mounted) setState(() => _loadingBookings = false);
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 300, child: _buildForm()),
          const SizedBox(width: 24),
          Expanded(child: _buildMemberList()),
          const SizedBox(width: 24),
          Expanded(child: _buildBookingsPanel()),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New member', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Full name', border: OutlineInputBorder()),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
                labelText: 'Email', border: OutlineInputBorder()),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Email is required';
              final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
              return ok ? null : 'Enter a valid email';
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _saveMember,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Add member'),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _loadMembers, child: const Text('Retry')),
        ]),
      );
    }
    if (_members.isEmpty) return const Center(child: Text('No members yet'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Members (${_members.length})',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _members.length,
            itemBuilder: (_, i) {
              final m = _members[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(m.fullName),
                  subtitle: Text(m.email),
                  selected: m == _selected,
                  onTap: () => _selectMember(m),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsPanel() {
    if (_selected == null) {
      return const Center(child: Text('Select a member to see their bookings'));
    }
    if (_loadingBookings) return const Center(child: CircularProgressIndicator());
    if (_bookingsError != null) {
      return Center(
          child: Text(_bookingsError!, style: const TextStyle(color: Colors.red)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bookings of ${_selected!.fullName}',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: _bookings.isEmpty
              ? const Center(child: Text('This member has no bookings'))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (_, i) {
                    final b = _bookings[i];
                    final cancelled = b.status == 'CANCELLED';
                    return Card(
                      child: ListTile(
                        // Adjust these fields to match Karem's Booking model
                        title: Text(b.resource.name),
                        subtitle: Text('${b.startDateTime}  →  ${b.endDateTime}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(b.status,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: cancelled ? Colors.red : Colors.green)),
                            Text(b.totalCost.toStringAsFixed(2)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}