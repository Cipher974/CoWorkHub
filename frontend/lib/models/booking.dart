import 'resource.dart';

class Booking {
  final int id;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int attendees;
  final String status;
  final double totalCost;
  final int memberId;
  final int resourceId;
  final String memberName;
  final String resourceName;
  final Resource resource;

  Booking({
    required this.id,
    required this.startDateTime,
    required this.endDateTime,
    required this.attendees,
    required this.status,
    required this.totalCost,
    required this.memberId,
    required this.resourceId,
    required this.memberName,
    required this.resourceName,
    required this.resource,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final member = (json['member'] as Map<String, dynamic>? ?? {});
    final resource = (json['resource'] as Map<String, dynamic>? ?? {});
    return Booking(
      id: (json['id'] as num).toInt(),
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      attendees: (json['attendees'] as num).toInt(),
      status: json['status'] as String? ?? 'CONFIRMED',
      totalCost: (json['totalCost'] as num? ?? 0).toDouble(),
      memberId: (member['id'] as num).toInt(),
      resourceId: (resource['id'] as num).toInt(),
      memberName: member['fullName'] as String? ?? 'Member #${member['id']}',
      resourceName: resource['name'] as String? ?? 'Resource #${resource['id']}',
      resource: Resource.fromJson(resource),
    );
  }
}
