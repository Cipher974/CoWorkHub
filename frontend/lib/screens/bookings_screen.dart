import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _api = ApiService();
  List<Booking> _bookings = [];
  bool _loading = true;
  int? _changingId;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final bookings = await _api.getBookings();
      if (mounted) setState(() => _bookings = bookings);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text),
      backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700));
  }

  Future<void> _cancel(Booking booking) async {
    final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Cancel booking?'),
      content: Text('Cancel booking #${booking.id}? It will remain in history.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel booking')),
      ],
    ));
    if (confirm != true || !mounted) return;
    setState(() => _changingId = booking.id);
    try {
      await _api.cancelBooking(booking);
      _message('Booking #${booking.id} cancelled.');
      await _load();
    } catch (e) {
      _message(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _changingId = null);
    }
  }

  Future<void> _edit(Booking booking) async {
  var start = booking.startDateTime;
  var end = booking.endDateTime;
  final attendees = TextEditingController(text: '${booking.attendees}');
  String? submittedAttendeesText;

  Future<DateTime?> pick(DateTime current) async {
    final day = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: current,
    );
    if (day == null || !mounted) return null;
    final clock = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (clock == null) return null;
    return DateTime(day.year, day.month, day.day, clock.hour, clock.minute);
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, update) => AlertDialog(
        title: Text('Update booking #${booking.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () async {
                final chosen = await pick(start);
                if (chosen != null && dialogContext.mounted) {
                  update(() => start = chosen);
                }
              },
              child: Text('Start: ${_date(start)}'),
            ),
            OutlinedButton(
              onPressed: () async {
                final chosen = await pick(end);
                if (chosen != null && dialogContext.mounted) {
                  update(() => end = chosen);
                }
              },
              child: Text('End: ${_date(end)}'),
            ),
            TextField(
              controller: attendees,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Attendees'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () {
              submittedAttendeesText = attendees.text;
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );

  // Let the dialog route finish unmounting before disposing the controller.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    attendees.dispose();
  });

  if (confirmed != true || !mounted) return;
  final count = int.tryParse((submittedAttendeesText ?? '').trim());
  if (!start.isBefore(end) || count == null || count < 1) {
    _message('Check start/end dates and attendees.', error: true);
    return;
  }

  setState(() => _changingId = booking.id);
  try {
    await _api.updateBooking(
      booking.id,
      memberId: booking.memberId,
      resourceId: booking.resourceId,
      startDateTime: start,
      endDateTime: end,
      attendees: count,
      status: booking.status,
    );
    _message('Booking updated successfully.');
    await _load();
    } catch (e) {
      _message(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _changingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      Row(children: [
        Text('Bookings', style: Theme.of(context).textTheme.headlineMedium),
        const Spacer(),
        IconButton(onPressed: _loading ? null : _load, tooltip: 'Refresh',
            icon: const Icon(Icons.refresh)),
      ]),
      const SizedBox(height: 12),
      if (_loading) const Expanded(child: Center(child: CircularProgressIndicator()))
      else if (_error != null) Expanded(child: Center(child: Column(
        mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ])))
      else Expanded(child: _bookings.isEmpty ? const Center(child: Text('No bookings yet.'))
        : ListView.builder(itemCount: _bookings.length, itemBuilder: (context, index) {
          final b = _bookings[index];
          final inactive = b.status == 'CANCELLED';
          return Card(child: ListTile(
            title: Text('#${b.id}  ${b.resourceName}'),
            subtitle: Text('${b.memberName}  •  ${_date(b.startDateTime)} - ${_date(b.endDateTime)}\n'
                '${b.attendees} attendee(s)  •  ${b.status}  •  QAR ${b.totalCost.toStringAsFixed(2)}'),
            isThreeLine: true,
            trailing: inactive ? const Text('Cancelled') : _changingId == b.id
                ? const CircularProgressIndicator()
                : Wrap( children: [
                    IconButton(tooltip: 'Update', onPressed: () => _edit(b), icon: const Icon(Icons.edit)),
                    IconButton(tooltip: 'Cancel', onPressed: () => _cancel(b), icon: const Icon(Icons.cancel_outlined)),
                  ]),
          ));
        })),
    ]));
  }
}
