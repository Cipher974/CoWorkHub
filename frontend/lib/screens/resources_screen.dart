import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/resource_service.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final _service = ResourceService();
  List<Resource> _resources = [];
  bool _loading = false;
  String? _error;

  String _type = 'ALL';
  final _minCapCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();

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
      final location = _locationCtrl.text.trim();
      final list = await _service.getResources(
        type: _type == 'ALL' ? null : _type,
        minCapacity: int.tryParse(_minCapCtrl.text.trim()),
        location: location.isEmpty ? null : location,
        maxPrice: double.tryParse(_maxPriceCtrl.text.trim()),
      );
      if (!mounted) return;
      setState(() => _resources = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red[700] : Colors.green[700],
    ));
  }

  void _clearFilters() {
    _type = 'ALL';
    _minCapCtrl.clear();
    _locationCtrl.clear();
    _maxPriceCtrl.clear();
    _load();
  }

  Future<void> _openForm([Resource? existing]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _ResourceFormDialog(existing: existing),
    );
    if (result == null) return;

    final isRoom = result.remove('isRoom') as bool;
    try {
      if (existing == null) {
        isRoom
            ? await _service.createRoom(result)
            : await _service.createDesk(result);
        _snack('Resource created');
      } else {
        await _service.updateResource(existing.id, result);
        _snack('Resource updated');
      }
      _load();
    } catch (e) {
      _snack(e.toString(), error: true);
    }
  }

  Future<void> _delete(Resource r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete resource'),
        content: Text('Delete "${r.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.deleteResource(r.id);
      _snack('Resource deleted');
      _load();
    } catch (e) {
      _snack(e.toString(), error: true); // e.g. 409: resource has bookings
    }
  }

  void _showDetails(Resource r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(r.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${r.isRoom ? 'Meeting Room' : 'Desk'}'),
            Text('Location: ${r.location}'),
            Text('Capacity: ${r.capacity}'),
            Text('Hourly rate: ${r.hourlyRate.toStringAsFixed(2)}'),
            Text('Status: ${r.status}'),
            if (r.isRoom) ...[
              Text('Projector: ${r.hasProjector ? 'Yes' : 'No'}'),
              Text('Video conference: ${r.hasVideoConference ? 'Yes' : 'No'}'),
            ] else
              Text('Desk type: ${r.deskType}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownButton<String>(
            value: _type,
            items: const [
              DropdownMenuItem(value: 'ALL', child: Text('All types')),
              DropdownMenuItem(value: 'ROOM', child: Text('Meeting rooms')),
              DropdownMenuItem(value: 'DESK', child: Text('Desks')),
            ],
            onChanged: (v) => setState(() => _type = v!),
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _minCapCtrl,
              decoration: const InputDecoration(labelText: 'Min capacity'),
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(
            width: 160,
            child: TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _maxPriceCtrl,
              decoration: const InputDecoration(labelText: 'Max price / hour'),
              keyboardType: TextInputType.number,
            ),
          ),
          ElevatedButton(onPressed: _load, child: const Text('Apply')),
          TextButton(onPressed: _clearFilters, child: const Text('Clear')),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_resources.isEmpty) {
      return const Center(child: Text('No resources found'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Capacity')),
            DataColumn(label: Text('Rate / hour')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _resources.map((r) {
            return DataRow(
              onSelectChanged: (_) => _showDetails(r),
              cells: [
                DataCell(Text(r.name)),
                DataCell(Text(r.isRoom ? 'Meeting Room' : 'Desk')),
                DataCell(Text(r.location)),
                DataCell(Text('${r.capacity}')),
                DataCell(Text(r.hourlyRate.toStringAsFixed(2))),
                DataCell(Text(r.status)),
                DataCell(Row(children: [
                  IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(r)),
                  IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _delete(r)),
                ])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('New resource'),
      ),
      body: Column(
        children: [
          _filterBar(),
          const Divider(height: 1),
          Expanded(child: _body()),
        ],
      ),
    );
  }
}

// ---------- Create / edit form ----------
class _ResourceFormDialog extends StatefulWidget {
  final Resource? existing;
  const _ResourceFormDialog({this.existing});

  @override
  State<_ResourceFormDialog> createState() => _ResourceFormDialogState();
}

class _ResourceFormDialogState extends State<_ResourceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _location;
  late TextEditingController _capacity;
  late TextEditingController _rate;
  late TextEditingController _deskType;
  late bool _isRoom;
  late String _status;
  late bool _projector;
  late bool _video;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _name = TextEditingController(text: r?.name ?? '');
    _location = TextEditingController(text: r?.location ?? '');
    _capacity = TextEditingController(text: r != null ? '${r.capacity}' : '');
    _rate = TextEditingController(text: r != null ? '${r.hourlyRate}' : '');
    _deskType = TextEditingController(text: r?.deskType ?? '');
    _isRoom = r?.isRoom ?? true;
    _status = r?.status ?? 'ACTIVE';
    _projector = r?.hasProjector ?? false;
    _video = r?.hasVideoConference ?? false;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final body = <String, dynamic>{
      'isRoom': _isRoom,
      'name': _name.text.trim(),
      'location': _location.text.trim(),
      'hourlyRate': double.parse(_rate.text.trim()),
      'status': _status,
    };
    if (_isRoom) {
      body['capacity'] = int.parse(_capacity.text.trim());
      body['hasProjector'] = _projector;
      body['hasVideoConference'] = _video;
    } else {
      body['deskType'] = _deskType.text.trim();
    }
    Navigator.pop(context, body);
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Edit resource' : 'New resource'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<bool>(
                  value: _isRoom,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Meeting Room')),
                    DropdownMenuItem(value: false, child: Text('Desk')),
                  ],
                  onChanged:
                      _editing ? null : (v) => setState(() => _isRoom = v!),
                ),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: _required,
                ),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: _required,
                ),
                if (_isRoom)
                  TextFormField(
                    controller: _capacity,
                    decoration: const InputDecoration(labelText: 'Capacity'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return (n == null || n < 1) ? 'Enter a number >= 1' : null;
                    },
                  ),
                TextFormField(
                  controller: _rate,
                  decoration: const InputDecoration(labelText: 'Hourly rate'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return (n == null || n < 0) ? 'Enter a number >= 0' : null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                    DropdownMenuItem(
                        value: 'OUT_OF_SERVICE',
                        child: Text('OUT_OF_SERVICE')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
                if (_isRoom) ...[
                  SwitchListTile(
                    title: const Text('Projector'),
                    value: _projector,
                    onChanged: (v) => setState(() => _projector = v),
                  ),
                  SwitchListTile(
                    title: const Text('Video conference'),
                    value: _video,
                    onChanged: (v) => setState(() => _video = v),
                  ),
                ] else
                  TextFormField(
                    controller: _deskType,
                    decoration: const InputDecoration(labelText: 'Desk type'),
                    validator: _required,
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}