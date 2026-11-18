import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/resource.dart';
import '../services/api_service.dart';

class NewBookingScreen extends StatefulWidget {
  const NewBookingScreen({super.key});

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _attendees = TextEditingController(text: '1');
  List<Member> _members = [];
  List<Resource> _available = [];
  Member? _member;
  Resource? _resource;
  DateTime _start = DateTime.now().add(const Duration(hours: 1));
  DateTime _end = DateTime.now().add(const Duration(hours: 2));
  bool _loading = true;
  bool _searching = false;
  bool _saving = false;
  bool _searched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _attendees.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final members = await _api.getMembers();
      if (!mounted) return;
      setState(() { _members = members; _member = members.isEmpty ? null : members.first; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _chooseDateTime(bool start) async {
    final value = start ? _start : _end;
    final date = await showDatePicker(context: context,
        firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: value);
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(value));
    if (time == null || !mounted) return;
    setState(() {
      final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (start) { _start = selected; } else { _end = selected; }
      _available = [];
      _resource = null;
      _searched = false;
    });
  }

  String _date(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  void _message(String value, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
    ));
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_start.isBefore(_end)) {
      _message('Start date/time must be before end date/time.', error: true);
      return;
    }
    setState(() { _searching = true; _error = null; _searched = false; _resource = null; });
    try {
      final result = await _api.getAvailableResources(
        startDateTime: _start, endDateTime: _end,
        attendees: int.parse(_attendees.text),
      );
      if (!mounted) return;
      setState(() { _available = result; _searched = true; });
      if (result.isEmpty) _message('No available resources for this time.', error: true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _book() async {
    if (!_formKey.currentState!.validate()) return;
    if (_member?.id == null || _resource == null) {
      _message('Select a member and an available resource.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final booking = await _api.createBooking(
        memberId: _member!.id!, resourceId: _resource!.id,
        startDateTime: _start, endDateTime: _end,
        attendees: int.parse(_attendees.text),
      );
      _message('Booking #${booking.id} created successfully.');
      // Refresh availability so the newly booked time is no longer selectable.
      await _search();
    } catch (e) {
      _message(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Availability / New Booking', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              TextButton(onPressed: _loadMembers, child: const Text('Retry')),
            ],
            DropdownButtonFormField<Member>(
              key: ValueKey(_member?.id),
              initialValue: _member,
              decoration: const InputDecoration(labelText: 'Member', border: OutlineInputBorder()),
              items: _members.map((m) => DropdownMenuItem(value: m, child: Text(m.fullName))).toList(),
              onChanged: (m) => setState(() => _member = m),
              validator: (m) => m == null ? 'Create/select a member first' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _attendees,
              decoration: const InputDecoration(labelText: 'Attendees', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (value) {
                final n = int.tryParse(value?.trim() ?? '');
                if (n == null || n < 1) return 'Enter at least 1 attendee';
                return null;
              },
              onChanged: (_) => setState(() { _searched = false; _resource = null; _available = []; }),
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 12, runSpacing: 8, children: [
              OutlinedButton.icon(onPressed: () => _chooseDateTime(true),
                icon: const Icon(Icons.event), label: Text('Start: ${_date(_start)}')),
              OutlinedButton.icon(onPressed: () => _chooseDateTime(false),
                icon: const Icon(Icons.event), label: Text('End: ${_date(_end)}')),
            ]),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _searching || _saving ? null : _search,
              icon: _searching ? const SizedBox(height: 16, width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
              label: const Text('Find available resources'),
            ),
            if (_searched) ...[
              const SizedBox(height: 24),
              Text('Available resources (${_available.length})',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (_available.isNotEmpty)
                DropdownButtonFormField<Resource>(
                  key: ValueKey('${_start.toIso8601String()}-${_end.toIso8601String()}-${_available.length}'),
                  initialValue: _resource,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Resource', border: OutlineInputBorder()),
                  items: _available.map((r) => DropdownMenuItem(
                    value: r,
                    child: Text('${r.name} (${r.type}) - ${r.location} - QAR ${r.hourlyRate.toStringAsFixed(2)}/hour',
                        overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (r) => setState(() => _resource = r),
                ),
              const SizedBox(height: 16),
              if (_resource != null)
                Text('Estimated cost: QAR ${(_resource!.hourlyRate * _end.difference(_start).inMinutes / 60).toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: (_resource == null || _saving || _searching) ? null : _book,
                icon: const Icon(Icons.check), label: Text(_saving ? 'Booking...' : 'Create booking'),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
