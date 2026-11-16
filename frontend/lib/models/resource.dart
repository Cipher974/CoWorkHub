class Resource {
  final int id;
  final String name;
  final String location;
  final int capacity;
  final double hourlyRate;
  final String status; // ACTIVE / OUT_OF_SERVICE
  final String type; // ROOM / DESK
  final bool hasProjector;
  final bool hasVideoConference;
  final String deskType;

  Resource({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.hourlyRate,
    required this.status,
    required this.type,
    this.hasProjector = false,
    this.hasVideoConference = false,
    this.deskType = '',
  });

  bool get isRoom => type == 'ROOM';

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      capacity: json['capacity'],
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      status: json['status'],
      type: json['type'],
      hasProjector: json['hasProjector'] ?? false,
      hasVideoConference: json['hasVideoConference'] ?? false,
      deskType: json['deskType'] ?? '',
    );
  }
}